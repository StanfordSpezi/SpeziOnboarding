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
///    func store(consent: Data, name: PersonNameComponents) {
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
public class OnboardingDataSource: Component, ObservableObject, ObservableObjectProvider {
    @StandardActor var standard: any OnboardingConstraint
    
    
    public init() { }
    
    
    /// Adds a new exported consent form represented as `PDFDocument` to the ``OnboardingDataSource``.
    ///
    /// - Parameters:
    ///   - consent: The exported consent form represented as `PDFDocument` that should be added.
    ///   - name: The name components used in the consent form.
    public func store(_ consent: PDFDocument, name: PersonNameComponents) async {
        Task { @MainActor in
            await standard.store(consent: consent, name: name)
        }
    }
}
