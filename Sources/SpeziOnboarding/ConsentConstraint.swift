//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PDFKit
import Spezi


/// A Constraint which all `Standard` instances must conform to when using the `OnboardingConsentView`.
public protocol ConsentConstraint: Standard {
    /// Adds a new exported consent form represented as `PDFDocument` to the `Standard` conforming to ``ConsentConstraint``.
    /// 
    /// - Parameters:
    ///     - consent: The exported consent form represented as `PDFDocument` that should be added.            
    ///     - identifier: A 'String' identifying the consent form as specified in `OnboardingConsentView`.                
    func store(consent: PDFDocument, identifier: String) async throws
}
