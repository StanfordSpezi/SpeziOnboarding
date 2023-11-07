//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PDFKit
import PencilKit
import SpeziPersonalInfo
import SpeziViews
import SwiftUI


/// The ``ConsentDocument`` allows the display of markdown-based consent documents that can be signed using a family and given name and a hand drawn signature. In addition, it enables the export of the signed form as a PDF document.
///
/// To observe and control the current state of the ``ConsentDocument``, the view requires passing down a ``ConsentDocument/ConsentViewState`` as a SwiftUI `Binding` in the ``ConsentView/init(header:asyncMarkdown:footer:givenNameField:familyNameField:exportConfiguration:action:)`` initializer.
/// This `Binding` can then be used to trigger the export of the consent form via setting the state to ``ConsentDocument/ConsentViewState/export``.
/// After the rendering completes, the finished `PDFDocument` from Apple's PDFKit is accessible via the associated value of the view state in ``ConsentDocument/ConsentViewState/exported(document:)``.
/// Other possible states of the ``ConsentDocument`` are the SpeziViews `ViewState`'s accessible via the associated value in ``ConsentDocument/ConsentViewState/base(_:)``. In addition, the view provides information about the signing progress via the ``ConsentDocument/ConsentViewState/signing`` and ``ConsentDocument/ConsentViewState/signed`` states.
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
    private let asyncMarkdown: (() async -> Data)
    private let givenNameTitle: LocalizedStringResource
    private let givenNamePlaceholder: LocalizedStringResource
    private let familyNameTitle: LocalizedStringResource
    private let familyNamePlaceholder: LocalizedStringResource
    private let exportConfiguration: ExportConfiguration
    
    @State private var name = PersonNameComponents()
    @State private var signature = PKDrawing()
    @State private var signatureSize: CGSize = .zero
    @Binding private var viewState: ConsentViewState
    
    
    private var nameView: some View {
        VStack {
            Divider()
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
                .disabled(inputFieldsDisabled)
                .onChange(of: name) {
                    if !(name.givenName?.isEmpty ?? true) && !(name.familyName?.isEmpty ?? true) {
                        viewState = .namesEntered
                    } else {
                        viewState = .base(.idle)
                        /// Reset all strokes if name fields are not complete anymore
                        signature.strokes.removeAll()
                    }
                }
            
            Divider()
        }
    }
    
    private var signatureView: some View {
        SignatureView(signature: $signature, isSigning: $viewState.signing, name: name)
            .padding(.vertical, 4)
            .disabled(inputFieldsDisabled)
            /// Capture the canvas size of the signature, important to export the consent form to a PDF
            .onPreferenceChange(CanvasView.CanvasSizePreferenceKey.self) { size in
                signatureSize = size
            }
            .onChange(of: signature) {
                if !(signature.strokes.isEmpty || (name.givenName?.isEmpty ?? true) || (name.familyName?.isEmpty ?? true)) {
                    viewState = .signed
                } else {
                    viewState = .namesEntered
                }
            }
    }
    
    public var body: some View {
        VStack {
            MarkdownView(asyncMarkdown: asyncMarkdown, state: $viewState.base)
            Spacer()
            nameView
            if case .base(let baseViewState) = viewState,
               case .idle = baseViewState {
                EmptyView()
            } else {
                signatureView
            }
        }
            .transition(.opacity)
            .animation(.easeInOut, value: viewState == .namesEntered)
            .onChange(of: viewState) {
                if case .export = viewState {
                    Task {
                        guard let exportedConsent = await export() else {
                            viewState = .base(.error(Error.memoryAllocationError))
                            return
                        }
                        viewState = .exported(document: exportedConsent)
                    }
                } else if case .base(let baseViewState) = viewState,
                          case .idle = baseViewState {
                    /// Reset view state to correct one after handling an error view state via `.viewStateAlert()`
                    if !signature.strokes.isEmpty {
                        viewState = .signed
                    } else if !((name.givenName?.isEmpty ?? true) || (name.familyName?.isEmpty ?? true)) {
                        viewState = .namesEntered
                    }
                }
            }
            .viewStateAlert(state: $viewState.base)
    }
    
    private var inputFieldsDisabled: Bool {
        viewState == .base(.processing) || viewState == .export
    }
    
    
    /// Creates a ``ConsentDocument`` which renders a consent document with a markdown view. The passed ``ConsentDocument/ConsentViewState`` indicates in which state the view currently is. This is especially useful for exporting the consent form as well as error management.
    /// - Parameters:
    ///   - markdown: The markdown content provided as an UTF8 encoded `Data` instance that can be provided asynchronously.
    ///   - viewState: A `Binding` to observe the ``ConsentDocument/ConsentViewState`` of the ``ConsentDocument``. 
    ///   - givenNameField: The localization to use for the given (first) name field.
    ///   - familyNameField: The localization to use for the family (last) name field.
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


/// Extension of ``ConsentDocument`` enabling the export of the signed consent page.
extension ConsentDocument {
    /// Exports the signed consent form as a `PDFDocument` via the SwiftUI `ImageRenderer`.
    /// Renders the `PDFDocument` according to the specified ``ConsentDocument/ExportConfiguration``.
    ///
    /// - Returns: The exported consent form in PDF format as a PDFKit `PDFDocument`
    @MainActor
    private func export() async -> PDFDocument? {
        let markdown = await asyncMarkdown()
        
        let markdownString = (try? AttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(String(localized: "MARKDOWN_LOADING_ERROR", bundle: .module))
        
        let renderer = ImageRenderer(content: exportBody(markdown: markdownString))
        let paperSize = CGSize(
            width: exportConfiguration.paperSize.dimensions.width,
            height: exportConfiguration.paperSize.dimensions.height
        )
        renderer.proposedSize = .init(paperSize)
        
        return await withCheckedContinuation { continuation in
            renderer.render { _, context in
                var box = CGRect(origin: .zero, size: paperSize)
                
                /// Create in-memory `CGContext` that stores the PDF
                guard let mutableData = CFDataCreateMutable(kCFAllocatorDefault, 0),
                      let consumer = CGDataConsumer(data: mutableData),
                      let pdf = CGContext(consumer: consumer, mediaBox: &box, nil) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                pdf.beginPDFPage(nil)
                pdf.translateBy(x: 0, y: 0)
                
                context(pdf)
                
                pdf.endPDFPage()
                pdf.closePDF()
                
                continuation.resume(returning: PDFDocument(data: mutableData as Data))
            }
        }
    }
    
    /// Creates a representation of the consent form that is ready to be exported via the SwiftUI `ImageRenderer`.
    ///
    /// - Parameters:
    ///   - markdown: The markdown consent content as an `AttributedString`.
    ///
    /// - Returns: A SwiftUI `View` representation of the consent content and signature.
    ///
    /// - Note: This function avoids the use of asynchronous operations.
    /// Asynchronous tasks are incompatible with SwiftUI's `ImageRenderer`,
    /// which expects all rendering processes to be synchronous.
    private func exportBody(markdown: AttributedString) -> some View {
        VStack {
            if exportConfiguration.includingTimestamp {
                HStack {
                    Spacer()
                    
                    Text("\(LocalizedStringResource("EXPORTED_TAG", bundle: .atURL(from: .module))): \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))")
                }
                .font(.caption)
                .padding()
            }
            
            OnboardingTitleView(title: exportConfiguration.consentTitle)
            
            Text(markdown)
                .padding()
            
            Spacer()
            
            ZStack(alignment: .bottomLeading) {
                SignatureViewBackground(name: name, backgroundColor: .clear)
                
                Image(uiImage: signature.image(
                    from: .init(x: 0, y: 0, width: signatureSize.width, height: signatureSize.height),
                    scale: UIScreen.main.scale
                ))
            }
            .frame(width: signatureSize.width, height: signatureSize.height)
        }
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
            .navigationTitle("Consent")
            .padding()
        }
    }
}
#endif
