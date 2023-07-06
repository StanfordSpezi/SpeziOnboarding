//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

public struct OnboardingFlow: View {
    @StateObject var onboardingViewController: OnboardingViewController

    public var body: some View {
        onboardingViewController.currentView
            .environmentObject(onboardingViewController)
    }
    
    public init(onboardingFlowComplete: Binding<Bool>, @OnboardingViewBuilder _ content: @escaping () -> OnboardingFlowViewCollection) {
        // Sadly, we cannot use async stuff here as otherwise the entire `OnboardingFlow` is async (the result builder itself could be async) -> cannot be used in a View body
        let onboardingFlowViewCollection = content()
        
        self._onboardingViewController = StateObject(
            wrappedValue: OnboardingViewController(
                views: onboardingFlowViewCollection.views,
                complete: onboardingFlowComplete
            )
        )
    }
}
