//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// :nodoc:
@available(*, deprecated, renamed: "ManagedNavigationStack.Path")
public typealias OnboardingNavigationPath = ManagedNavigationStack.Path


/// :nodoc:
@available(*, deprecated, renamed: "ManagedNavigationStack")
public typealias OnboardingStack = ManagedNavigationStack


extension View {
    /// Assign a unique identifier to a `View` appearing in a `ManagedNavigationStack`.
    @available(*, deprecated, renamed: "navigationStepIdentifier(_:)")
    public func onboardingIdentifier<ID: Hashable>(_ id: ID) -> some View {
        self.navigationStepIdentifier(id)
    }
}
