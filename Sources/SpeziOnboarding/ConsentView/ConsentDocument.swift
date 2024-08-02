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
/// ``init(markdown:viewState:givenNameTitle:givenNamePlaceholder:familyNameTitle:familyNamePlaceholder:exportConfiguration:)`` initializer.
/// This `Binding` can then be used to trigger the export of the consent form via setting the state to ``ConsentViewState/export``.
/// After the rendering completes, the finished `PDFDocument` from Apple's PDFKit is accessible via the associated value of the view state in ``ConsentViewState/exported(document:)``.
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
///     exportConfiguration: .init(paperSize: .usLetter)   // Configure the properties of the exported consent form
/// )
/// ```
public struct ConsentDocument: View {
    /// The maximum width such that the drawing canvas fits onto the PDF.
    static let maxWidthDrawing: CGFloat = 550

    let asyncMarkdown: () async -> Data
    private let givenNameTitle: LocalizedStringResource
    private let givenNamePlaceholder: LocalizedStringResource
    private let familyNameTitle: LocalizedStringResource
    private let familyNamePlaceholder: LocalizedStringResource
    let exportConfiguration: ExportConfiguration
    
    @Environment(\.colorScheme) var colorScheme
    @State var name = PersonNameComponents()
    #if !os(macOS)
    @State var signature = PKDrawing()
    #else
    @State var signature = String()
    #endif
    @State var signatureSize: CGSize = .zero
    @Binding private var viewState: ConsentViewState
    @State private var checked: [String: Bool] = [:]
    @State private var markdownStrings: [String] = []
    @State public var cleanedMarkdownData: Data?
    @State public var checkboxSnapshot: UIImage?
    
    private var nameView: some View {
        VStack {
            Divider()
            Group {
                #if !os(macOS)
                nameInputView
                #else
                // Need to wrap the `NameFieldRow` from SpeziViews into a SwiftUI `Form, otherwise the Label is omitted
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
    
    private func extractMarkdownCB() async -> (cleanedMarkdown: String, checkboxes: [String]) {
        let data = await asyncMarkdown()
        let dataString = String(data: data, encoding: .utf8)!
        
        var result = [String]()
        var start: String.Index? = nil
        var cleanedMarkdown = ""
        var isInBracket = false

        for (index, char) in dataString.enumerated() {
            let currentIndex = dataString.index(dataString.startIndex, offsetBy: index)
            
            if char == "[" {
                start = currentIndex
                isInBracket = true
            } else if char == "]", let start = start {
                let end = currentIndex
                let subInd = dataString.index(after: start)
                let substring = String(dataString[subInd..<end])
                result.append(substring)
                isInBracket = false
            } else if !isInBracket {
                cleanedMarkdown.append(char)
            }
        }
        
        return (cleanedMarkdown, result)
    }
    
    private var checkboxesView: some View {
        VStack {
            Grid(horizontalSpacing: 15) {
                ForEach(markdownStrings, id: \.self) { markdownString in
                    GridRow {
                        Text(markdownString)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button(action: {
                            withAnimation {
                                checked[markdownString]?.toggle()
                            }
                        }) {
                            Image(systemName: checked[markdownString] == true ? "checkmark.square.fill" : "xmark.square.fill")
                                .foregroundColor(checked[markdownString] == true ? .green : .red)
                        }
                    }
                    Divider()
                        .gridCellUnsizedAxes(.horizontal)
                }
            }
        }
        .onAppear {
            Task {
                let (cleanedMarkdown, checkboxes) = await extractMarkdownCB()
                cleanedMarkdownData = Data(cleanedMarkdown.utf8)
                markdownStrings = checkboxes
                for string in markdownStrings {
                    checked[string] = false
                }
            }
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
    
    private var signatureView: some View {
        Group {
            #if !os(macOS)
            SignatureView(signature: $signature, isSigning: $viewState.signing, canvasSize: $signatureSize, name: name)
            #else
            SignatureView(signature: $signature, name: name)
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
            if let cleanedMarkdownData = cleanedMarkdownData {
                MarkdownView(asyncMarkdown: {cleanedMarkdownData}, state: $viewState.base)
                    .padding(.bottom, 15)
            }
            checkboxesView
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
                    let renderer = ImageRenderer(content: checkboxesView)
                    if let uiImage = renderer.uiImage {
                        checkboxSnapshot = uiImage
                    }
                    Task {
                        guard let exportedConsent = await export() else {
                            viewState = .base(.error(Error.memoryAllocationError))
                            return
                        }
                        viewState = .exported(document: exportedConsent)
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
        viewState == .base(.processing) || viewState == .export
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
    public init(
        markdown: @escaping () async -> Data,
        viewState: Binding<ConsentViewState>,
        givenNameTitle: LocalizedStringResource = LocalizationDefaults.givenNameTitle,
        givenNamePlaceholder: LocalizedStringResource = LocalizationDefaults.givenNamePlaceholder,
        familyNameTitle: LocalizedStringResource = LocalizationDefaults.familyNameTitle,
        familyNamePlaceholder: LocalizedStringResource = LocalizationDefaults.familyNamePlaceholder,
        exportConfiguration: ExportConfiguration = .init()
    ) {
        self.asyncMarkdown = markdown
        self._viewState = viewState
        self.givenNameTitle = givenNameTitle
        self.givenNamePlaceholder = givenNamePlaceholder
        self.familyNameTitle = familyNameTitle
        self.familyNamePlaceholder = familyNamePlaceholder
        self.exportConfiguration = exportConfiguration
    }
}


#if DEBUG
struct ConsentDocument_Previews: PreviewProvider {
    @State private static var viewState: ConsentViewState = .base(.idle)
    
    
    static var previews: some View {
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
}
#endif
