//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// A ``_OnboardingFlowViewCollection`` defines a collection of SwiftUI `View`s that are defined with an ``OnboardingStack``.
///
/// You can not create a ``_OnboardingFlowViewCollection`` yourself. Please use the ``OnboardingStack`` that internally creates a ``_OnboardingFlowViewCollection`` with the passed views.
public class _OnboardingFlowViewCollection: ObservableObject {  // swiftlint:disable:this type_name
    @Published var views: [any View]
    
    
    init(views: [any View]) {
        self.views = views
    }
}
