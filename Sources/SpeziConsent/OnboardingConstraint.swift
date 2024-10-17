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
@available(
    *,
    deprecated,
    message: """
    Storing consent documents without an identifier is deprecated.
    Please use `ConsentConstraint` instead.
    """
)
public protocol OnboardingConstraint: Standard {
    /// Adds a new exported consent form represented as `PDFDocument` to the `Standard` conforming to ``OnboardingConstraint``.
    /// 
    /// - Parameters:
    ///     - consent: The exported consent form represented as `PDFDocument` that should be added.
    @available(
        *,
        deprecated,
        message: """
        Storing consent documents without an identifier is deprecated.
        Please use `ConsentConstraint.store(consent: PDFDocument, identifier: String)` instead.
        """
    )
    func store(consent: PDFDocument) async
}
