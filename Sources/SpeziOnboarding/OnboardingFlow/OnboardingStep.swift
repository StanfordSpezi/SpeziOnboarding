//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

struct OnboardingStep: Hashable {
    let wrappedStep: String
    
    init(fromType type: any View.Type) {
        wrappedStep = String(describing: type)
    }
    
    init(fromView view: any View) {
        wrappedStep = String(describing: type(of: view))
    }
}
