//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI

struct OnboardingIdentifiableTestViewCustom: View, Identifiable {
    var id: String

    @Environment(OnboardingStack.Path.self) private var path


    var body: some View {
        VStack(spacing: 12) {
            Text(self.id)

            Button {
                if self.id == "ID: 1" {
                    path.append(customView: OnboardingIdentifiableTestViewCustom(id: "ID: 2"))
                } else {
                    path.nextStep()
                }
            } label: {
                Text("Next")
            }
        }
    }
}
