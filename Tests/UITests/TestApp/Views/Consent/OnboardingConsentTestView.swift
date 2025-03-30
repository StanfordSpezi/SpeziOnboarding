//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SpeziViews
import SwiftUI


struct OnboardingConsentTestView: View {
    let consentTitle: String
    let consentText: String
    let documentIdentifier: ConsentDocumentIdentifiers

    @Environment(OnboardingStack.Path.self) private var path
    @Environment(ExampleStandard.self) private var standard

    
    var body: some View {
        OnboardingConsentView(
            markdown: {
                Data(consentText.utf8)
            },
            action: { exportedConsent in
                // Store the exported consent form in the `ExampleStandard`
                switch documentIdentifier {
                case .first: standard.firstConsentDocument = exportedConsent
                case .second: standard.secondConsentDocument = exportedConsent
                }

                // Simulate storage / upload delay of consent form
                try await Task.sleep(until: .now + .seconds(0.5))

                // Navigates to the next onboarding step
                path.nextStep()
            },
            title: consentTitle.localized(),
            currentDateInSignature: true,
            exportConfiguration: .init(paperSize: .dinA4, includingTimestamp: true)
        )
    }
}
