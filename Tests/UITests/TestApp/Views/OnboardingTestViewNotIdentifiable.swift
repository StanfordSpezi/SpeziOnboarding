//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI

struct OnboardingTestViewNotIdentifiable: View {
    var text: String

    @Environment(OnboardingNavigationPath.self) private var path


    var body: some View {
        VStack(spacing: 12) {
            Text(self.text)

            Button {
                path.nextStep()
            } label: {
                Text("Next")
            }
        }
    }
}

#if DEBUG
#Preview {
    OnboardingStack(startAtStep: OnboardingTestViewNotIdentifiable.self) {
        for onboardingView in OnboardingFlow.previewSimulatorViews {
            onboardingView
        }
    }
}
#endif
