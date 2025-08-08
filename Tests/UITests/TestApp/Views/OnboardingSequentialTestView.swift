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


struct OnboardingSequentialTestView: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    
    
    var body: some View {
        SequentialOnboardingView(
            title: "Things to know",
            subtitle: "And you should pay close attention ...",
            steps: [
                .init(title: "A thing to know", description: "This is a first thing that you should know, read carefully!"),
                .init(title: "Second thing to know", description: "This is a second thing that you should know, read carefully!"),
                .init(title: "Third thing to know", description: "This is a third thing that you should know, read carefully!"),
                .init(description: "Now you should know all the things!")
            ],
            actionText: "Continue"
        ) {
            path.nextStep()
        }
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
    }
}
