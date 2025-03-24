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
import SpeziViews
import SwiftUI

/// Onboarding view to display markdown-based consent documents that can be signed and exported.
///
/// The ``OnboardingConsentView`` provides a convenient onboarding `View` for the display of markdown-based documents that can be
/// signed using a family and given name and a hand drawn signature.
///
/// Furthermore, the `View` includes an export functionality, enabling users to share and store the signed consent form.
/// The exported consent form PDF is received via the `action` closure on the ``OnboardingConsentView/init(markdown:action:title:currentDateInSignature:exportConfiguration:)``.
///
/// The ``OnboardingConsentView`` builds on top of the SpeziOnboarding ``ConsentDocument``
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
    private let initialNameComponents: PersonNameComponents?
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
                        initialNameComponents: initialNameComponents,
                        consentSignatureDate: currentDateInSignature ? .now : nil
                    )
                    .padding(.bottom)
                },
                actionView: {
                    Button(
                        action: {
                            withAnimation(.easeOut(duration: 0.2)) {
                                viewState = .export     // Triggers the export process
                            }
                        },
                        label: {
                            Text("CONSENT_ACTION", bundle: .module)
                                .frame(maxWidth: .infinity, minHeight: 38)
                                .processingOverlay(isProcessing: backButtonHidden)
                        }
                    )
                        .buttonStyle(.borderedProminent)
                        .disabled(!actionButtonsEnabled)
                        .animation(.easeInOut(duration: 0.2), value: actionButtonsEnabled)
                        .id("ActionButton")
                }
            )
            .scrollDisabled($viewState.signing.wrappedValue)
            .navigationBarBackButtonHidden(backButtonHidden)
            .task(id: viewState) {
                if case .exported(let consentExport) = viewState {
                    if !willShowShareSheet {
                        do {
                            // Pass the rendered consent form to the `action` closure
                            nonisolated(unsafe) let pdf = try consentExport.render()
                            try await action(pdf)

                            withAnimation(.easeIn(duration: 0.2)) {
                                self.viewState = .base(.idle)
                            }
                        } catch {
                            withAnimation(.easeIn(duration: 0.2)) {
                                // In case of error, go back to previous state.
                                self.viewState = .base(.error(AnyLocalizedError(error: error)))
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
                            .onDisappear {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    self.viewState = .signed
                                }
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
                        .task {
                            // This is required as only the "Markup" action from the ShareSheet misses to dismiss the share sheet again
                            if !willShowShareSheet {
                                showShareSheet = false
                            }
                        }
                }
            }
            #if os(macOS)
            .onChange(of: showShareSheet) { _, isPresented in
                if isPresented,
                   case .exported(let exportedConsent) = viewState {
                    if let consentPdf = try? exportedConsent.render() {
                        let shareSheet = ShareSheet(sharedItem: consentPdf)
                        shareSheet.show()

                        willShowShareSheet = false
                        showShareSheet = false

                        withAnimation(.easeIn(duration: 0.2)) {
                            self.viewState = .signed
                        }
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
        let exportStates = switch viewState {
        case .export, .exported: true
        default: false
        }
        
        return exportStates && !willShowShareSheet
    }

    private var actionButtonsEnabled: Bool {
        switch viewState {
        case .signing, .signed: true
        default: false
        }
    }
    
    
    /// Creates an `OnboardingConsentView` which provides a convenient onboarding view for visualizing, signing, and exporting a consent form.
    /// - Parameters:
    ///   - markdown: The markdown content provided as an UTF8 encoded `Data` instance that can be provided asynchronously.
    ///   - action: The action that should be performed once the consent is given. Action is called with the exported consent document as a parameter.
    ///   - title: The title of the view displayed at the top. Can be `nil`, meaning no title is displayed.
    ///   - initialNameComponents: Allows prefilling the first and last name fields in the consent document.
    ///   - currentDateInSignature: Indicates if the consent document should include the current date in the signature field. Defaults to `true`.
    ///   - exportConfiguration: Defines the properties of the exported consent form via ``ConsentDocumentExportRepresentation/Configuration``.
    public init(
        markdown: @escaping () async -> Data,
        action: @escaping (_ document: PDFDocument) async throws -> Void,
        title: LocalizedStringResource? = LocalizationDefaults.consentFormTitle,
        initialNameComponents: PersonNameComponents? = nil,
        currentDateInSignature: Bool = true,
        exportConfiguration: ConsentDocumentExportRepresentation.Configuration = .init()
    ) {
        self.markdown = markdown
        self.action = action
        self.title = title
        self.initialNameComponents = initialNameComponents
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
