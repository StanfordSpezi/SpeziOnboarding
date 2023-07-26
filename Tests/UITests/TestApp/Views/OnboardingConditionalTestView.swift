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


struct OnboardingConditionalTestView: View {
    @EnvironmentObject private var path: OnboardingNavigationPath
    
    
    var body: some View {
        VStack {
            Text("Conditional Test View")
            
            Button {
                path.nextStep()
            } label: {
                Text("Next")
            }
        }
    }
}


#if DEBUG
struct OnboardingConditionalTestView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingConditionalTestView()
    }
}
#endif
