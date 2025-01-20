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


private protocol DeprecationSuppression {
    func storeInLegacyConstraint(for standard: any Standard, _ consent: sending PDFDocument) async
}


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
public final class OnboardingDataSource: Module, EnvironmentAccessible, @unchecked Sendable {
    @StandardActor var standard: any Standard
    
    
    public init() { }


    @available(*, deprecated, message: "Propagate deprecation warning")
    public func configure() {
        guard standard is any OnboardingConstraint || standard is any ConsentConstraint else {
            fatalError("A \(type(of: standard).self) must conform to `ConsentConstraint` to process signed consent documents.")
        }
    }
    
    /// Adds a new exported consent form represented as `PDFDocument` to the ``OnboardingDataSource``.
    ///
    /// - Parameter consent: The exported consent form represented as `ConsentDocumentExport` that should be added.
    public func store(_ consent: sending PDFDocument, identifier: String = ConsentDocumentExport.Defaults.documentIdentifier) async throws {
        if let consentConstraint = standard as? any ConsentConstraint {
            let consentDocumentExport = ConsentDocumentExport(documentIdentifier: identifier, cachedPDF: consent)
            try await consentConstraint.store(consent: consentDocumentExport)
        } else {
            // By down-casting to the protocol we avoid "seeing" the deprecation warning, allowing us to hide it from the compiler.
            // We need to call the deprecated symbols for backwards-compatibility.
            await (self as any DeprecationSuppression).storeInLegacyConstraint(for: standard, consent)
        }
    }
}


extension OnboardingDataSource: DeprecationSuppression {
    @available(*, deprecated, message: "Suppress deprecation warning.")
    func storeInLegacyConstraint(for standard: any Standard, _ consent: sending PDFDocument) async {
        if let onboardingConstraint = standard as? any OnboardingConstraint {
            await onboardingConstraint.store(consent: consent)
        } else {
            fatalError("A \(type(of: standard).self) must conform to `ConsentConstraint` to process signed consent documents.")
        }
    }
}
