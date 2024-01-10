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
    @Environment(OnboardingNavigationPath.self) private var path
    @Binding var showConditionalView: Bool
    

    var body: some View {
        VStack(spacing: 8) {  // swiftlint:disable:this closure_body_length
            Button {
                path.append(OnboardingWelcomeTestView.self)
            } label: {
                Text("Welcome View")
            }
            
            Button {
                path.append(OnboardingSequentialTestView.self)
            } label: {
                Text("Sequential Onboarding")
            }

            Button {
                path.append(OnboardingConsentMarkdownTestView.self)
            } label: {
                Text("Consent View (Markdown)")
            }
            
            Button {
                path.append(OnboardingConsentMarkdownRenderingView.self)
            } label: {
                Text("Rendered Consent View (Markdown)")
            }
            
            Button {
                path.append(
                    customView: OnboardingCustomTestView1(exampleArgument: "Hello Spezi!")
                )
            } label: {
                Text("Custom Onboarding View 1")
            }
            
            Button {
                path.append(customView: OnboardingCustomTestView2())
            } label: {
                Text("Custom Onboarding View 2")
            }
            
            Spacer()
                .frame(height: 8)
            
            /// We need to use a custom-built toggle as UI tests are very flakey when clicking on SwiftUI `Toggle`'s
            CustomToggleView(
                text: "Show Conditional View",
                condition: $showConditionalView
            )
        }
    }
}


#if DEBUG
struct OnboardingStartTestView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingStack(startAtStep: OnboardingStartTestView.self) {
            for onboardingView in OnboardingFlow.previewSimulatorViews {
                onboardingView
            }
        }
    }
}
#endif
