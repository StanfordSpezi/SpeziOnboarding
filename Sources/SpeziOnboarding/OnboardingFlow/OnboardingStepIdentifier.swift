//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// An `OnboardingStepIdentifier` serves as an abstraction of a step in the onboarding flow as outlined within the ``OnboardingStack``.
/// 
/// It contains both the identifier for an onboarding step (the view's type) as well as a flag that indicates if it's a custom onboarding step.
struct OnboardingStepIdentifier: Hashable, Codable {
    let identifierHash: Int
    /// Whether the step is custom, i.e. created via e.g. ``OnboardingNavigationPath/append(customView:)``
    let isCustom: Bool

    /// Initializes an identifier using a view. If the view conforms to `Identifiable`, its `id` is used; otherwise, the view's type is used.
    /// - Parameters:
    ///   - view: The view used to initialize the identifier.
    ///   - custom: A flag indicating whether the step is custom.
    @MainActor
    init(view: some View, isCustom: Bool = false) {
        self.isCustom = isCustom
        var hasher = Hasher()
        if let identifiable = view as? any Identifiable {
            let id = identifiable.id
            hasher.combine(id)
        } else if let identifiable = view as? any OnboardingIdentifiable {
            let id = identifiable.id
            hasher.combine(id)
        } else {
            hasher.combine(String(reflecting: type(of: view as Any)))
        }
        self.identifierHash = hasher.finalize()
    }

    /// Initializes an identifier using a view type.
    /// - Parameters:
    ///   - onboardingStepType: The class of the view used to initialize the identifier.
    ///   - custom: A flag indicating whether the step is custom.
    init(onboardingStepType: (some View).Type, isCustom: Bool = false) {
        self.isCustom = isCustom
        var hasher = Hasher()
        hasher.combine(String(reflecting: onboardingStepType))
        self.identifierHash = hasher.finalize()
    }
}
