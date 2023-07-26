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

struct OnboardingWelcomeTestView: View {
    @EnvironmentObject private var path: OnboardingNavigationPath
    
    
    var body: some View {
        OnboardingView(
            title: "Welcome",
            subtitle: "Spezi UI Tests",
            areas: [
                .init(icon: Image(systemName: "tortoise.fill"), title: "Tortoise", description: "A Tortoise!"),
                .init(icon: Image(systemName: "lizard.fill"), title: "Lizard", description: "A Lizard!"),
                .init(icon: Image(systemName: "tree.fill"), title: "Tree", description: "A Tree!")
            ],
            actionText: "Learn More",
            action: {
                path.nextStep()
            }
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}


#if DEBUG
struct OnboardingWelcomeTestView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingWelcomeTestView()
    }
}
#endif
