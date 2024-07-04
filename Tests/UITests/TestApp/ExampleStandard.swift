//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import Spezi
import SpeziOnboarding
import SwiftUI


/// An example Standard used for the configuration.
actor ExampleStandard: Standard, EnvironmentAccessible {
    @Published @MainActor var firstConsentData: PDFDocument = .init()
    @Published @MainActor var secondConsentData: PDFDocument = .init()
}


extension ExampleStandard: ConsentConstraint {
    func store(consent: PDFDocument, identifier: String) async throws {
        try await MainActor.run {
            if identifier == ConsentDocumentIdentifier.first {
                self.firstConsentData = consent
            } else if identifier == ConsentDocumentIdentifier.second {
                self.secondConsentData = consent
            } else {
                throw ConsentStoreError.invalidIdentifier("Invalid Identifier \(identifier)")
            }
        }
        try? await Task.sleep(for: .seconds(0.5))
    }
    
    func loadConsentDocument(identifier: String) async throws -> PDFDocument? {
        if identifier == ConsentDocumentIdentifier.first {
            return await self.firstConsentData
        } else if identifier == ConsentDocumentIdentifier.second {
            return await self.secondConsentData
        }
        
        // In case an invalid identifier is provided, return nil.
        // The OnboardingConsentMarkdownRenderingView checks if the document
        // is nil, and if so, displays an error.
        return nil
    }
}
