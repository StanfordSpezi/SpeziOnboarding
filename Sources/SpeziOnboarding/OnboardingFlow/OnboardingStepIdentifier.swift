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
    let onboardingStepType: String
    let custom: Bool
    
    
    init(fromType type: any View.Type, custom: Bool = false) {
        self.onboardingStepType = String(describing: type)
        self.custom = custom
    }
    
    
    init(fromView view: any View, custom: Bool = false) {
        self.onboardingStepType = String(describing: type(of: view))
        self.custom = custom
    }
}
