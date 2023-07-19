//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

/// The ``OnboardingNavigationPath`` represents one of the main components of the ``SpeziOnboarding`` package. It wraps SwiftUI's `NavigationPath` and tailors it for the use within the ``OnboardingStack`` which provides an easy-to-use interface for creating Onboarding Flows within health applications.
///
/// At the core of the ``OnboardingNavigationPath`` stands a wrapped `NavigationPath` from SwiftUI which holds path elements of type `OnboardingStep.Identifier`. Based on the onboarding views and conditions defined within the ``OnboardingStack``, the ``OnboardingNavigationPath`` enables developers to easily navigate through the onboarding procedure without repeated condition checking in every single onboarding view.
///
/// The ``OnboardingNavigationPath`` is injeceted as a SwiftUI `EnvironmentObject` into the ``OnboardingStack`` view hierachy. Resulting from that, all views declared within the ``OnboardingStack`` are able to access a single instance of the ``OnboardingNavigationPath``.
///
/// ```swift
/// struct Welcome: View {
///     @EnvironmentObject private var onboardingNavigationPath: OnboardingNavigationPath
///
///     var body: some View {
///         OnboardingView(
///             ...,
///             action: {
///                 // Automatically navigates to the next `OnboardingStep`, as outlined by the order of views within the `OnboardingStack`
///                 onboardingNavigationPath.nextStep()
///
///                 // Manually navigates to an onboarding view identified by it's static type which is declared within the `OnboardingStack`. After this manual navigation step, the `OnboardingNavigationPath` will continue in the declared onboarding order from the `OnboardingStack`.
///                 onboardingNavigationPath.append(InterestingModules.self)
///             }
///         )
///     }
/// }
/// ```
public class OnboardingNavigationPath: ObservableObject {
    /// Internal SwiftUI `NavigationPath` that serves as the source of truth for the navigation state.
    /// Holds elements of type `OnboardingStep.Identifier` which identify the individual onboarding steps.
    @Published var path: NavigationPath
    /// Boolean binding that is injected via the ``OnboardingStack``.
    /// Indicates if the onboarding flow is completed, meaning the last view declared within the ``OnboardingStack`` is completed.
    private var complete: Binding<Bool>?
    
    /// Stores all `OnboardingStep`s in-order as declared by the onboarding views within the ``OnboardingStack``.
    private var onboardingSteps: [OnboardingStep]
    /// Holds a custom onboarding step that is appended to the ``OnboardingNavigationPath`` via the ``append(customView:)`` or ``append(customViewInit:)`` instance methods
    private var customOnboardingStep: OnboardingStep? = nil
    
    /// The first onboarding view of the `OnboardingNavigationPath.onboardingSteps`. Serves as a starting point for the SwiftUI `NavigationStack`.
    ///
    /// In case there isn't a single onboarding view stored within `OnboardingNavigationPath.onboardingSteps` (meaning the ``NavigationStack`` contains no views after its evaluation), the property serves an `EmptyView` which is then dismissed immediatly as the `OnboardingNavigationPath.complete` property is automatically set to true.
    var firstOnboardingView: AnyView {
        if !onboardingSteps.isEmpty {
            .init(onboardingSteps[0].view)
        } else {
            .init(EmptyView())
        }
    }
    
    /// Identifier of the current onboarding step that is shown to the user via its associated view
    /// Inspects the `OnboardingNavigationPath.path` to determine the current on-top navigation element of the internal SwiftUI `NavigationPath`.
    /// Utilizes the extenstion of the `NavigationPath` declared within the ``SpeziOnboarding`` package for this functionality.
    ///
    /// In case there isn't a suitable element within the `OnboardingNavigationPath.path`, return the `OnboardingStep.Identifier` of the first onboarding view.
    private var currentOnboardingStep: OnboardingStep.Identifier? {
        var copyPath = path
        while(!copyPath.isEmpty) {
            guard let lastElement = copyPath.lastElement else {
                return nil
            }
            
            if !lastElement.custom {
                return lastElement
            }
            copyPath.removeLast()
        }
        
        return onboardingSteps.first?.step
    }
    
    /// A ``OnboardingNavigationPath`` represents the current navigation path within the ``OnboardingStack``.
    /// - Parameters:
    ///   - views: SwiftUI `View`s that are declaredxx within the ``OnboardingStack``.
    ///   - complete: A SwiftUI `Binding` that is injected to the ``OnboardingStack``. Is managed by the ``OnboardingNavigationPath`` to indicate wheather the onboarding flow is complete.
    init(views: [any View], complete: Binding<Bool>?) {
        self.onboardingSteps = views.map { view in
            .init(
                view: view,
                step: .init(fromView: view)
            )
        }
        self.complete = complete
        
        self.path = NavigationPath()
    }
    
    
    /// An invocation of this function moves the internal `NavigationPath` of the ``OnboardingNavigationPath`` to the next onboarding step as outlined by the order of views within the ``OnboardingStack``. The tracking of the current state of the onboarding flow is done fully automatic by the ``OnboardingNavigationPath``.
    /// After all onboarding steps have been shown, the injected `complete` `Binding` is set to true indicating that the onboarding flow is completed.
    public func nextStep() {
        guard let currentStepIndex = onboardingSteps.firstIndex(where: { $0.step == currentOnboardingStep }),
              currentStepIndex + 1 < onboardingSteps.count else {
            complete?.wrappedValue = true
            return
        }
        
        appendToInternalNavigationPath(
            of: onboardingSteps[currentStepIndex + 1].step
        )
    }
    
    
    /// Moves the internal `NavigationPath` of the ``OnboardingNavigationPath`` to the onboarding step described by the passed parameter.
    /// This action integrates seamlessly with the ``nextStep()`` function, meaning one can switch between the ``append(_:)`` and ``nextStep()`` function.
    /// It is important to note that the passed parameter type must correspond to a `View` declared within the ``OnboardingStack``. If not, no movement of the internal `NavigationPath` will be done and a warning will be printed.
    ///
    /// - Parameters:
    ///   - onboardingStepType: The type of the onboarding `View` which should be displayed next. Must be declared within the ``OnboardingStack``.
    public func append(_ onboardingStepType: any View.Type) {
        let onboardingStep = OnboardingStep.Identifier(fromType: onboardingStepType)
        guard onboardingSteps.contains(where: { $0.step == onboardingStep }) else {
            print("Warning: Parameter passed to OnboardingNavigationPath.append(_:) doesn't correspond to an Onboarding step outlined in the OnboardingStack! Please make sure that the passed type reflects an Onboarding view decleared in the OnboardingStack!")
            return
        }
        
        appendToInternalNavigationPath(of: onboardingStep)
    }
    
    
    /// An invocation of this function moves the internal `NavigationPath` of the ``OnboardingNavigationPath`` to the passed custom onboarding `View` instance. Keep in mind that this custom `View` does not have to be declared within the ``OnboardingStack``. Resulting from that, the internal state of the ``OnboardingNavigationPath`` is still referencing to the last regular `OnboardingStep`.
    /// This function is closly related to ``append(customViewInit:)``.
    ///
    /// - Parameters:
    ///   - customView: A custom onboarding `View` instance that should be shown next in the onboarding flow. It isn't required to declare this view within the ``OnboardingStack``.
    public func append(customView: any View) {
        let customOnboardingStepIdentifier = OnboardingStep.Identifier(fromView: customView, custom: true)
        customOnboardingStep = .init(
            view: customView,
            step: customOnboardingStepIdentifier
        )
        
        appendToInternalNavigationPath(of: customOnboardingStepIdentifier)
    }
    
    
    /// An invocation of this function moves the internal `NavigationPath` of the ``OnboardingNavigationPath`` to the passed custom onboarding `View` initializer. Keep in mind that this custom `View` does not have to be declared within the ``OnboardingStack``. Resulting from that, the internal state of the ``OnboardingNavigationPath`` is still referencing to the last regular `OnboardingStep`.
    /// This function is closly related to ``append(customView:)``.
    ///
    /// - Parameters:
    ///   - customViewInit: A custom onboarding `View` initializer that creates a `View` shown next in the onboarding flow. It isn't required to declare this view within the ``OnboardingStack``.
    public func append(customViewInit: () -> any View) {
        let view = customViewInit()
        let customOnboardingStepIdentifier = OnboardingStep.Identifier(fromView: view, custom: true)
        
        customOnboardingStep = .init(
            view: view,
            step: customOnboardingStepIdentifier
        )

        appendToInternalNavigationPath(of: customOnboardingStepIdentifier)
    }
    
    
    /// Removes the last element on top of the internal `NavigationPath` of the ``OnboardingNavigationPath``, meaning one is able to manually move backwards within the onboarding navigation flow.
    public func removeLast() {
        Task { @MainActor in
            path.removeLast()
        }
    }
    
    
    /// Internal function used to update the onboarding steps within the ``OnboardingNavigationPath`` if the result builder associated with the ``OnboardingStack`` is reevaluated. This may be the case with `async` properties that are stored as a SwiftUI `State` in the respective view.
    ///
    /// - Parameters:
    ///   - with: The updated `View`s from the ``OnboardingStack``.
    func updateViews(with views: [any View]) {
        /// Only allow view updates as long as the first onboarding view is shown.
        /// Without this condition, the stored onboarding steps would continue to be updated when conditionals declared within the ``OnboardingStack`` change their outcome during the onboarding flow (e.g. when HealthKit permissions are granted during the onboarding), making it hard to keep track of the internal state of the navigation.
        if currentOnboardingStep == onboardingSteps.first?.step {
            self.onboardingSteps = views.map { view in
                .init(
                    view: view,
                    step: .init(fromView: view)
                )
            }
            
            onboardingComplete()
        }
    }
    
    
    /// Internal function used to navigate to the respective onboarding `View` via the `NavigationStack.navigationDestination(for:)`, either regularly declared within the ``OnboardingStack`` or custom steps passed via ``append(customView:)`` /``append(customViewInit:)``. identified by the `OnboardingStep.Identifier`.
    ///
    /// - Parameters:
    ///   - to: The onboarding step identified via `OnboardingStep.Identifier`
    /// - Returns: `View` corresponding to the passed `OnboardingStep.Identifier`
    func navigate(to onboardingStep: OnboardingStep.Identifier) -> AnyView {
        if onboardingStep.custom {
            guard let view = customOnboardingStep?.view else {
                return AnyView(IllegalOnboardingStepView())
            }
            return AnyView(view)
        }
        
        guard let view = onboardingSteps.first(where: { $0.step == onboardingStep })?.view else {
            return AnyView(IllegalOnboardingStepView())
        }
        return AnyView(view)
    }
    
    
    private func appendToInternalNavigationPath(of onboardingStepIdentifier: OnboardingStep.Identifier) {
        Task { @MainActor in
            path.append(onboardingStepIdentifier)
        }
    }
    
    
    private func onboardingComplete() {
        Task {
            if self.onboardingSteps.isEmpty && !(self.complete?.wrappedValue ?? false) {
                self.complete?.wrappedValue = true
            }
        }
    }
}
