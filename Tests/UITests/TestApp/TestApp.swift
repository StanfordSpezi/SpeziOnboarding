//
// This source file is part of the CardinalKit open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


@main
struct UITestsApp: App {
    @State private var path = NavigationPath()
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                OnboardingTestsView(navigationPath: $path)
            }
        }
    }
}
