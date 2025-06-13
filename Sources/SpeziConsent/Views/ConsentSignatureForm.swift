//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PencilKit
import SpeziPersonalInfo
import SpeziViews
import SwiftUI


/// A Signature Form with Name entry.
///
/// Display markdown-based consent documents that can be signed and exported.
///
/// Allows the display markdown-based consent documents that can be signed using a family and given name and a hand drawn signature.
/// In addition, it enables the export of the signed form as a PDF document.
///
/// To observe and control the current state of the ``ConsentDocument``, the `View` requires passing down a ``ConsentViewState`` as a SwiftUI `Binding` in the
/// ``init(markdown:viewState:givenNameTitle:givenNamePlaceholder:familyNameTitle:familyNamePlaceholder:exportConfiguration:consentSignatureDate:consentSignatureDateFormatter:)`` initializer.
///
/// This `Binding` can then be used to trigger the creation of the export representation of the consent form via setting the state to ``ConsentViewState/export``.
/// After the export representation completes, the ``ConsentDocumentExportRepresentation`` is accessible via the associated value of the view state in ``ConsentViewState/exported(representation:)``.
/// The ``ConsentDocumentExportRepresentation`` can then be rendered to a PDF via ``ConsentDocumentExportRepresentation/render()``.
///
/// Other possible states of the ``ConsentDocument`` are the SpeziViews `ViewState`'s accessible via the associated value in ``ConsentViewState/base(_:)``.
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
public struct ConsentSignatureForm: View {
    /// The maximum width such that the drawing canvas fits onto the PDF.
    static let maxWidthDrawing: CGFloat = 550

    private let labels: Labels
    private let signatureDate: Date?
    private let signatureDateFormat: Date.FormatStyle

    @Environment(\.colorScheme) var colorScheme
    @Binding private var storage: ConsentDocument.SignatureStorage
    private var isSigning: Binding<Bool>?
    
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
            .onChange(of: storage.name) { _, _ in
                print("STORAGE DID CHANGE")
                if !storage.didEnterNames {
                    print("clear signature")
                    // Reset all strokes if name fields are not complete anymore
                    self.storage.clearSignature()
                }
            }
            Divider()
        }
    }
    
    private var nameInputView: some View {
        Grid(horizontalSpacing: 15) {
            NameFieldRow(name: $storage.name, for: \.givenName) {
                Text(labels.givenNameTitle)
                    .fontWeight(.medium)
            } label: {
                Text(labels.givenNamePlaceholder)
            }
            Divider()
                .gridCellUnsizedAxes(.horizontal)
            NameFieldRow(name: $storage.name, for: \.familyName) {
                Text(labels.familyNameTitle)
                    .fontWeight(.medium)
            } label: {
                Text(labels.familyNamePlaceholder)
            }
        }
    }
    
    private var signatureView: some View {
        Group {
            let footer = SignatureView.Footer(
                leading: Text(storage.name, format: .name(style: .long)),
                trailing: signatureDate.map { Text($0, format: signatureDateFormat) }
            )
            #if !os(macOS)
            SignatureView(
                signature: $storage.signature,
                isSigning: isSigning ?? .constant(false),
                canvasSize: $storage.size,
                footer: footer
            )
            #else
            SignatureView(
                signature: $storage.signature,
                footer: footer
            )
            #endif
        }
        .padding(.vertical, 4)
    }
    
    public var body: some View {
        Group {
            nameView
            signatureView
        }
        .frame(maxWidth: Self.maxWidthDrawing) // Limit the max view size so it fits on the PDF
        .transition(.opacity)
        .animation(.easeInOut, value: storage.didEnterNames)
//        .task(id: viewState) {
//            if case .export = viewState {
////                // Captures the current state of the document and transforms it to the `ConsentDocumentExportRepresentation`
////                self.viewState = .exported(
////                    representation: await self.exportRepresentation
////                )
//                fatalError()
//            } else if case .base(let baseViewState) = viewState,
//                      case .idle = baseViewState {
//                // Reset view state to correct one after handling an error view state via `.viewStateAlert()`
//                #if !os(macOS)
//                let isSignatureEmpty = storage.signature.strokes.isEmpty
//                #else
//                let isSignatureEmpty = storage.signature.isEmpty
//                #endif
//
//                if !isSignatureEmpty {
//                    self.viewState = .signed
//                } else if !(name.givenName?.isEmpty ?? true) && !(name.familyName?.isEmpty ?? true) {
//                    self.viewState = .namesEntered
//                }
//            }
//        }
//        .viewStateAlert(state: $viewState.base)
    }

    var formattedConsentSignatureDate: String? {
        if let signatureDate {
            signatureDate.formatted(signatureDateFormat)
        } else {
            nil
        }
    }

    
    /// Creates a `ConsentDocument` which renders a consent document with a markdown view.
    ///
    /// The passed ``ConsentViewState`` indicates in which state the view currently is.
    /// This is especially useful for exporting the consent form as well as error management.
    /// - Parameters:
    ///   - labels: Allows customizing which text should be used for the signature field's labels.
    ///   - storage: A `Binding` to the storage that manages the data input into this view (i.e., the name and the signature).
    ///   - isSigning: An optional `Binding<Bool>` that will be updated by this view to indicate whether the user is currently entering their signature into the field.
    ///   - signatureDate: The date that is displayed under the signature line.
    ///   - signatureDateFormat: The date format used to format the `signatureDate`.
    public init(
        labels: Labels = .init(), // swiftlint:disable:this function_default_parameter_at_end
        storage: Binding<ConsentDocument.SignatureStorage>,
        isSigning: Binding<Bool>? = nil,
        signatureDate: Date? = nil,
        signatureDateFormat: Date.FormatStyle = .init(date: .numeric)
    ) {
        self._storage = storage
        self.labels = labels
        self.isSigning = isSigning
        self.signatureDate = signatureDate
        self.signatureDateFormat = signatureDateFormat
    }
}


#if DEBUG
#Preview {
    @Previewable @State var storage = ConsentDocument.SignatureStorage()
    NavigationStack {
        ConsentSignatureForm(
            storage: $storage,
            signatureDate: .now
        )
        .navigationTitle(Text(verbatim: "Consent"))
        .padding()
    }
}
#endif
