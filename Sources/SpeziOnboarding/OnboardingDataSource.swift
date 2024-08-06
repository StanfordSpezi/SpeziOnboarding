//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import Spezi
import SwiftUI


/// Configuration for the Spezi Onboarding module.
///
/// Make sure that your standard in your Spezi Application conforms to the ``OnboardingConstraint``
/// protocol to store exported consent forms.
/// ```swift
/// actor ExampleStandard: Standard, OnboardingConstraint {
///    func store(consent: Data) {
///        ...
///    }
/// }
/// ```
///
/// Use the ``OnboardingDataSource/init()`` initializer to add the data source to your `Configuration`.
/// ```swift
/// class ExampleAppDelegate: SpeziAppDelegate {
///     override var configuration: Configuration {
///         Configuration(standard: ExampleStandard()) {
///             OnboardingDataSource()
///         }
///     }
/// }
/// ```
public class OnboardingDataSource: Module, EnvironmentAccessible {
    @StandardActor var standard: any Standard
    
    
    public init() { }


    public func configure() {
        guard standard is any OnboardingConstraint || standard is any ConsentConstraint else {
            fatalError("A \(type(of: standard).self) must conform to `ConsentConstraint` to process signed consent documents.")
        }
    }
    
    /// Adds a new exported consent form represented as `PDFDocument` to the ``OnboardingDataSource``.
    ///
    /// - Parameter consent: The exported consent form represented as `ConsentDocumentExport` that should be added.
    public func store(_ consent: PDFDocument, identifier: String) async throws {
        if let consentConstraint = standard as? any ConsentConstraint {
            let consentDocumentExport = ConsentDocumentExport(documentIdentifier: identifier, cachedPDF: consent)
            try await consentConstraint.store(consent: consentDocumentExport)
        } else if let onboardingConstraint = standard as? any OnboardingConstraint {
            await onboardingConstraint.store(consent: consent)
        } else {
            fatalError("A \(type(of: standard).self) must conform to `ConsentConstraint` to process signed consent documents.")
        }
    }
}
