//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

public struct OnboardingStack: View {
    @StateObject var onboardingNavigationPath: OnboardingNavigationPath
    private var firstOnboardingView: AnyView {
        .init(onboardingNavigationPath.views[0])
    }

    public var body: some View {
        NavigationStack(path: $onboardingNavigationPath.path) {
            firstOnboardingView
                .navigationDestination(for: OnboardingStep.self) { onboardingStep in
                    onboardingNavigationPath.getView(forStep: onboardingStep)
                }
        }
        .environmentObject(onboardingNavigationPath)
    }
    
    public init(onboardingFlowComplete: Binding<Bool>? = nil, @OnboardingViewBuilder _ content: @escaping () -> OnboardingFlowViewCollection) {
        // Sadly, we cannot use async stuff here as otherwise the entire `OnboardingFlow` is async (the result builder itself could be async) -> cannot be used in a View body
        let onboardingFlowViewCollection = content()
        
        self._onboardingNavigationPath = StateObject(
            wrappedValue: OnboardingNavigationPath(
                views: onboardingFlowViewCollection.views,
                complete: onboardingFlowComplete
            )
        )
    }
}
