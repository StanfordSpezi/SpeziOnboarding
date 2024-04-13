//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// Wrap `Content` `View` in an `Identifiable` `View`.
private struct OnboardingIdentifiableView<Content, ID>: View, Identifiable where Content: View, ID: Hashable {
    /// Unique identifier of the wrapped `View`.
    let id: ID
    /// Wrapped `View`.
    let body: Content
}

private struct OnboardingIdentifiableViewModifier<ID>: ViewModifier, Identifiable where ID: Hashable {
    let id: ID

    func body(content: Content) -> some View {
        OnboardingIdentifiableView(
            id: self.id,
            body: content
        )
    }
}

extension View {
    /// `ViewModifier` assigning an identifier to the `View` it is applied to.
    /// When applying this modifier repeatedly, the outermost ``onboardingIdentifier(_:)`` counts.
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
    ///             MyOwnView().onboardingIdentifier("my-own-view-1")
    ///             MyOwnView().onboardingIdentifier("my-own-view-2")
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
