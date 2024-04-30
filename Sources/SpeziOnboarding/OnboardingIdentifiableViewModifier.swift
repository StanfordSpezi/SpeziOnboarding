//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct OnboardingIdentifiableViewModifier<ID>: ViewModifier, Identifiable where ID: Hashable {
    let id: ID

    func body(content: Content) -> some View { content }
}


extension View {
    /// Assign a unique identifier to a ``SwiftUI/View`` appearing in an ``OnboardingStack``.
    ///
    /// A `ViewModifier` assigning an identifier to the `View` it is applied to.
    /// When applying this modifier repeatedly, the outermost ``SwiftUI/View/onboardingIdentifier(_:)`` counts.
    ///
    /// - Note: This `ViewModifier` should only be used to identify `View`s of the same type within an ``OnboardingStack``.
    ///
    /// - Parameters:
    ///   - identifier: The `Hashable` identifier given to the view.
    ///
    /// ```swift
    /// struct Onboarding: View {
    ///     @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    ///
    ///     var body: some View {
    ///         OnboardingStack(onboardingFlowComplete: $completedOnboardingFlow) {
    ///             MyOwnView()
    ///                 .onboardingIdentifier("my-own-view-1")
    ///             MyOwnView()
    ///                 .onboardingIdentifier("my-own-view-2")
    ///         }
    ///     }
    /// }
    /// ```
    public func onboardingIdentifier<ID>(_ identifier: ID) -> some View where ID: Hashable {
        modifier(OnboardingIdentifiableViewModifier(id: identifier))
    }
}


extension ModifiedContent: Identifiable where Modifier: Identifiable {
    public var id: Modifier.ID {
        self.modifier.id
    }
}
