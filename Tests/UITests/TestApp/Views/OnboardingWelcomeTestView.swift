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


// swiftlint:disable accessibility_label_for_image
struct OnboardingWelcomeTestView: View {
    @Environment(OnboardingNavigationPath.self) private var path
    
    
    var body: some View {
        OnboardingView(
            title: "Welcome",
            subtitle: "Spezi UI Tests",
            areas: [
                .init(icon: { Image(systemName: "tortoise.fill").foregroundColor(.green) }, title: "Tortoise", description: "A Tortoise!"),
                .init(icon: Image(systemName: "tree.fill"), title: "Tree", description: "A Tree!"),
                .init(icon: { Text("A").fontWeight(.light) }, title: "Letter", description: "A letter!"),
                .init(icon: { Circle().fill(.orange) }, title: "Circle", description: "A circle!")
            ],
            actionText: "Learn More",
            action: {
                path.nextStep()
            }
        )
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
    }
}


#if DEBUG
struct OnboardingWelcomeTestView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingStack(startAtStep: OnboardingWelcomeTestView.self) {
            for onboardingView in OnboardingFlow.previewSimulatorViews {
                onboardingView
            }
        }
    }
}
#endif
