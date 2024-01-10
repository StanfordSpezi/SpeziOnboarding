//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI


struct OnboardingCustomTestView1: View {
    @Environment(OnboardingNavigationPath.self) private var path
    var exampleArgument: String
    
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Custom Test View 1: \(exampleArgument)")
            
            Button {
                path.append(customView: OnboardingCustomTestView2())
            } label: {
                Text("Next")
            }
        }
    }
}


#if DEBUG
struct OnboardingCustomTestView1_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingStack(startAtStep: OnboardingCustomTestView1.self) {
            for onboardingView in OnboardingFlow.previewSimulatorViews {
                onboardingView
            }
        }
    }
}
#endif
