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
    @EnvironmentObject private var path: OnboardingNavigationPath
    
    
    var body: some View {
        ConsentView(
            header: {
                OnboardingTitleView(title: "Consent", subtitle: "Version 1.0")
            },
            asyncMarkdown: {
                Data("This is a *markdown* **example**".utf8)
            },
            action: {
                path.nextStep()
            },
            givenNameField: FieldLocalizationResource(title: "First Name", placeholder: "Enter your first name ..."),
            familyNameField: FieldLocalizationResource(title: "Surname", placeholder: "Enter your surname ...")
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}


#if DEBUG
struct ConsentMarkdownTestView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingConsentMarkdownTestView()
    }
}
#endif
