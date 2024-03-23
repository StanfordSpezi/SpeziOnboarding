//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// A protocol that defines an onboarding view with a unique identifier.
///
/// Conforming to this protocol allows a SwiftUI `View` to be identified uniquely within an onboarding process.
/// If no explicit ``id-2e4hq`` is provided, the identifier of the `View` will default to its type name e.g. `WelcomeView`.
///
/// Here's an example of how to conform to `OnboardingIdentifiableView`:
///
/// ```swift
/// struct WelcomeView: OnboardingIdentifiableView {
///     var id: String = "welcome-view"
///
///     var body: some View {
///         Text("Welcome to the app!")
///     }
/// }
/// ```
public protocol OnboardingIdentifiableView: View, Identifiable {
    /// View identifier that is unique among all other onboarding views.
    var id: String { get }
}

extension OnboardingIdentifiableView {
    /// Default implementation of ``id-3adll`` that uses a string representation of the `View`'s type as its id.
    public var id: String {
        String(describing: type(of: self))
    }
}
