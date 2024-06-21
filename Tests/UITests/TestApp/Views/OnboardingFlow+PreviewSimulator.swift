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
            OnboardingConsentMarkdownTestView1(),
            OnboardingConsentMarkdownRenderingView1(),
            OnboardingConsentMarkdownTestView2(),
            OnboardingConsentMarkdownRenderingView2(),
            OnboardingCustomTestView1(exampleArgument: "test"),
            OnboardingCustomTestView2(),
            OnboardingConditionalTestView()
        ]
    }()
}
