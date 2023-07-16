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
    @ObservedObject var onboardingFlowViewCollection: OnboardingFlowViewCollection
    
    
    public var body: some View {
        NavigationStack(path: $onboardingNavigationPath.path) {
            onboardingNavigationPath.firstOnboardingView
                .navigationDestination(for: OnboardingStepIdentifier.self) { onboardingStep in
                    onboardingNavigationPath.navigate(to: onboardingStep)
                        .navigationBarBackButtonHidden()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                backButton
                            }
                        }
                }
        }
        .environmentObject(onboardingNavigationPath)
        .onReceive(onboardingFlowViewCollection.$views, perform: { newViews in
            self.onboardingNavigationPath.updateViews(with: newViews)
        })
    }
    
    @ViewBuilder
    private var backButton: some View {
        // TODO: Environment object / Environment path that is passed to all views in the onboarding view stack enabelling the "disabelling" of the back button for a short amount of time
        Button(action: {
            onboardingNavigationPath.removeLast()
        }) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .font(.system(size: 17, weight: .semibold))
                // TODO: Why isn't this text displayed in "leading" placement? Some kind of toolbar limitation?
                // With .navigationBarItems(leading: backButton) is somehow works but the placement is off
                Text(String(localized: "BACK_BUTTON_CONTENT", bundle: .module))
                    .foregroundColor(.blue)
                    .font(.system(size: 17))
            }
        }
    }
    
    public init(onboardingFlowComplete: Binding<Bool>? = nil, @OnboardingViewBuilder _ content: @escaping () -> OnboardingFlowViewCollection) {
        let onboardingFlowViewCollection = content()
        self.onboardingFlowViewCollection = onboardingFlowViewCollection
        
        self._onboardingNavigationPath = StateObject(
            wrappedValue: OnboardingNavigationPath(
                views: onboardingFlowViewCollection.views,
                complete: onboardingFlowComplete
            )
        )
    }
}
