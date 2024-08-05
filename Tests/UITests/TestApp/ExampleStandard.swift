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
    // Example of an async function using MainActor and Task
    func store(consent: ConsentDocumentExport) async throws {
        // Extract data outside of the MainActor.run block
        let documentIdentifier = await consent.documentIdentifier
        let pdf = await consent.pdf
        
        // Perform operations on the main actor
        try await MainActor.run {
            if documentIdentifier == DocumentIdentifiers.first {
                self.firstConsentData = pdf ?? .init()
            } else if documentIdentifier == DocumentIdentifiers.second {
                self.secondConsentData = pdf ?? .init()
            } else {
                throw ConsentStoreError.invalidIdentifier("Invalid Identifier \(documentIdentifier.id)")
            }
        }
        
        try? await Task.sleep(for: .seconds(0.5))
    }
    
    func loadConsentDocument(identifier: ConsentDocumentIdentifier) async throws -> PDFDocument? {
        if identifier == DocumentIdentifiers.first {
            return await self.firstConsentData
        } else if identifier == DocumentIdentifiers.second {
            return await self.secondConsentData
        }
        
        // In case an invalid identifier is provided, return nil.
        // The OnboardingConsentMarkdownRenderingView checks if the document
        // is nil, and if so, displays an error.
        return nil
    }
}
