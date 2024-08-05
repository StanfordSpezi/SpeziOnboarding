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
import SpeziViews
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
/// If you want to use multiple `OnboardingConsentView`, you can provide each with an identifier (see below).
/// The identifier allows to distinguish the consent forms in the `Standard`.
/// Any identifier is a string. We recommend storing and grouping consent document identifiers in an enum:
/// ```swift
/// enum DocumentIdentifiers {
///     static let first = ConsentDocumentIdentifier("firstConsentDocument")
///     static let second = ConsentDocumentIdentifier("secondConsentDocument")
/// }
/// ```
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
///     identifier: DocumentIdentifiers.first, // Specify a unique identifier of type ``ConsentDocumentIdentifier``, preferably
///                                                  // bundled in an enum (see above). Only relevant if more than one OnboardingConsentView is needed.
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
    private let identifier: ConsentDocumentIdentifier
    private let exportConfiguration: ConsentDocument.ExportConfiguration
    private var backButtonHidden: Bool {
        viewState == .storing || (viewState == .export && !willShowShareSheet)
    }

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
                if case .exported(let exportedConsentDocumented) = viewState {
                    if !willShowShareSheet {
                        viewState = .storing
                        Task {
                            do {
                                let documentExport = ConsentDocumentExport(
                                    documentIdentifier: identifier,
                                    cachedPDF: exportedConsentDocumented
                                )
                                
                                /// Stores the finished PDF in the Spezi `Standard`.
                                try await onboardingDataSource.store(
                                   documentExport
                                )

                                await action()
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
        case .signing, .signed, .exported: true
        default: false
        }
    }
    
    
    /// Creates an `OnboardingConsentView` which provides a convenient onboarding view for visualizing, signing, and exporting a consent form.
    /// - Parameters:
    ///   - markdown: The markdown content provided as an UTF8 encoded `Data` instance that can be provided asynchronously.
    ///   - action: The action that should be performed once the consent is given.
    ///   - title: The title of the view displayed at the top. Can be `nil`, meaning no title is displayed.
    ///   - identifier: A unique identifier or "name" for the consent form, helpful for distinguishing consent forms when storing in the `Standard`.
    ///   - exportConfiguration: Defines the properties of the exported consent form via ``ConsentDocument/ExportConfiguration``.
    public init(
        markdown: @escaping () async -> Data,
        action: @escaping () async -> Void,
        title: LocalizedStringResource? = LocalizationDefaults.consentFormTitle,
        identifier: ConsentDocumentIdentifier = ConsentDocumentIdentifier("ConsentDocument"),
        exportConfiguration: ConsentDocument.ExportConfiguration = .init()
    ) {
        self.markdown = markdown
        self.exportConfiguration = exportConfiguration
        self.title = title
        self.action = action
        self.identifier = identifier
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
