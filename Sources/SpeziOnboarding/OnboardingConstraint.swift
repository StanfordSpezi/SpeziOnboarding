//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi


/// A Constraint which all `Standard` instances must conform to when using the Spezi Onboarding module.
public protocol OnboardingConstraint: Standard {
    /// Adds a new exported consent form represented as `Data` to the `Standard` conforming to ``OnboardingConstraint``.
    /// 
    /// - Parameter consent: The exported consent form represented as `Data` that should be added.
    func store(consent: Data) async
    
    /// Loads the exported consent form represented as `Data` from the ``OnboardingDataSource``.
    ///
    /// - Returns: The loaded consent data.
    func loadConsent() async throws -> Data
}
