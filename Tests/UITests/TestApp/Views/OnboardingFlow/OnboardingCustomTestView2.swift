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


struct OnboardingCustomTestView2: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Custom Test View 2")
            
            Button {
                path.nextStep()
            } label: {
                Text("Next")
            }
        }
    }
}
