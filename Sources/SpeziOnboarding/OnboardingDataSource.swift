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
/// Make sure that the `Standard` in your Spezi Application conforms to the ``ConsentConstraint``
/// protocol to store exported consent forms.
/// ```swift
/// actor ExampleStandard: Standard, ConsentConstraint {
///    func store(consent: consuming sending ConsentDocumentExportRepresentation) async throws
///        let pdf = try consent.render()
///        let documentIdentifier = consent.documentIdentifier
///        // ...
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
public final class OnboardingDataSource: Module, EnvironmentAccessible {
    @StandardActor var standard: any ConsentConstraint

    
    public init() { }


    /// Adds a new exported consent form representation ``ConsentDocumentExportRepresentation`` to the ``OnboardingDataSource``.
    ///
    /// - Parameters:
    ///   - consent: The exported consent form represented as ``ConsentDocumentExportRepresentation`` that should be added.
    @MainActor
    public func store(_ consent: consuming sending ConsentDocumentExportRepresentation) async throws {
        try await standard.store(consent: consent)
    }
}
