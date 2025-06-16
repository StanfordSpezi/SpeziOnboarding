//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziConsent
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct OnboardingStartTestView: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    @Binding var showConditionalView: Bool
    
    var body: some View {
        let consentFileUrl = Bundle.main.url(forResource: "Consent", withExtension: "md")! // swiftlint:disable:this force_unwrapping
        Form { // swiftlint:disable:this closure_body_length
            Button("Welcome View") {
                path.navigateToNextStep(
                    matching: .viewType(OnboardingWelcomeTestView.self),
                    includeIntermediateSteps: false
                )
            }
            Button("Sequential Onboarding") {
                path.navigateToNextStep(
                    matching: .viewType(OnboardingSequentialTestView.self),
                    includeIntermediateSteps: false
                )
            }
            Button("Consent View (Markdown)") {
                path.navigateToNextStep(
                    matching: .viewType(OnboardingConsentTestView.self),
                    includeIntermediateSteps: false
                )
            }
            Button("Rendered Consent View (Markdown)") {
                path.navigateToNextStep(
                    matching: .viewType(OnboardingConsentFinishedRenderedView.self),
                    includeIntermediateSteps: false
                )
            }
            Button("Complex Consent View") {
                path.append(
                    customView: Consent(url: consentFileUrl)
                )
            }
            Button("Custom Onboarding View 1") {
                path.append(
                    customView: OnboardingCustomTestView1(exampleArgument: "Hello Spezi!")
                )
            }
            Button("Custom Onboarding View 2") {
                path.append(customView: OnboardingCustomTestView2())
            }
            Button("Onboarding Identifiable View") {
                path.append(customView: OnboardingIdentifiableTestViewCustom(id: "ID: 1"))
            }
            /// We need to use a custom-built toggle as UI tests are very flakey when clicking on SwiftUI `Toggle`'s
            CustomToggleView(
                text: "Show Conditional View",
                condition: $showConditionalView
            )
        }
    }
}
