//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI

struct OnboardingTestViewNotIdentifiable: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    
    let text: String
    
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
