//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// The ``OnboardingConsentView`` provides a convenient onboarding view for the display of
/// markdown-based documents that can be signed using a family and given name and a hand drawn
/// signature. Furthermore, the view includes an export functionality, enabling users to share and store the
/// signed consent form. 
/// The exported consent form is automatically stored in the Spezi `Standard`, requiring the `Standard`
/// to conform to the ``OnboardingConstraint``.
///
/// The ``OnboardingConsentView`` builds on top of the SpeziOnboarding ``ConsentDocument`` but provides a more developer friendly, convenient API with additional functionalities like the share consent option.
///
///
/// ```swift
/// ConsentView(
///     markdown: {
///         Data("This is a *markdown* **example**".utf8)
///     },
///     action: {
///         // The action that should be performed once the user has provided their consent.
///     },
///     exportConfiguration: .init(paperSize: .usLetter)   // Configure the properties of the exported consent form
/// )
/// ```
public struct OnboardingConsentView: View {
    private let markdown: (() async -> Data)
    private let action: (() async -> Void)
    private let exportConfiguration: ConsentDocument.ExportConfiguration
    
    @EnvironmentObject private var onboardingDataSource: OnboardingDataSource
    @State private var consentViewState: ConsentDocument.ConsentViewState = .base(.idle)
    @State private var showShareSheet = false
    @State private var disableScrolling = false
    
    
    public var body: some View {
        OnboardingView(
            titleView: {
                OnboardingTitleView(
                    title: LocalizedStringResource("CONSENT_VIEW_TITLE", bundle: .atURL(from: .module))
                )
            },
            contentView: {
                ConsentDocument(
                    markdown: markdown,
                    viewState: $consentViewState,
                    exportConfiguration: exportConfiguration
                )
                    .padding(.bottom)
            },
            actionView: {
                OnboardingActionsView(
                    LocalizedStringResource("CONSENT_ACTION", bundle: .atURL(from: .module)),
                    action: {
                        consentViewState = .export
                    }
                )
                    .disabled(!actionButtonsEnabled)
                    .animation(.easeInOut, value: actionButtonsEnabled)
                    // TODO: Is .scrollTo possible here? i dont think so (also via view state tricky) - Is it actually needed?
            }
        )
        .scrollDisabled(disableScrolling)
        .onChange(of: consentViewState) { newState in
            if case .exported(let exportedConsentDocumented) = newState {
                if !showShareSheet {
                    Task { @MainActor in
                        /// Stores the finished PDF within the Spezi `Standard`.
                        await onboardingDataSource.store(exportedConsentDocumented)
                        await action()
                    }
                }
            } else if case .signing = newState {
                disableScrolling = true
            } else {
                disableScrolling = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    consentViewState = .export
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .opacity(actionButtonsEnabled ? 1.0 : 0.0)
                        .scaleEffect(actionButtonsEnabled ? 1.0 : 0.8)
                        .animation(.easeInOut, value: actionButtonsEnabled)
                        .disabled(!actionButtonsEnabled)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            switch consentViewState {
            case .exported(let exportedConsentDocumented):
                ShareSheet(sharedItem: exportedConsentDocumented)
                    .presentationDetents([.medium])
            default:
                ProgressView()
                    .padding()
            }
        }
    }
    
    var actionButtonsEnabled: Bool {
        switch consentViewState {
        case .signing, .signed, .export, .exported: true
        default: false
        }
    }
    
    
    /// Creates an ``OnboardingConsentView`` which provides a convenient onboarding view for visualizing, signing, and exporting a consent form.
    /// - Parameters:
    ///   - markdown: The markdown content provided as an UTF8 encoded `Data` instance that can be provided asynchronously.
    ///   - action: The action that should be performed once the consent is given.
    ///   - exportConfiguration: Defines the properties of the exported consent form via ``ConsentDocument/ExportConfiguration``.
    public init(
        markdown: @escaping () async -> Data,
        action: @escaping () async -> Void,
        exportConfiguration: ConsentDocument.ExportConfiguration = .init()
    ) {
        self.markdown = markdown
        self.exportConfiguration = exportConfiguration
        self.action = action
    }
}


#if DEBUG
struct OnboardingConsentView_Previews: PreviewProvider {
    @State static var viewState: ConsentDocument.ConsentViewState = .base(.idle)
    
    
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
