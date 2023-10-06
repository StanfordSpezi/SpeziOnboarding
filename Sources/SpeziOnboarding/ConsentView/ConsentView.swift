//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreGraphics
import PDFKit
import PencilKit
import SpeziViews
import SwiftUI


/// The ``ConsentView`` allows the display of markdown-based documents that can be signed using a family and given name and a hand drawn signature.
///
/// The ``ConsentView`` provides a convenience initializer with a provided action view using an ``OnboardingActionsView`` (``ConsentView/init(header:asyncMarkdown:footer:action:)``)
/// or a more customized ``ConsentView/init(contentView:actionView:)`` initializer with a custom-provided content and action view.
///
/// The ``ConsentView`` is able to automatically export the signed consent form (in the Markdown version) as a PDF  to the Spezi `Standard`. To handle the exported form, the `Standard` needs to conform to ``OnboardingConstraint``. Developers can opt-out by setting the `exportConsentForm` parameter in ``ConsentView/init(header:asyncMarkdown:footer:action:givenNameField:familyNameField:exportConsentForm:)`` to `false`.
///
/// ```swift
/// ConsentView(
///     asyncMarkdown: {
///         Data("This is a *markdown* **example**".utf8)
///     },
///     action: {
///         // The action that should be performed once the user has provided their consent.
///     },
///     exportConsentForm: false  // Opt-out of the automatic export of the signed consent form as PDF to the Spezi Standard
/// )
/// ```
public struct ConsentView: View {
    public enum LocalizationDefaults {
        public static var givenName: FieldLocalizationResource {
            FieldLocalizationResource(
                title: LocalizedStringResource("NAME_FIELD_GIVEN_NAME_TITLE", bundle: .atURL(from: .module)),
                placeholder: LocalizedStringResource("NAME_FIELD_GIVEN_NAME_PLACEHOLDER", bundle: .atURL(from: .module))
            )
        }
        public static var familyName: FieldLocalizationResource {
            FieldLocalizationResource(
                title: LocalizedStringResource("NAME_FIELD_FAMILY_NAME_TITLE", bundle: .atURL(from: .module)),
                placeholder: LocalizedStringResource("NAME_FIELD_FAMILY_NAME_PLACEHOLDER", bundle: .atURL(from: .module))
            )
        }
    }
    
    public struct ExportConfiguration {
        let consentTitle: LocalizedStringResource
        let paperSize: PaperSize
        let includingTimestamp: Bool
        
        public init(
            paperSize: PaperSize = .usLetter,
            consentTitle: LocalizedStringResource? = nil,   /// As `.module` is not available in init
            includingTimestamp: Bool = true
        ) {
            self.paperSize = paperSize
            self.consentTitle = consentTitle ?? LocalizedStringResource("CONSENT_TITLE", bundle: .atURL(from: .module))
            self.includingTimestamp = includingTimestamp
        }
    }
    
    public enum ViewState: Equatable {
        case processing
        case idle
        case signed
        case export(share: Bool = false)
        case exported(PDFDocument)
        case error(ConsentRenderError)
    }
    
    public enum ConsentRenderError: LocalizedError {
        case memoryAllocationError
    }
    

    private let header: any View
    private let asyncMarkdown: (() async -> Data)
    private let footer: any View
    private let givenNameField: FieldLocalizationResource
    private let familyNameField: FieldLocalizationResource
    private let exportConfiguration: ExportConfiguration
    private let actionClosure: () async -> Void
    
    
    @EnvironmentObject private var onboardingDataSource: OnboardingDataSource
    @State private var name = PersonNameComponents()
    @State private var showSignatureView = false
    @State private var isSigning = false
    @State private var signature = PKDrawing()
    @State private var signatureSize: CGSize = .zero
    @State private var showShareSheet = false
    @State private var viewState: ViewState = .idle
    @State private var contentViewState: SpeziViews.ViewState = .idle
    
    
    private var contentView: some View {
        VStack {
            AnyView(header)
            DocumentView(
                asyncData: asyncMarkdown,
                type: .markdown,
                state: $contentViewState
            )
            AnyView(footer)
        }
    }
    
    private var actionButtons: some View {
        OnboardingActionsView(
            primaryContent: .text(LocalizedStringResource("CONSENT_ACTION", bundle: .atURL(from: .module))),
            primaryAction: {
                viewState = .export()
            },
            secondaryContent: .image("square.and.arrow.up"),
            secondaryAction: {
                viewState = .export(share: true)
            },
            layout: .horizontal(proportions: 0.8)
        )
            .disabled(actionButtonsDisabled || inputFieldsDisabled)
            .animation(.easeInOut, value: actionButtonsDisabled || inputFieldsDisabled)
    }
    
    public var body: some View {
        ScrollViewReader { proxy in // swiftlint:disable:this closure_body_length
            OnboardingView(
                contentView: {
                    contentView
                },
                actionView: {
                    VStack {
                        Divider()
                        
                        NameFields(
                            name: $name,
                            givenNameField: givenNameField,
                            familyNameField: familyNameField
                        )
                            .disabled(inputFieldsDisabled)
                        
                        if showSignatureView {
                            Divider()
                            SignatureView(signature: $signature, isSigning: $isSigning, name: name)
                                .padding(.vertical, 4)
                                .disabled(inputFieldsDisabled)
                                /// Capture the canvas size of the signature, important to export the consent form to a PDF
                                .onPreferenceChange(CanvasView.CanvasSizePreferenceKey.self) { value in
                                    signatureSize = value
                                }
                        }

                        Divider()
                        
                        actionButtons
                            .id("ActionButtons")
                            .onChange(of: showSignatureView) { _ in
                                proxy.scrollTo("ActionButtons")
                            }
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: showSignatureView)
                }
            )
            .scrollDisabled(isSigning)
            /// Based on the view state, trigger the export of the consent form
            .onChange(of: viewState) { newState in
                if case .export(let share) = newState {
                    Task { @MainActor in
                        guard let exportedConsent = await export() else {
                            viewState = .error(.memoryAllocationError)
                            return
                        }
                        
                        /// Stores the finished PDF within the Spezi `Standard`.
                        await onboardingDataSource.store(exportedConsent)
                        viewState = .exported(exportedConsent)

                        /// Show share sheet or execute the user's action closure
                        if share {
                            showShareSheet = true
                        } else {
                            await actionClosure()
                        }
                    }
                }
            }
            /// Propagates the state of the content (e.g., `SpeziViews/MarkdownView` to the ``ConsentView``
            .onChange(of: contentViewState) { newState in
                if newState == .processing {
                    viewState = .processing
                } else if newState == .idle {
                    viewState = .idle
                }
            }
            .viewStateAlert(state: $contentViewState)
            .sheet(isPresented: $showShareSheet) {
                switch viewState {
                case .exported(let consent):
                    ShareSheet(sharedItem: consent)
                        .presentationDetents([.medium])
                default:
                    EmptyView()
                }
            }
        }
    }
    
    private var inputFieldsDisabled: Bool {
        switch viewState {
        case .processing, .export(_): true  // swiftlint:disable:this empty_enum_arguments
        default: false
        }
    }
    
    private var actionButtonsDisabled: Bool {
        let showSignatureView = !(name.givenName?.isEmpty ?? true) && !(name.familyName?.isEmpty ?? true)
        if !self.showSignatureView && showSignatureView {
            Task { @MainActor in
                self.showSignatureView = showSignatureView
            }
        }
        
        if signature.strokes.isEmpty || (name.givenName?.isEmpty ?? true) || (name.familyName?.isEmpty ?? true) {
            return true
        } else {
            // As soon as form is complete, set it to signed
            Task { @MainActor in
                if viewState == .idle {
                    viewState = .signed
                }
            }
            return false
        }
    }
    
    
    /// Creates a ``ConsentView`` with a provided action view using  an``OnboardingActionsView`` and renders a markdown view.
    /// Furthermore, by default, the signed consent form is exported to the `Standard` as a PDF.
    /// - Parameters:
    ///   - header: The header view will be displayed above the markdown content.
    ///   - asyncMarkdown: The markdown content provided as an UTF8 encoded `Data` instance that can be provided asynchronously.
    ///   - footer: The footer view will be displayed above the markdown content.
    ///   - action: The action that should be performed once the consent has been given.
    ///   - givenNameField: The localization to use for the given (first) name field.
    ///   - familyNameField: The localization to use for the family (last) name field.
    ///   - exportConsentForm: Indicates weather the signed consent form should be exported as a PDF to the `Standard`. Defaults to true.
    public init(
        @ViewBuilder header: () -> some View = { EmptyView() },
        asyncMarkdown: @escaping () async -> Data,
        @ViewBuilder footer: () -> some View = { EmptyView() },
        givenNameField: FieldLocalizationResource = LocalizationDefaults.givenName,
        familyNameField: FieldLocalizationResource = LocalizationDefaults.familyName,
        exportConfiguration: ExportConfiguration = .init(),
        action: @escaping () async -> Void
    ) {
        self.header = header()
        self.asyncMarkdown = asyncMarkdown
        self.footer = footer()
        self.givenNameField = givenNameField
        self.familyNameField = familyNameField
        self.exportConfiguration = exportConfiguration
        self.actionClosure = action
    }
}


/// Extension of ``ConsentView`` enabling the export of the signed consent page in the onboarding flow.
extension ConsentView {
    /// Exports the consent form as a PDF in the specified paper size.
    ///
    /// This function retrieves the markdown content, renders it to an image, and saves it as a PDF
    /// with the provided ``ConsentView/ExportConfiguration``. The resulting PDF is stored via the Spezi `Standard`.
    /// The `Standard` must conform to the ``OnboardingConstraint``.
    ///
    /// - Returns: The exported consent form in PDF format as `PDFDocument`
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
    
    /// Creates a view representation of the consent content, ready for PDF export via SwiftUIs `ImageRenderer`.
    /// At the moment, this is
    ///
    /// This function constructs a view for presenting the markdown consent form. It combines the
    /// given markdown and the user's signature with details such as the date of export. It can be
    /// used to create exportable PDF documents of the consent form.
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
                    
                    Text(LocalizedStringResource("EXPORTED_TAG", bundle: .atURL(from: .module)))
                    + Text(": \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))")
                }
                .font(.caption)
                .padding()
            }
            
            OnboardingTitleView(title: exportConfiguration.consentTitle, paddingTop: 8)
            
            Text(markdown)
                .padding()
            
            Spacer()
            
            ZStack(alignment: .bottomLeading) {
                SignatureViewBackground(name: name, contrastBackground: false)
                
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
struct ConsentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ConsentView(
                header: {
                    OnboardingTitleView(title: "Consent", subtitle: "Version 1.0")
                },
                asyncMarkdown: {
                    Data("This is a *markdown* **example**".utf8)
                },
                action: {
                    print("Next step ...")
                }
            )
            .navigationTitle("Consent")
        }
    }
}
#endif
