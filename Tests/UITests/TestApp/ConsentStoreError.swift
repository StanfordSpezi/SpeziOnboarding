//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

// Error that can occur if ``OnboardingConsentView`` calls store in ExampleStandard
// with an identifier which is not in ``DocumentIdentifiers``.
enum ConsentStoreError: LocalizedError {
    case invalidIdentifier(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidIdentifier:
            String(
                localized: "Unknown document identifier provided in the OnboardingConsentView.",
                comment: "Error thrown if a document identifier was passed to OnboardingConsentView, which is unknown to the Standard."
            )
        }
    }
}
