//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

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
public class OnboardingDataSource: Component, ObservableObject, ObservableObjectProvider {
    @StandardActor var standard: any OnboardingConstraint
    
    
    public init() { }
    
    
    /// Adds a new exported consent form represented as `Data` to the ``OnboardingDataSource``.
    ///
    /// - Parameter consent: The exported consent form represented as `Data` that should be added.
    public func store(_ consent: Data) {
        Task { @MainActor in
            await standard.store(consent: consent)
        }
    }
    
    /// Loads the exported consent form represented as `Data` from the ``OnboardingDataSource``.
    ///
    /// - Returns: The loaded consent data.
    public func load() async throws -> Data {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                let result = try await standard.loadConsent()
                continuation.resume(returning: result)
            }
        }
    }
}
