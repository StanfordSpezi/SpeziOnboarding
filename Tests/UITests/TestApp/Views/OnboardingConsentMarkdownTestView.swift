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
    @Environment(OnboardingNavigationPath.self) private var path
    
    var body: some View {
        OnboardingConsentView(
            markdown: {
                guard let url = Bundle.main.url(forResource: "Tester", withExtension: "md"),
                      let data = try? Data(contentsOf: url) else {
                    fatalError("ConsentDocument.md file not found in bundle.")
                }
                return data
            },
            action: {
                path.nextStep()
            },
            exportConfiguration: .init(paperSize: .dinA4, includingTimestamp: true)
        )
    }
}

#if DEBUG
struct OnboardingConsentMarkdownTestView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingStack(startAtStep: OnboardingConsentMarkdownTestView.self) {
            for onboardingView in OnboardingFlow.previewSimulatorViews {
                onboardingView
            }
        }
    }
}
#endif
