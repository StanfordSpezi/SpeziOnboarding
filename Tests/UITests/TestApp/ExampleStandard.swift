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


// An enum to hold identifier strings to identify two separate consent documents.
enum DocumentIdentifiers {
    static let first = "firstConsentDocument"
    static let second = "secondConsentDocument"
}


/// An example `Standard` used for the configuration.
actor ExampleStandard: Standard, EnvironmentAccessible {
    @MainActor var firstConsentData: PDFDocument = .init()
    @MainActor var secondConsentData: PDFDocument = .init()
}

extension ExampleStandard: ConsentConstraint {
    func store(consent: consuming sending ConsentDocumentExportRepresentation) async throws {
        let documentIdentifier = consent.documentIdentifier
        let pdf = try consent.render()
        
        try await self.store(document: pdf, for: documentIdentifier)
        try? await Task.sleep(for: .seconds(0.5))   // Simulates storage delay
    }

    @MainActor
    func store(document pdf: sending PDFDocument, for documentIdentifier: String) throws {
        if documentIdentifier == DocumentIdentifiers.first {
            self.firstConsentData = pdf
        } else if documentIdentifier == DocumentIdentifiers.second {
            self.secondConsentData = pdf
        } else {
            preconditionFailure("Unexpected document identifier when persisting consent document: \(documentIdentifier)")
        }
    }

    @MainActor
    func resetDocument(identifier: String) async throws {
        if identifier == DocumentIdentifiers.first {
            firstConsentData = .init()
        } else if identifier == DocumentIdentifiers.second {
            secondConsentData = .init()
        }
    }

    @MainActor
    func loadConsentDocument(identifier: String) async throws -> PDFDocument? {
        if identifier == DocumentIdentifiers.first {
            return self.firstConsentData
        } else if identifier == DocumentIdentifiers.second {
            return self.secondConsentData
        }
        
        // In case an invalid identifier is provided, return nil.
        // The OnboardingConsentMarkdownRenderingView checks if the document
        // is nil, and if so, displays an error.
        return nil
    }
}
