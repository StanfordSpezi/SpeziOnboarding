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
    @StandardActor var standard: any ConsentConstraint

    
    public init() { }


    /// Adds a new exported consent form represented as `PDFDocument` to the ``OnboardingDataSource``.
    ///
    /// - Parameters:
    ///   - consent: The exported consent form represented as `ConsentDocumentExportRepresentation` that should be added.
    ///   - identifier: The document identifier for the exported consent document.
    public func store(
        _ consent: consuming sending ConsentDocumentExportRepresentation,
        identifier: String = ConsentDocumentExportRepresentation.Defaults.documentIdentifier
    ) async throws {
        try await standard.store(consent: consent)
    }
}
