//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// Wrap `Content` `View` in an `Identifiable` `View`.
public struct OnboardingIdentifiableView<Content>: View, Identifiable where Content: View {
    /// Unique identifier of the wrapped `View`.
    public let id: String
    /// Wrapped `View`.
    public var body: Content
}

struct OnboardingIdentifiableViewModifier: ViewModifier {
    let identifier: String

    func body(content: Content) -> some View {
        OnboardingIdentifiableView(
            id: self.identifier,
            body: content
        )
    }
}


extension View {
    /// `ViewModifier` assigning an identifier to the `View` it is applied to.
    /// When applying this modifier repeatedly, the outermost ``id(_:)`` counts.
    /// - Parameters:
    ///   - identifier: The `String` identifier given to the view.
    public func id(_ identifier: String) -> some View {
        modifier(OnboardingIdentifiableViewModifier(identifier: identifier))
    }
}
