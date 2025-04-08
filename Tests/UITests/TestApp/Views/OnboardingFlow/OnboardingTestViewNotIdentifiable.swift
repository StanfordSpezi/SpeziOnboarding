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
    var text: String

    @Environment(ManagedNavigationStack.Path.self) private var path


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
