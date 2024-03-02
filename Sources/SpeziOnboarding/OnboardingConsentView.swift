//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// Onboarding view to display markdown-based consent documents that can be signed and exported.
///
/// The `OnboardingConsentView` provides a convenient onboarding view for the display of markdown-based documents that can be
/// signed using a family and given name and a hand drawn signature.
///
/// Furthermore, the view includes an export functionality, enabling users to share and store the signed consent form.
/// The exported consent form is automatically stored in the Spezi `Standard`, requiring the `Standard` to conform to the ``OnboardingConstraint``.
///
/// The `OnboardingConsentView` builds on top of the SpeziOnboarding ``ConsentDocument`` 
/// by providing a more developer-friendly, convenient API with additional functionalities like the share consent option.
///
/// ```swift
/// OnboardingConsentView(
///     markdown: {
///         Data("This is a *markdown* **example**".utf8)
///     },
///     action: {
///         // The action that should be performed once the user has provided their consent.
///     },
///     title: "Consent",   // Configure the title of the consent view
///     exportConfiguration: .init(paperSize: .usLetter)   // Configure the properties of the exported consent form
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
    private let action: () async -> Void
    private let title: LocalizedStringResource?
    private let exportConfiguration: ConsentDocument.ExportConfiguration
    
    @Environment(OnboardingDataSource.self) private var onboardingDataSource
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
                        exportConfiguration: exportConfiguration
                    )
                    .padding(.bottom)
                },
                actionView: {
                    OnboardingActionsView(
                        LocalizedStringResource("CONSENT_ACTION", bundle: .atURL(from: .module)),
                        action: {
                            viewState = .export
                        }
                    )
                        .disabled(!actionButtonsEnabled)
                        .animation(.easeInOut, value: actionButtonsEnabled)
                        .id("ActionButton")
                }
            )
            .scrollDisabled($viewState.signing.wrappedValue)
            .onChange(of: viewState) {
                if case .exported(let exportedConsentDocumented) = viewState {
                    if !willShowShareSheet {
                        Task { @MainActor in
                            /// Stores the finished PDF in the Spezi `Standard`.
                            await onboardingDataSource.store(exportedConsentDocumented)
                            await action()
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
                    Button(action: {
                        viewState = .export
                        willShowShareSheet = true
                    }) {
                        Label {
                            Text("CONSENT_SHARE", bundle: .module)
                        } icon: {
                            Image(systemName: "square.and.arrow.up")
                                .accessibilityHidden(true)
                        }
                    }
                        .disabled(!actionButtonsEnabled)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if case .exported(let exportedConsentDocumented) = viewState {
                    #if !os(macOS)
                    ShareSheet(sharedItem: exportedConsentDocumented)
                        .presentationDetents([.medium])
                        .task {
                            willShowShareSheet = false
                        }
                    #endif
                } else {
                    ProgressView()
                        .padding()
                }
            }
            #if os(macOS)
            .onChange(of: showShareSheet) { _, isPresented in
                if isPresented,
                   case .exported(let exportedConsentDocumented) = viewState {
                    let shareSheet = ShareSheet(sharedItem: exportedConsentDocumented)
                    shareSheet.show()

                    showShareSheet = false
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
    
    private var actionButtonsEnabled: Bool {
        switch viewState {
        case .signing, .signed, .export, .exported: true
        default: false
        }
    }
    
    
    /// Creates an `OnboardingConsentView` which provides a convenient onboarding view for visualizing, signing, and exporting a consent form.
    /// - Parameters:
    ///   - markdown: The markdown content provided as an UTF8 encoded `Data` instance that can be provided asynchronously.
    ///   - action: The action that should be performed once the consent is given.
    ///   - title: The title of the view displayed at the top. Can be `nil`, meaning no title is displayed.
    ///   - exportConfiguration: Defines the properties of the exported consent form via ``ConsentDocument/ExportConfiguration``.
    public init(
        markdown: @escaping () async -> Data,
        action: @escaping () async -> Void,
        title: LocalizedStringResource? = LocalizationDefaults.consentFormTitle,
        exportConfiguration: ConsentDocument.ExportConfiguration = .init()
    ) {
        self.markdown = markdown
        self.exportConfiguration = exportConfiguration
        self.title = title
        self.action = action
    }
}


#if DEBUG
struct OnboardingConsentView_Previews: PreviewProvider {
    @State private static var viewState: ConsentViewState = .base(.idle)
    
    
    static var previews: some View {
        NavigationStack {
            OnboardingConsentView(markdown: {
                Data("This is a *markdown* **example**".utf8)
            }, action: {
                print("Next")
            })
        }
    }
}
#endif
