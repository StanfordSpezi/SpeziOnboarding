//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The `IllegalOnboardingStepView` is shown when the application navigates to an illegal ``OnboardingStep``.
/// 
/// This behavior shouldn't occur at all as there are lots of checks performed within the ``OnboardingNavigationPath`` that prevent such illegal steps.
struct IllegalOnboardingStepView: View {
    var body: some View {
        Text("ILLEGAL_ONBOARDING_STEP", bundle: .module)
    }
}


#if DEBUG
struct IllegalOnboardingStepView_Previews: PreviewProvider {
    static var previews: some View {
        IllegalOnboardingStepView()
    }
}
#endif
