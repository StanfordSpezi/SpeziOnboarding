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


struct OnboardingStartTestView: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    @Binding var showConditionalView: Bool
    
    var body: some View {
        Form {
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
