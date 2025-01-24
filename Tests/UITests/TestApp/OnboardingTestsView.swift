//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SpeziViews
import SwiftUI


struct OnboardingTestsView: View {
    @Binding var onboardingFlowComplete: Bool
    @State var showConditionalView = false


    var body: some View {
        OnboardingStack(onboardingFlowComplete: $onboardingFlowComplete) {
            OnboardingStartTestView(
                showConditionalView: $showConditionalView
            )
            OnboardingWelcomeTestView()
            OnboardingSequentialTestView()

            OnboardingConsentMarkdownTestView(
                consentTitle: "First Consent",
                consentText: "This is the first *markdown* **example**",
                documentIdentifier: DocumentIdentifiers.first
            )

            OnboardingConsentMarkdownRenderingView(
                consentTitle: "First Consent",
                documentIdentifier: DocumentIdentifiers.first
            )

            OnboardingConsentMarkdownTestView(
                consentTitle: "Second Consent",
                consentText: "This is the second *markdown* **example**",
                documentIdentifier: DocumentIdentifiers.second
            )
                .onboardingIdentifier(DocumentIdentifiers.second)
            OnboardingConsentMarkdownRenderingView(
                consentTitle: "Second Consent",
                documentIdentifier: DocumentIdentifiers.second
            )
                .onboardingIdentifier("\(DocumentIdentifiers.second)_rendering")

            OnboardingTestViewNotIdentifiable(text: "Leland").onboardingIdentifier("a")
            OnboardingTestViewNotIdentifiable(text: "Stanford").onboardingIdentifier("b")
            OnboardingCustomToggleTestView(showConditionalView: $showConditionalView)

            if showConditionalView {
                OnboardingConditionalTestView()
            }
        }
    }
}


#if DEBUG
#Preview {
    OnboardingTestsView(onboardingFlowComplete: .constant(false))
}
#endif
