//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PDFKit
import Spezi


/// A Constraint which all `Standard` instances must conform to when using the Spezi Onboarding module.
public protocol OnboardingConstraint: Standard {
    /// Adds a new exported consent form represented as `PDFDocument` to the `Standard` conforming to ``OnboardingConstraint``.
    /// 
    /// - Parameters:
    ///   - consent: The exported consent form represented as `PDFDocument` that should be added.
    ///   - name: The name components used in the consent form.
    func store(consent: PDFDocument, name: PersonNameComponents) async
}
