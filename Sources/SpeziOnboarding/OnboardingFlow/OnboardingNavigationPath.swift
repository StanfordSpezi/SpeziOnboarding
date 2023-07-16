//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

struct OnboardingStep {
    let view: any View
    let step: OnboardingStepIdentifier
    let position: Int?
}

public class OnboardingNavigationPath: ObservableObject {
    @Published var path = NavigationPath()
    private var completeOnboardingPath: [OnboardingStepIdentifier] = []
    
    private var complete: Binding<Bool>?
    
    private var onboardingSteps: [OnboardingStep]
    private var customOnboardingStep: OnboardingStep? = nil
    
    private var currentOnboardingStep: OnboardingStepIdentifier? {
        completeOnboardingPath.reversed().first(where: { !$0.custom })
    }
    
    // New approach
    private var currentOnboardingStep2: OnboardingStepIdentifier? {
        var copyPath = path
        while(!copyPath.isEmpty) {
            guard let lastComponent = try? copyPath.lastComponent else {
                fatalError("Navigation Path Components couldn't be decoded")
            }
            if !lastComponent.custom {
                return lastComponent
            }
            copyPath.removeLast()
        }
        
        // Return first view
        return onboardingSteps[0].step
    }
    
    var firstOnboardingView: AnyView {
        if !onboardingSteps.isEmpty {
            .init(onboardingSteps[0].view)
        } else {
            fatalError("There's no beginning onboarding view")
        }
    }
    
    init(views: [any View], complete: Binding<Bool>?) {
        self.complete = complete
        
        self.onboardingSteps = views.enumerated().map { (index, view) in
            .init(
                view: view,
                step: .init(fromView: view),
                position: index
            )
        }
        
        self.completeOnboardingPath.append(OnboardingStepIdentifier(fromView: views[0]))
    }
    
    func updateViews(with views: [any View]) {
        // Only allow updates on the view stack as long as we're in the first view of the onboarding,
        // allowing developers to use async properties.
        // Without this condition, we would mess up our view stack during the onboarding as e.g. healthkit
        // permissions are given and this triggers a reevaluation of the result builder, meaning the view
        // stack doesnt include the healthkit permissions view afterwards anymore -> hard to keep track of
        if currentOnboardingStep == onboardingSteps.first?.step {
            self.onboardingSteps = views.enumerated().map { (index, view) in
                .init(
                    view: view,
                    step: .init(fromView: view),
                    position: index
                )
            }
        }
    }
    
    // Navigate to the respective onboarding step view
    func navigate(to onboardingStep: OnboardingStepIdentifier) -> AnyView {
        if onboardingStep.custom {
            // Custom view
            guard let view = customOnboardingStep?.view else {
                fatalError("Could not find the next to-be-shown view in the Onboarding flow")
            }
            return AnyView(view)
        } else {
            // Regular onboarding view
            guard let view = onboardingSteps.first(where: { $0.step == onboardingStep })?.view else {
                fatalError("Could not find the next to-be-shown view in the Onboarding flow")
            }
            return AnyView(view)
        }
    }
    
    // Set the path to the next regular onboarding view
    public func nextStep() {
        guard let currentStepIndex = onboardingSteps.firstIndex(where: { $0.step == currentOnboardingStep }),
              currentStepIndex + 1 < onboardingSteps.count else {
            complete?.wrappedValue = true
            return
        }
        
        let onboardingStep = onboardingSteps[currentStepIndex + 1].step
        
        appendToNavigationPath(of: onboardingStep)
    }
    
    // For regular onboarding views
    public func append(_ onboardingStepType: any View.Type) {
        let onboardingStep = OnboardingStepIdentifier(fromType: onboardingStepType)
        // Check if such an onboarding step actually exists
        guard onboardingSteps.contains(where: { $0.step == onboardingStep }) else {
            fatalError("No such Onboarding step! Please check if the passed type reflects an Onboarding view decleared in the OnboardingStack")
        }
        
        appendToNavigationPath(of: onboardingStep)
    }
    
    // For custom onboarding views
    public func append(customView customOnboardingView: any View) {
        let customOnboardingStepIdentifier = OnboardingStepIdentifier(fromView: customOnboardingView, custom: true)
        customOnboardingStep = .init(
            view: customOnboardingView,
            step: customOnboardingStepIdentifier,
            position: nil
        )
        
        appendToNavigationPath(of: customOnboardingStepIdentifier)
    }
    
    // For custom onboarding view types (via init)
    public func append(customViewInit: () -> any View) {
        let view = customViewInit()
        let customOnboardingStepIdentifier = OnboardingStepIdentifier(fromView: view, custom: true)
        
        customOnboardingStep = .init(
            view: view,
            step: customOnboardingStepIdentifier,
            position: nil
        )

        appendToNavigationPath(of: customOnboardingStepIdentifier)
    }
    
    public func removeLast() {
        let _ = completeOnboardingPath.popLast()
        
        Task { @MainActor in
            path.removeLast()
        }
    }
    
    private func appendToNavigationPath(of onboardingStepIdentifier: OnboardingStepIdentifier) {
        completeOnboardingPath.append(onboardingStepIdentifier)
        
        Task { @MainActor in
            path.append(onboardingStepIdentifier)
        }
    }
}

// MARK: - Utilities
extension NavigationPath {
    public enum Error: Swift.Error {
        case nonInspectablePath
    }
    
    /// This is not super efficient, but at least always in sync.
    var lastComponent: OnboardingStepIdentifier? {
        get throws {
            guard !isEmpty else { return nil }
            guard let codable else {
                throw Error.nonInspectablePath
            }
            
            return try JSONDecoder().decode(_LastElementDecoder.self, from: JSONEncoder().encode(codable)).value
        }
    }
    
    /// We use this type to decode the two first encoded components.
    private struct _LastElementDecoder: Decodable {
        var value: OnboardingStepIdentifier
        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            // Type name - not really needed
            let typeName = try container.decode(String.self)
            
            let encodedValue = try container.decode(String.self)
            self.value = try JSONDecoder().decode(OnboardingStepIdentifier.self, from: Data(encodedValue.utf8))
        }
    }
}
