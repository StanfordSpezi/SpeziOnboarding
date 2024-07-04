//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

// Error that can occur if ``OnboardingConsentView`` calls store in ExampleStandard
// with an identifier which is not in ``ConsentDocumentIdentifier``
public enum ConsentStoreError: Error {
    case invalidIdentifier(String)
    
    public var errorDescription: String? {
        "Invalid identifier"
    }
}
