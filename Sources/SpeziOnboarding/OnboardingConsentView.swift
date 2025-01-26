//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if os(macOS)
import AppKit
#endif

import Foundation
import PDFKit
import Spezi
import SpeziFoundation
import SpeziViews
import SwiftUI

/// Onboarding view to display markdown-based consent documents that can be signed and exported.
///
/// The `OnboardingConsentView` provides a convenient onboarding view for the display of markdown-based documents that can be
/// signed using a family and given name and a hand drawn signature.
///
/// Furthermore, the view includes an export functionality, enabling users to share and store the signed consent form.
/// The exported consent form PDF is received via the `action` closure on the ``OnboardingConsentView/init(markdown:action:title:currentDateInSignature:exportConfiguration:)``.
///
/// The `OnboardingConsentView` builds on top of the SpeziOnboarding ``ConsentDocument`` 
/// by providing a more developer-friendly, convenient API with additional functionalities like the share consent option.
///
/// ```swift
/// OnboardingConsentView(
///     markdown: {
///         Data("This is a *markdown* **example**".utf8)
///     },
///     action: { exportedConsentPdf in
///         // The action that should be performed once the user has provided their consent.
///         // Closure receives the exported consent PDF to persist or upload it.
///     },
///     title: "Consent",   // Configure the title of the consent view
///     exportConfiguration: .init(paperSize: .usLetter),   // Configure the properties of the exported consent form
///     currentDateInSignature: true   // Indicates if the consent signature should include the current date
/// )
/// ```
public struct OnboardingConsentView: View {
    /// Provides default localization values for necessary fields in the ``OnboardingConsentView``.
    public enum LocalizationDefaults {
        /// Default localized value for the title of the consent form.
        public static var consentFormTitle: LocalizedStringResource {
            LocalizedStringResource("CONSENT_VIEW_TITLE", bundle: .atURL(from: .module))
        }
    }
        
    private let markdown: () async -> Data
    private let action: (_ document: PDFDocument) async throws -> Void
    private let title: LocalizedStringResource?
    private let currentDateInSignature: Bool
    private let exportConfiguration: ConsentDocumentExportRepresentation.Configuration
    
    @State private var viewState: ConsentViewState = .base(.idle)
    @State private var willShowShareSheet = false
    @State private var showShareSheet = false

    
    public var body: some View {
        ScrollViewReader { proxy in // swiftlint:disable:this closure_body_length
            OnboardingView(
                titleView: {
                    if let title {
                        OnboardingTitleView(
                            title: title
                        )
                    }
                },
                contentView: {
                    ConsentDocument(
                        markdown: markdown,
                        viewState: $viewState,
                        exportConfiguration: exportConfiguration,
                        consentSignatureDate: currentDateInSignature ? .now : nil
                    )
                    .padding(.bottom)
                },
                actionView: {
                    Button(
                        action: {
                            viewState = .export
                        },
                        label: {
                            Text("CONSENT_ACTION", bundle: .module)
                                .frame(maxWidth: .infinity, minHeight: 38)
                                .processingOverlay(isProcessing: viewState == .storing || (viewState == .export && !willShowShareSheet))
                        }
                    )
                        .buttonStyle(.borderedProminent)
                        .disabled(!actionButtonsEnabled)
                        .animation(.easeInOut, value: actionButtonsEnabled)
                        .id("ActionButton")
                }
            )
            .scrollDisabled($viewState.signing.wrappedValue)
            .navigationBarBackButtonHidden(backButtonHidden)
            .onChange(of: viewState) {
                if case .exported(let consentExport) = viewState {
                    if !willShowShareSheet {
                        viewState = .storing

                        Task {
                            do {
                                // Calls the passed `action` closure with the rendered consent PDF.
                                try await action(consentExport.render())
                                viewState = .base(.idle)
                            } catch {
                                // In case of error, go back to previous state.
                                viewState = .base(.error(AnyLocalizedError(error: error)))
                            }
                        }
                    } else {
                        showShareSheet = true
                    }
                } else if case .namesEntered = viewState {
                    proxy.scrollTo("ActionButton")
                }
            }
        }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(
                        action: {
                            viewState = .export
                            willShowShareSheet = true
                        },
                        label: {
                            if willShowShareSheet {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            } else {
                                Label {
                                    Text("CONSENT_SHARE", bundle: .module)
                                } icon: {
                                    Image(systemName: "square.and.arrow.up")
                                        .accessibilityHidden(true)
                                }
                            }
                        }
                    )
                        .disabled(!actionButtonsEnabled || willShowShareSheet)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if case .exported(let exportedConsent) = viewState {
                    if let consentPdf = try? exportedConsent.render() {
                        #if !os(macOS)
                        ShareSheet(sharedItem: consentPdf)
                            .presentationDetents([.medium])
                            .task {
                                willShowShareSheet = false
                            }
                        #endif
                    } else {
                        ProgressView()
                            .padding()
                            .task {
                                viewState = .base(.error(Error.consentExportError))
                            }
                    }
                } else {
                    ProgressView()
                        .padding()
                }
            }
            #if os(macOS)
            .onChange(of: showShareSheet) { _, isPresented in
                if isPresented,
                   case .exported(let exportedConsent) = viewState {
                    if let consentPdf = try? exportedConsent.render() {
                        let shareSheet = ShareSheet(sharedItem: consentPdf)
                        shareSheet.show()

                        showShareSheet = false
                    } else {
                        viewState = .base(.error(Error.consentExportError))
                    }
                }
            }
            
            // `NSSharingServicePicker` doesn't provide a completion handler as `UIActivityViewController` does,
            // therefore necessitating the deletion of the temporary file on disappearing.
            .onDisappear {
                try? FileManager.default.removeItem(
                    at: FileManager.default.temporaryDirectory.appendingPathComponent(
                        LocalizedStringResource("FILE_NAME_EXPORTED_CONSENT_FORM", bundle: .atURL(from: .module)).localizedString() + ".pdf"
                    )
                )
            }
            #endif
    }

    private var backButtonHidden: Bool {
        viewState == .storing || (viewState == .export && !willShowShareSheet)
    }

    private var actionButtonsEnabled: Bool {
        switch viewState {
        case .signing, .signed, .exported: true
        default: false
        }
    }
    
    
    /// Creates an `OnboardingConsentView` which provides a convenient onboarding view for visualizing, signing, and exporting a consent form.
    /// - Parameters:
    ///   - markdown: The markdown content provided as an UTF8 encoded `Data` instance that can be provided asynchronously.
    ///   - action: The action that should be performed once the consent is given. Action is called with the exported consent document as a parameter.
    ///   - title: The title of the view displayed at the top. Can be `nil`, meaning no title is displayed.
    ///   - currentDateInSignature: Indicates if the consent document should include the current date in the signature field. Defaults to `true`.
    ///   - exportConfiguration: Defines the properties of the exported consent form via ``ConsentDocumentExportRepresentation/Configuration``.
    public init(
        markdown: @escaping () async -> Data,
        action: @escaping (_ document: PDFDocument) async throws -> Void,
        title: LocalizedStringResource? = LocalizationDefaults.consentFormTitle,
        currentDateInSignature: Bool = true,
        exportConfiguration: ConsentDocumentExportRepresentation.Configuration = .init()
    ) {
        self.markdown = markdown
        self.action = action
        self.title = title
        self.currentDateInSignature = currentDateInSignature
        self.exportConfiguration = exportConfiguration
    }
}


#if DEBUG
#Preview {
    @Previewable @State var viewState: ConsentViewState = .base(.idle)


    NavigationStack {
        OnboardingConsentView(markdown: {
            Data("This is a *markdown* **example**".utf8)
        }, action: { _ in
            print("Next")
        })
    }
}
#endif
