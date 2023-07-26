//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


@main
struct UITestsApp: App {
    @State var onboardingFlowComplete = false
    
    var body: some Scene {
        WindowGroup {
            if !onboardingFlowComplete {
                OnboardingTestsView(onboardingFlowComplete: $onboardingFlowComplete)
            } else {
                Text("Onboarding complete")
            }
        }
    }
}
