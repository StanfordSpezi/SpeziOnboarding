//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import PDFKit
import Spezi
import SwiftUI


private protocol DeprecationSuppression {
    func storeInLegacyConstraint(for standard: any Standard, _ consent: sending ConsentDocumentExport) async
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
    /// - Parameters
    ///     - consent: The PDF of the exported consent form.
    ///     - identifier: The document identifier for the exported consent document.
    @available(
        *,
        deprecated,
        message: """
        Storing consent documents using an exported PDF and an identifier is deprecated.
        Please store the consent document from the corresponding `ConsentDocumentExport`,
        by using `ConsentConstraint.store(_ consent: ConsentDocumentExport)` instead.
        """
    )
    public func store(_  consent: sending PDFDocument, identifier: String = ConsentDocumentExport.Defaults.documentIdentifier) async throws {
        // Normally, the ConsentDocumentExport stores all data relevant to generate the PDFDocument, such as the data and ExportConfiguration.
        // Since we can not determine the original data and the ExportConfiguration at this point, we simply use some placeholder data
        // to generate the ConsentDocumentExport.
        let dataPlaceholder = {
            Data("".utf8)
        }
        let documentExport = ConsentDocumentExport(
            markdown: dataPlaceholder,
            exportConfiguration: ConsentDocument.ExportConfiguration(),
            documentIdentifier: identifier,
            cachedPDF: consent
        )
        try await store(documentExport)
    }
    
    /// Adds a new exported consent form represented as `PDFDocument` to the ``OnboardingDataSource``.
    ///
    /// - Parameters:
    ///   - consent: The exported consent form represented as `ConsentDocumentExport` that should be added.
    ///   - identifier: The document identifier for the exported consent document.
    public func store(_ consent: sending ConsentDocumentExport, identifier: String = ConsentDocumentExport.Defaults.documentIdentifier) async throws {
        if let consentConstraint = standard as? any ConsentConstraint {
            try await consentConstraint.store(consent: consent)
        } else {
            // By down-casting to the protocol we avoid "seeing" the deprecation warning, allowing us to hide it from the compiler.
            // We need to call the deprecated symbols for backwards-compatibility.
            await (self as any DeprecationSuppression).storeInLegacyConstraint(for: standard, consent)
        }
    }
}


extension OnboardingDataSource: DeprecationSuppression {
    @available(*, deprecated, message: "Suppress deprecation warning.")
    func storeInLegacyConstraint(for standard: any Standard, _ consent: sending ConsentDocumentExport) async {
        if let onboardingConstraint = standard as? any OnboardingConstraint {
            await onboardingConstraint.store(consent: consent.consumePDF())
        } else {
            fatalError("A \(type(of: standard).self) must conform to `ConsentConstraint` to process signed consent documents.")
        }
    }
}
