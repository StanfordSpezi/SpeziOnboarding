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
    @MainActor private(set) var consentData: PDFDocument = .init()
}


extension ExampleStandard: OnboardingConstraint {
    @MainActor
    func store(consent: PDFDocument) async {
        self.consentData = consent
        try? await Task.sleep(for: .seconds(0.5))
    }

    @MainActor
    func loadConsent() async throws -> PDFDocument {
        self.consentData
    }
}
