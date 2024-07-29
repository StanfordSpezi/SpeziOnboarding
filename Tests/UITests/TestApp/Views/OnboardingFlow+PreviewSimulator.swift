//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Defines onboarding views that are shown in the Xcode preview simulator
enum OnboardingFlow {
    @MainActor static let previewSimulatorViews: [any View] = {
        [
            OnboardingStartTestView(showConditionalView: .constant(true)),
            OnboardingWelcomeTestView(),
            OnboardingSequentialTestView(),

            OnboardingConsentMarkdownTestView(
                consentTitle: "Consent Document",
                consentText: "This is the first *markdown* **example**",
                documentIdentifier: ConsentDocumentIdentifier.first
            ),
            OnboardingConsentMarkdownRenderingView(
                consentTitle: "Consent Document",
                documentIdentifier: ConsentDocumentIdentifier.first
            ),

            OnboardingConsentMarkdownTestView(
                consentTitle: "Consent Document",
                consentText: "This is the second *markdown* **example**",
                documentIdentifier: ConsentDocumentIdentifier.second
            )
                .onboardingIdentifier(ConsentDocumentIdentifier.second),
            OnboardingConsentMarkdownRenderingView(
                consentTitle: "Consent Document",
                documentIdentifier: ConsentDocumentIdentifier.second
            )
                .onboardingIdentifier("\(ConsentDocumentIdentifier.second)_rendering"),

            OnboardingCustomTestView1(exampleArgument: "test"),
            OnboardingCustomTestView2(),
            OnboardingConditionalTestView()
        ]
    }()
}
