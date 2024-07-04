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
            ).onboardingIdentifier("consent1"),
            OnboardingConsentMarkdownRenderingView(
                consentTitle: "Consent Document",
                documentIdentifier: ConsentDocumentIdentifier.second
            ).onboardingIdentifier("consent_rendering1"),
            OnboardingConsentMarkdownTestView(
                consentTitle: "Consent Document",
                consentText: "This is the second *markdown* **example**",
                documentIdentifier: ConsentDocumentIdentifier.first
            ).onboardingIdentifier("consent2"),
            OnboardingConsentMarkdownRenderingView(
                consentTitle: "Consent Document",
                documentIdentifier: ConsentDocumentIdentifier.second
            ).onboardingIdentifier("consent_rendering2"),
            OnboardingCustomTestView1(exampleArgument: "test"),
            OnboardingCustomTestView2(),
            OnboardingConditionalTestView()
        ]
    }()
}
