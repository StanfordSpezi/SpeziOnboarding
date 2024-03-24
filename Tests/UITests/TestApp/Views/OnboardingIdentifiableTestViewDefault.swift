//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI

struct OnboardingIdentifiableTestViewDefault: OnboardingIdentifiableView {
    @Environment(OnboardingNavigationPath.self) private var path


    var body: some View {
        VStack(spacing: 12) {
            Text(self.id)

            Button {
                path.append(identifiableView: OnboardingIdentifiableTestViewCustom(id: "ID: 1"))
            } label: {
                Text("Next")
            }
        }
    }
}

#if DEBUG
struct OnboardingIdentifiableViewDefault_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingStack(startAtStep: OnboardingIdentifiableTestViewDefault.self) {
            for onboardingView in OnboardingFlow.previewSimulatorViews {
                onboardingView
            }
        }
    }
}
#endif
