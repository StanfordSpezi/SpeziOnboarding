//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//
import Foundation
import SwiftUI

public class OnboardingFlowViewCollection: ObservableObject {
    @Published var views: [any View]
    
    init(views: [any View]) {
        self.views = views
    }
}
