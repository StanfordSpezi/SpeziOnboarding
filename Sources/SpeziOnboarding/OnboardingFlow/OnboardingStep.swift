//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

/// An `OnboardingStep` serves as an abstraction of a step in the onboarding flow as outlined within the ``OnboardingStack``.
/// It contains both the associated SwiftUI `View` with an onboarding step as well as a lightweight `OnboardingStep.Identifier`
struct OnboardingStep {
    let view: any View
    let step: Identifier
    
    struct Identifier: Hashable, Codable {
        let wrappedStep: String
        let custom: Bool
        
        init(fromType type: any View.Type, custom: Bool = false) {
            self.wrappedStep = String(describing: type)
            self.custom = custom
        }
        
        init(fromView view: any View, custom: Bool = false) {
            self.wrappedStep = String(describing: type(of: view))
            self.custom = custom
        }
    }
}
