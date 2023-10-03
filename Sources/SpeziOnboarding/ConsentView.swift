//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreGraphics
import PencilKit
import SpeziViews
import SwiftUI


/// The ``ConsentView`` allows the display of markdown-based documents that can be signed using a family and given name and a hand drawn signature.
///
/// The ``ConsentView`` provides a convenience initializer with a provided action view using an ``OnboardingActionsView`` (``ConsentView/init(header:asyncMarkdown:footer:action:)``)
/// or a more customized ``ConsentView/init(contentView:actionView:)`` initializer with a custom-provided content and action view.
///
/// ```swift
/// ConsentView(
///     asyncMarkdown: {
///         Data("This is a *markdown* **example**".utf8)
///     },
///     action: {
///         // The action that should be performed once the user has provided their consent.
///     }
/// )
/// ```
public struct ConsentView<ContentView: View, Action: View>: View {
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
    
    
    @EnvironmentObject private var onboardingDataSource: OnboardingDataSource

    private let contentView: ContentView
    private let action: Action
    private let givenNameField: FieldLocalizationResource
    private let familyNameField: FieldLocalizationResource
    private var exportConsentForm: Bool = false
    private var asyncMarkdown: (() async -> Data)?
    @State private var name = PersonNameComponents()
    @State private var showSignatureView = false
    @State private var isSigning = false
    @State private var signature = PKDrawing()
    @State private var signatureSize: CGSize = .zero
    
    
    public var body: some View {
        ScrollViewReader { proxy in
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
                        if showSignatureView {
                            Divider()
                            SignatureView(signature: $signature, isSigning: $isSigning, name: name)
                                .padding(.vertical, 4)
                                /// Capture the canvas size of the signature, important to export the consent form to a PDF
                                .onPreferenceChange(CanvasView.CanvasSizePreferenceKey.self, perform: { value in
                                    signatureSize = value
                                })
                        }
                        
                        Divider()
                        
                        action
                            .disabled(buttonDisabled)
                            .animation(.easeInOut, value: buttonDisabled)
                            .id("ActionButtons")
                            .onChange(of: showSignatureView) { _ in
                                proxy.scrollTo("ActionButtons")
                            }
                            /// Use `.simultaneousGesture()` to detect tap as action subview would otherwise capture the tap gesture
                            .simultaneousGesture(TapGesture().onEnded {
                                if !buttonDisabled && exportConsentForm {
                                    Task { @MainActor in
                                        await self.export()
                                    }
                                }
                            })
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: showSignatureView)
                }
            )
            .scrollDisabled(isSigning)
        }
    }
    
    var buttonDisabled: Bool {
        let showSignatureView = !(name.givenName?.isEmpty ?? true) && !(name.familyName?.isEmpty ?? true)
        if !self.showSignatureView && showSignatureView {
            Task { @MainActor in
                self.showSignatureView = showSignatureView
            }
        }
        
        return signature.strokes.isEmpty || (name.givenName?.isEmpty ?? true) || (name.familyName?.isEmpty ?? true)
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
        action: @escaping () async -> Void,
        givenNameField: FieldLocalizationResource = LocalizationDefaults.givenName,
        familyNameField: FieldLocalizationResource = LocalizationDefaults.familyName,
        exportConsentForm: Bool = true
    ) where ContentView == AnyView, Action == OnboardingActionsView {
        self.init(
            contentView: {
                AnyView(
                    VStack {
                        header()
                        DocumentView(
                            asyncData: asyncMarkdown,
                            type: .markdown
                        )
                        footer()
                    }
                )
            },
            actionView: {
                OnboardingActionsView(LocalizedStringResource("CONSENT_ACTION", bundle: .atURL(from: .module))) {
                    await action()
                }
            },
            givenNameField: givenNameField,
            familyNameField: familyNameField
        )
        
        self.asyncMarkdown = asyncMarkdown
        self.exportConsentForm = exportConsentForm
    }

    /// Creates a ``ConsentView`` with a provided action view using  an``OnboardingActionsView`` and renders HTML in a web view.
    /// - Parameters:
    ///   - header: The header view will be displayed above the html content.
    ///   - asyncHTML: The html content provided as an UTF8 encoded `Data` instance that can be provided asynchronously.
    ///   - footer: The footer view will be displayed above the html content.
    ///   - action: The action that should be performed once the consent has been given.
    ///   - givenNameField: The localization for the given name field.
    ///   - familyNameField: The localization for the family name field.
    public init(
        @ViewBuilder header: () -> some View = { EmptyView() },
        asyncHTML: @escaping () async -> Data,
        @ViewBuilder footer: () -> some View = { EmptyView() },
        action: @escaping () async -> Void,
        givenNameField: FieldLocalizationResource = LocalizationDefaults.givenName,
        familyNameField: FieldLocalizationResource = LocalizationDefaults.familyName
    ) where ContentView == AnyView, Action == OnboardingActionsView {
        self.init(
            contentView: {
                AnyView(
                    VStack {
                        header()
                        DocumentView(
                            asyncData: asyncHTML,
                            type: .html
                        )
                        footer()
                    }
                )
            },
            actionView: {
                OnboardingActionsView(LocalizedStringResource("CONSENT_ACTION", bundle: .atURL(from: .module))) {
                    await action()
                }
            },
            givenNameField: givenNameField,
            familyNameField: familyNameField
        )
    }

    /// Creates a ``ConsentView`` with a custom-provided action view.
    /// - Parameters:
    ///   - contentView: The content view providing context about the consent view.
    ///   - actionView: The action view that should be displayed under the name and signature boxes.
    ///   - givenNameField: The localization to use for the given (first) name field.
    ///   - familyNameField: The localization to use for the family (last) name field.
    public init(
        @ViewBuilder contentView: () -> ContentView,
        @ViewBuilder actionView: () -> Action,
        givenNameField: FieldLocalizationResource = LocalizationDefaults.givenName,
        familyNameField: FieldLocalizationResource = LocalizationDefaults.familyName
    ) {
        self.contentView = contentView()
        self.action = actionView()
        self.givenNameField = givenNameField
        self.familyNameField = familyNameField
    }
}


/// Extension of ``ConsentView`` enabling the export of the signed consent page in the onboarding flow.
private extension ConsentView {
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
    func exportBody(markdown: AttributedString) -> some View {
        VStack {
            HStack {
                Spacer()
                
                Text("Exported: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))")
                    .font(.caption)
            }
            .padding()
            
            Text("Spezi Consent")
                .font(.title)
            
            Text(markdown)
                .padding()
            
            Spacer()
            
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                Text("X")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30 + 2)
                Text(name.formatted(.name(style: .long)))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30 - 18)
                Image(uiImage: signature.image(from: .init(x: 0, y: 0, width: signatureSize.width, height: signatureSize.height), scale: UIScreen.main.scale))
            }
            .frame(width: signatureSize.width, height: signatureSize.height)
        }
    }
    
    
    /// Exports the consent form as a PDF in the specified paper size.
    ///
    /// This function retrieves the markdown content, renders it to an image, and saves it as a PDF
    /// with the provided paper size. The resulting PDF is stored via the Spezi `Standard`.
    /// The `Standard` must conform to the ``OnboardingConstraint``.
    ///
    /// - Parameter paperSize: The desired size for the exported PDF, defaulting to `.usLetter`.
    func export(paperSize: PaperSize = .usLetter) async {
        guard let asyncMarkdown else {
            preconditionFailure("SpeziOnboarding: Consent form export is only supported for Markdown documents!")
        }
        
        let markdown = await asyncMarkdown()
        
        let markdownString = (try? AttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(String(localized: "MARKDOWN_LOADING_ERROR", bundle: .module))
        
        let renderer = ImageRenderer(content: exportBody(markdown: markdownString))
        let paperSize = CGSize(
            width: paperSize.dimensions.width,
            height: paperSize.dimensions.height
        )
        renderer.proposedSize = .init(paperSize)
        
        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: paperSize)
            
            /// Creates the `CGContext` that stores the to-be-rendered PDF in-memory as a Swift `Data` struct.
            guard let mutableData = CFDataCreateMutable(kCFAllocatorDefault, 0),
                  let consumer = CGDataConsumer(data: mutableData),
                  let pdf = CGContext(consumer: consumer, mediaBox: &box, nil) else {
                return
            }
            
            pdf.beginPDFPage(nil)
            pdf.translateBy(
                x: 0,
                y: 0
            )
            
            context(pdf)
            
            pdf.endPDFPage()
            pdf.closePDF()
            
            /// Stores the finished PDF within the Spezi `Standard`.
            onboardingDataSource.store(mutableData as Data)
        }
    }
}


#if DEBUG
struct ConsentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ConsentView(
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
