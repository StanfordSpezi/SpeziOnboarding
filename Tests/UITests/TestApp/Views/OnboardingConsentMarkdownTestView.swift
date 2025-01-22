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


struct OnboardingConsentMarkdownTestView: View {
    let consentTitle: String
    let consentText: String
    let documentIdentifier: String

    @Environment(OnboardingNavigationPath.self) private var path
    
    
    var body: some View {
        OnboardingConsentView(
            markdown: {
                Data(consentText.utf8)
            },
            action: {
                path.nextStep()
            },
            title: consentTitle.localized(),
            identifier: documentIdentifier,
            exportConfiguration: .init(paperSize: .dinA4, includingTimestamp: true)
        )
    }
}


#if DEBUG
#Preview {
    OnboardingStack(startAtStep: OnboardingConsentMarkdownTestView.self) {
        for onboardingView in OnboardingFlow.previewSimulatorViews {
            onboardingView
        }
    }
}
#endif
