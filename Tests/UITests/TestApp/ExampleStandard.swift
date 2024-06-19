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


extension ExampleStandard: OnboardingConstraint {
    func store(consent: PDFDocument, identifier: String) async {
        await MainActor.run {
            if(identifier == "FirstConsentDocument")
            {
                self.firstConsentData = consent
            }
            if(identifier == "SecondConsentDocument")
            {
                self.secondConsentData = consent
            }
        }
        try? await Task.sleep(for: .seconds(0.5))
    }
    
    func loadConsentDocument(identifier: String) async throws -> PDFDocument? {
        
        if(identifier == "FirstConsentDocument")
        {
            return await self.firstConsentData
        }
        if(identifier == "SecondConsentDocument")
        {
            return await self.secondConsentData
        }
        
        // In case an invalid identifier is provided, return nil.
        // The OnboardingConsentMarkdownRenderingView checks if the document
        // is nil, and if so, displays an error.
        return nil
    }
    

}
