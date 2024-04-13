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
    let custom: Bool
    let identifierHash: Int

    /// Initializes an identifier using a view. If the view conforms to `Identifiable`, its `id` is used; otherwise, the view's type is used.
    /// - Parameters:
    ///   - view: The view used to initialize the identifier.
    ///   - custom: A flag indicating whether the step is custom.
    init<V: View>(view: V, custom: Bool = false) {
        self.custom = custom
        var hasher = Hasher()
        if let identifiable = view as? any Identifiable {
            let id = identifiable.id
            hasher.combine(id)
        } else {
            hasher.combine(String(describing: type(of: view)))
        }
        self.identifierHash = hasher.finalize()
    }

    /// Initializes an identifier using a view type.
    /// - Parameters:
    ///   - onboardingStepType: The class of the view used to initialize the identifier.
    ///   - custom: A flag indicating whether the step is custom.
    init(onboardingStepType: any View.Type, custom: Bool = false) {
        self.custom = custom
        var hasher = Hasher()
        hasher.combine(String(describing: onboardingStepType))
        self.identifierHash = hasher.finalize()
    }
}
