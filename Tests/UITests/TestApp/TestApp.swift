//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


@main
struct UITestsApp: App {
    @ApplicationDelegateAdaptor(SpeziAppDelegate.self) var appDelegate
    @State var onboardingFlowComplete = false
    
    
    var body: some Scene {
        WindowGroup {
            if !onboardingFlowComplete {
                OnboardingTestsView(onboardingFlowComplete: $onboardingFlowComplete)
                    .spezi(appDelegate)
            } else {
                Text("Onboarding complete")
            }
        }
        #if os(visionOS)
        // for some reason, XCTest can't swipeUp() in visionOS (you can call the function; it just doesn't do anything),
        // so we instead need to make the window super large so that everything fits on screen without having to scroll.
        .defaultSize(width: 1250, height: 1250)
        #endif
    }
}

extension View {
    func printingType() -> Self {
        print()
        print(Self.self)
        print(type(of: self))
        return self
    }
}
