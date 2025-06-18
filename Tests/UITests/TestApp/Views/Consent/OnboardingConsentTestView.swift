//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziConsent
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct OnboardingConsentTestView: View {
    let consentTitle: String
    let consentText: String
    let documentIdentifier: ConsentDocumentIdentifiers
    private let exportConfig = ConsentDocument.ExportConfiguration(paperSize: .dinA4, includingTimestamp: true)
    
    @Environment(ManagedNavigationStack.Path.self) private var path
    @Environment(ExampleStandard.self) private var standard
    
    @State private var consentDocument: ConsentDocument?
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        OnboardingConsentView(
            consentDocument: consentDocument,
            title: consentTitle.localized(),
            currentDateInSignature: true
        ) {
            guard let consentDocument else {
                return
            }
            let pdf = try consentDocument.export(using: exportConfig).pdf
            // Store the exported consent form in the `ExampleStandard`
            switch documentIdentifier {
            case .first:
                standard.firstConsentDocument = pdf
            case .second:
                standard.secondConsentDocument = pdf
            }
            // Simulate storage / upload delay of consent form
            try await Task.sleep(until: .now + .seconds(0.5))
            // Navigate to the next onboarding step
            path.nextStep()
        }
        .viewStateAlert(state: $viewState)
        .task {
            do {
                consentDocument = try ConsentDocument(markdown: consentText, enableCustomElements: false)
            } catch {
                viewState = .error(AnyLocalizedError(error: error))
            }
        }
    }
}
