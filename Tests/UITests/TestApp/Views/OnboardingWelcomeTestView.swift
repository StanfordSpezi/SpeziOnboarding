//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable accessibility_label_for_image

import SpeziOnboarding
import SpeziViews
import SwiftUI


struct OnboardingWelcomeTestView: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    
    var body: some View {
        OnboardingView(
            title: "Welcome",
            subtitle: "Spezi UI Tests",
            areas: [
                .init(icon: { Image(systemName: "tortoise.fill").foregroundColor(.green) }, title: "Tortoise", description: "A Tortoise!"),
                .init(iconSymbol: "tree.fill", title: "Tree", description: "A Tree!"),
                .init(icon: { Text("A").fontWeight(.light) }, title: "Letter", description: "A letter!"),
                .init {
                    Circle().fill(.orange)
                } title: {
                    Text("Circle")
                } description: {
                    Text("A circle!")
                }
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
