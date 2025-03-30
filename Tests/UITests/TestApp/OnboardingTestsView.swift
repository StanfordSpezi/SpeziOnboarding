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
        ManagedNavigationStack(didComplete: $onboardingFlowComplete) {
            OnboardingStartTestView(
                showConditionalView: $showConditionalView
            )
            OnboardingWelcomeTestView()
            OnboardingSequentialTestView()

            OnboardingConsentTestView(
                consentTitle: "First Consent",
                consentText: "This is the first *markdown* **example**",
                documentIdentifier: ConsentDocumentIdentifiers.first
            )
            
            OnboardingConsentFinishedRenderedView(
                consentTitle: "First Consent",
                documentIdentifier: ConsentDocumentIdentifiers.first
            )
            
            OnboardingConsentTestView(
                consentTitle: "Second Consent",
                consentText: "This is the second *markdown* **example**",
                documentIdentifier: ConsentDocumentIdentifiers.second
            )
                .navigationStepIdentifier(ConsentDocumentIdentifiers.second)
            OnboardingConsentFinishedRenderedView(
                consentTitle: "Second Consent",
                documentIdentifier: ConsentDocumentIdentifiers.second
            )
                .navigationStepIdentifier("\(ConsentDocumentIdentifiers.second)_rendering")
            
            OnboardingTestViewNotIdentifiable(text: "Leland")
                .navigationStepIdentifier("a")
            OnboardingTestViewNotIdentifiable(text: "Stanford")
                .navigationStepIdentifier("b")
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
