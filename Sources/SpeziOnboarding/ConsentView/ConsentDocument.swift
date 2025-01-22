//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PencilKit
import SpeziPersonalInfo
import SpeziViews
import SwiftUI


/// Display markdown-based consent documents that can be signed and exported.
///
/// Allows the display markdown-based consent documents that can be signed using a family and given name and a hand drawn signature.
/// In addition, it enables the export of the signed form as a PDF document.
///
/// To observe and control the current state of the `ConsentDocument`, the view requires passing down a ``ConsentViewState`` as a SwiftUI `Binding` in the
/// ``init(markdown:viewState:givenNameTitle:givenNamePlaceholder:familyNameTitle:familyNamePlaceholder:exportConfiguration:documentIdentifier:consentSignatureDate:consentSignatureDateFormatter:)`` initializer.
/// This `Binding` can then be used to trigger the export of the consent form via setting the state to ``ConsentViewState/export``.
/// After the rendering completes, the finished `PDFDocument` from Apple's PDFKit is accessible via the associated value of the view state in ``ConsentViewState/exported(document:export:)``.
/// Other possible states of the `ConsentDocument` are the SpeziViews `ViewState`'s accessible via the associated value in ``ConsentViewState/base(_:)``.
/// In addition, the view provides information about the signing progress via the ``ConsentViewState/signing`` and ``ConsentViewState/signed`` states.
///
/// ```swift
/// // Enables observing the view state of the consent document
/// @State var state: ConsentDocument.ConsentViewState = .base(.idle)
///
/// ConsentDocument(
///     markdown: {
///         Data("This is a *markdown* **example**".utf8)
///     },
///     viewState: $state,
///     exportConfiguration: .init(paperSize: .usLetter),   // Configure the properties of the exported consent form
///     consentSignatureDate: .now
/// )
/// ```
public struct ConsentDocument: View {
    /// The maximum width such that the drawing canvas fits onto the PDF.
    static let maxWidthDrawing: CGFloat = 550

    private let givenNameTitle: LocalizedStringResource
    private let givenNamePlaceholder: LocalizedStringResource
    private let familyNameTitle: LocalizedStringResource
    private let familyNamePlaceholder: LocalizedStringResource
    private let consentSignatureDate: Date?
    private let consentSignatureDateFormatter: DateFormatter

    let markdown: () async -> Data
    let exportConfiguration: ExportConfiguration
    let documentIdentifier: String

    @Environment(\.colorScheme) var colorScheme
    @State var name = PersonNameComponents()
    #if !os(macOS)
    @State var signature = PKDrawing()
    #else
    @State var signature = String()
    #endif
    @State var signatureSize: CGSize = .zero
    @Binding private var viewState: ConsentViewState
    
    
    private var nameView: some View {
        VStack {
            Divider()
            Group {
                #if !os(macOS)
                nameInputView
                #else
                // Need to wrap the `NameFieldRow` from SpeziViews into a SwiftUI `Form`, otherwise the Label is omitted
                Form {
                    nameInputView
                }
                #endif
            }
                .disabled(inputFieldsDisabled)
                .onChange(of: name) {
                    if !(name.givenName?.isEmpty ?? true) && !(name.familyName?.isEmpty ?? true) {
                        viewState = .namesEntered
                    } else {
                        viewState = .base(.idle)
                        // Reset all strokes if name fields are not complete anymore
                        #if !os(macOS)
                        signature.strokes.removeAll()
                        #else
                        signature.removeAll()
                        #endif
                    }
                }
            
            Divider()
        }
    }
    
    private var nameInputView: some View {
        Grid(horizontalSpacing: 15) {
            NameFieldRow(name: $name, for: \.givenName) {
                Text(givenNameTitle)
            } label: {
                Text(givenNamePlaceholder)
            }
            Divider()
                .gridCellUnsizedAxes(.horizontal)
            NameFieldRow(name: $name, for: \.familyName) {
                Text(familyNameTitle)
            } label: {
                Text(familyNamePlaceholder)
            }
        }
    }
    
    @MainActor private var signatureView: some View {
        Group {
            #if !os(macOS)
            SignatureView(
                signature: $signature,
                isSigning: $viewState.signing,
                canvasSize: $signatureSize,
                name: name,
                formattedDate: formattedConsentSignatureDate
            )
            #else
            SignatureView(
                signature: $signature,
                name: name,
                formattedDate: formattedConsentSignatureDate
            )
            #endif
        }
            .padding(.vertical, 4)
            .disabled(inputFieldsDisabled)
            .onChange(of: signature) {
                #if !os(macOS)
                let isSignatureEmpty = signature.strokes.isEmpty
                #else
                let isSignatureEmpty = signature.isEmpty
                #endif
                if !(isSignatureEmpty || (name.givenName?.isEmpty ?? true) || (name.familyName?.isEmpty ?? true)) {
                    viewState = .signed
                } else {
                    viewState = .namesEntered
                }
            }
    }
    
    public var body: some View {
        VStack {
            MarkdownView(asyncMarkdown: markdown, state: $viewState.base)
            Spacer()
            Group {
                nameView
                if case .base(let baseViewState) = viewState,
                   case .idle = baseViewState {
                    EmptyView()
                } else {
                    signatureView
                }
            }
                .frame(maxWidth: Self.maxWidthDrawing) // Limit the max view size so it fits on the PDF
        }
            .transition(.opacity)
            .animation(.easeInOut, value: viewState == .namesEntered)
            .onChange(of: viewState) {
                if case .export = viewState {
                    Task {
                        do {
                            // Stores the finished PDF in the Spezi `Standard`.
                            let exportedConsent = try await export()
                            viewState = .exported(document: exportedConsent)
                        } catch {
                            // In case of error, go back to previous state.
                            viewState = .base(.error(AnyLocalizedError(error: error)))
                        }
                    }
                } else if case .base(let baseViewState) = viewState,
                          case .idle = baseViewState {
                    // Reset view state to correct one after handling an error view state via `.viewStateAlert()`
                    #if !os(macOS)
                    let isSignatureEmpty = signature.strokes.isEmpty
                    #else
                    let isSignatureEmpty = signature.isEmpty
                    #endif
                    
                    if !isSignatureEmpty {
                        viewState = .signed
                    } else if !(name.givenName?.isEmpty ?? true) || !(name.familyName?.isEmpty ?? true) {
                        viewState = .namesEntered
                    }
                }
            }
                .viewStateAlert(state: $viewState.base)
    }
    
    private var inputFieldsDisabled: Bool {
        viewState == .base(.processing) || viewState == .export || viewState == .storing
    }

    var formattedConsentSignatureDate: String? {
        if let consentSignatureDate {
            consentSignatureDateFormatter.string(from: consentSignatureDate)
        } else {
            nil
        }
    }

    
    /// Creates a `ConsentDocument` which renders a consent document with a markdown view.
    ///
    /// The passed ``ConsentViewState`` indicates in which state the view currently is.
    /// This is especially useful for exporting the consent form as well as error management.
    /// - Parameters:
    ///   - markdown: The markdown content provided as an UTF8 encoded `Data` instance that can be provided asynchronously.
    ///   - viewState: A `Binding` to observe the ``ConsentViewState`` of the ``ConsentDocument``. 
    ///   - givenNameTitle: The localization to use for the given (first) name field.
    ///   - givenNamePlaceholder: The localization to use for the given name field placeholder.
    ///   - familyNameTitle: The localization to use for the family (last) name field.
    ///   - familyNamePlaceholder: The localization to use for the family name field placeholder.
    ///   - exportConfiguration: Defines the properties of the exported consent form via ``ConsentDocument/ExportConfiguration``.
    ///   - documentIdentifier: A unique identifier or "name" for the consent form, helpful for distinguishing consent forms when storing in the `Standard`.
    ///   - consentSignatureDate: The date that is displayed under the signature line.
    ///   - consentSignatureDateFormatter: The date formatter used to format the date that is displayed under the signature line.
    public init(
        markdown: @escaping () async -> Data,
        viewState: Binding<ConsentViewState>,
        givenNameTitle: LocalizedStringResource = LocalizationDefaults.givenNameTitle,
        givenNamePlaceholder: LocalizedStringResource = LocalizationDefaults.givenNamePlaceholder,
        familyNameTitle: LocalizedStringResource = LocalizationDefaults.familyNameTitle,
        familyNamePlaceholder: LocalizedStringResource = LocalizationDefaults.familyNamePlaceholder,
        exportConfiguration: ExportConfiguration = .init(),
        documentIdentifier: String = ConsentDocumentExport.Defaults.documentIdentifier,
        consentSignatureDate: Date? = nil,
        consentSignatureDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }()
    ) {
        self.markdown = markdown
        self._viewState = viewState
        self.givenNameTitle = givenNameTitle
        self.givenNamePlaceholder = givenNamePlaceholder
        self.familyNameTitle = familyNameTitle
        self.familyNamePlaceholder = familyNamePlaceholder
        self.exportConfiguration = exportConfiguration
        self.documentIdentifier = documentIdentifier
        self.consentSignatureDate = consentSignatureDate
        self.consentSignatureDateFormatter = consentSignatureDateFormatter
    }
}


#if DEBUG
#Preview {
    @Previewable @State var viewState: ConsentViewState = .base(.idle)


    NavigationStack {
        ConsentDocument(
            markdown: {
                Data("This is a *markdown* **example**".utf8)
            },
            viewState: $viewState
        )
        .navigationTitle(Text(verbatim: "Consent"))
        .padding()
    }
}
#endif
