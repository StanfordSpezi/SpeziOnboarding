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
                documentIdentifier: ConsentDocumentIdentifier.first
            )
            OnboardingConsentMarkdownRenderingView(
                consentTitle: "First Consent",
                documentIdentifier: ConsentDocumentIdentifier.first
            )

            OnboardingConsentMarkdownTestView(
                consentTitle: "Second Consent",
                consentText: "This is the second *markdown* **example**",
                documentIdentifier: ConsentDocumentIdentifier.second
            )
                .onboardingIdentifier(ConsentDocumentIdentifier.second)
            OnboardingConsentMarkdownRenderingView(
                consentTitle: "Second Consent",
                documentIdentifier: ConsentDocumentIdentifier.second
            )
                .onboardingIdentifier("\(ConsentDocumentIdentifier.second)_rendering")

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
struct OnboardingTestsView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTestsView(onboardingFlowComplete: .constant(false))
    }
}
#endif
