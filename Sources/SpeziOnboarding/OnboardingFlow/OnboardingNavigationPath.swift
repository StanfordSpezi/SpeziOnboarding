//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

public class OnboardingNavigationPath: ObservableObject {
    @Published public var path = NavigationPath()
    var views: [any View]
    private var complete: Binding<Bool>?
    private var topPathCompontentIndex: Int  // We cannot get the "uppermost" element from the navigationpath, need to keep some internal state -> Here in the form of an index that tracks the uppermost element
    
    init(views: [any View], complete: Binding<Bool>?) {
        self.views = views
        self.complete = complete
        self.topPathCompontentIndex = 0
    }
    
    func getView(forStep onboardingStep: OnboardingStep) -> AnyView {
        // We could also just access the index here? But it's cleaner to filter to the OnboardingStep within the NavigationPath -> Especially if we want to get rid of the index sometime
        guard let view = views.first(where: { onboardingStep == OnboardingStep(fromView: $0) }) else {
            fatalError("Could not find the next to-be-shown view in the Onboarding flow")
        }
        
        return AnyView(view)
    }
    
    public func nextStep() {
        topPathCompontentIndex += 1
        
        Task { @MainActor in
            if views.count <= topPathCompontentIndex {
                complete?.wrappedValue = true
                return
            }
            
            path.append(
                OnboardingStep(fromView: views[topPathCompontentIndex])
            )
        }
    }
    
    public func append(_ onboardingStepType: any View.Type) {
        guard let index = views.firstIndex(where: { onboardingStepType == type(of: $0) }) else {
            fatalError("Could not find the to-be-shown view in the Onboarding flow")
        }
        
        topPathCompontentIndex = index
        
        Task { @MainActor in
            if views.count <= topPathCompontentIndex {
                complete?.wrappedValue = true
                return
            }
            
            path.append(
                OnboardingStep(fromType: onboardingStepType)
            )
        }
    }
    
    public func removeLast(_ k: Int = 1) {
        Task { @MainActor in
            path.removeLast(k)
        }
    }
}
