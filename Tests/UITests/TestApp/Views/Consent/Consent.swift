//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziConsent
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct Consent: View {
    let url: URL
    
    @Environment(ManagedNavigationStack.Path.self) private var path
    
    @State private var consentDocument: ConsentDocument?
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        OnboardingConsentView(consentDocument: consentDocument, viewState: $viewState) {
            path.nextStep()
        }
        .viewStateAlert(state: $viewState)
        .scrollIndicators(.visible)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ConsentShareButton(
                    consentDocument: consentDocument,
                    viewState: $viewState
                )
            }
        }
        .task {
            do {
                consentDocument = try ConsentDocument(contentsOf: url)
            } catch {
                viewState = .error(AnyLocalizedError(error: error))
            }
        }
    }
}
