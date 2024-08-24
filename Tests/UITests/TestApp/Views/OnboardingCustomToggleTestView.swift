//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI

struct OnboardingCustomToggleTestView: View {
    @Environment(OnboardingNavigationPath.self) private var path
    @Binding var showConditionalView: Bool

    var body: some View {
        VStack(spacing: 12) {
            Button {
                path.nextStep()
            } label: {
                Text("Next")
            }

            /// We need to use a custom-built toggle as UI tests are very flakey when clicking on SwiftUI `Toggle`'s
            CustomToggleView(
                text: "Show Conditional View",
                condition: $showConditionalView
            )
        }
    }
}
