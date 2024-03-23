//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import OrderedCollections
import SwiftUI


/// Describes the current navigation state of a `OnboardingStack`.
///
/// The `OnboardingNavigationPath` wraps SwiftUI's `NavigationPath` and tailors it for the use within the ``OnboardingStack``
/// which provides an easy-to-use interface for creating Onboarding Flows within health applications.
///
/// At the core of the `OnboardingNavigationPath` stands a wrapped `NavigationPath` from SwiftUI.
/// Based on the onboarding views and conditions defined within the ``OnboardingStack``, the ``OnboardingNavigationPath``
/// enables developers to easily navigate through the onboarding procedure
/// without repeated condition checking in every single onboarding view.
///
/// The `OnboardingNavigationPath` is injected as an `Observable` into the Environment of the ``OnboardingStack`` view hierarchy.
/// Resulting from that, all views declared within the ``OnboardingStack`` are able to access a single instance of the `OnboardingNavigationPath`.
///
/// ```swift
/// struct Welcome: View {
///     @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
///
///     var body: some View {
///         OnboardingView(
///             ...,
///             action: {
///                 // Navigates to the next onboarding step, as defined in `OnboardingStack` closure.
///                 onboardingNavigationPath.nextStep()
///
///                 // Navigates to the next onboarding step that matches the provided view type.
///                 onboardingNavigationPath.append(InterestingModules.self)
///
///                 // Navigate to a manually injected view. The `OnboardingNavigationPath` won't be moved and stay at the old position.
///                 onboardingNavigationPath.append(customView: SomeCustomView())
///             }
///         )
///     }
/// }
/// ```
@MainActor
@Observable
public class OnboardingNavigationPath {
    /// Internal SwiftUI `NavigationPath` that serves as the source of truth for the navigation state.
    /// Holds elements of type `OnboardingStepIdentifier` which identify the individual onboarding steps.
    var path = NavigationPath()
    /// Boolean binding that is injected via the ``OnboardingStack``.
    /// Indicates if the onboarding flow is completed, meaning the last view declared within the ``OnboardingStack`` is completed.
    private let complete: Binding<Bool>?

    /// Stores all onboarding views as declared within the ``OnboardingStack`` and keep them in order.
    private var onboardingSteps: OrderedDictionary<OnboardingStepIdentifier, any View> = [:]
    /// Stores all custom onboarding views that are appended to the `OnboardingNavigationPath`
    /// via the ``append(customView:)`` or ``append(customViewInit:)`` instance methods
    private var customOnboardingSteps: [OnboardingStepIdentifier: any View] = [:]

    
    /// ``OnboardingStepIdentifier`` of first view in ``OnboardingStack``.
    /// `nil` if ``OnboardingStack`` is empty.
    private var firstOnboardingStepIdentifier: OnboardingStepIdentifier? {
        if onboardingSteps.elements.isEmpty {
            return nil
        } else {
            return onboardingSteps.elements[0].key
        }
    }

    /// The initial view that is presented to the user.
    ///
    /// The first onboarding view of the `OnboardingNavigationPath.onboardingSteps`.
    ///
    /// In case there isn't a single onboarding view stored within `OnboardingNavigationPath.onboardingSteps`
    /// (meaning the ``NavigationStack`` contains no views after its evaluation),
    /// the property serves an `EmptyView` which is then dismissed immediately as the `OnboardingNavigationPath.complete` property
    /// is automatically set to true.
    var firstOnboardingView: AnyView {
        guard let firstOnboardingStepIdentifier,
              let view = onboardingSteps[firstOnboardingStepIdentifier] else {
            return .init(EmptyView())
        }
        
        return .init(view)
    }
    
    /// Identifier of the current onboarding step that is shown to the user via its associated view.
    ///
    /// Inspects the `OnboardingNavigationPath.path` to determine the current on-top navigation element of the internal SwiftUI `NavigationPath`.
    /// Utilizes the extension of the `NavigationPath` declared within the ``SpeziOnboarding`` package for this functionality.
    ///
    /// In case there isn't a suitable element within the `OnboardingNavigationPath.path`, return the `OnboardingStepIdentifier`
    /// of the first onboarding view.
    private var currentOnboardingStep: OnboardingStepIdentifier? {
        guard let lastElement = path.last(where: { !$0.custom }) else {
            return firstOnboardingStepIdentifier
        }
        
        return lastElement
    }
    
    /// An `OnboardingNavigationPath` represents the current navigation path within the ``OnboardingStack``.
    /// - Parameters:
    ///   - views: SwiftUI `View`s that are declared within the ``OnboardingStack``.
    ///   - complete: An optional SwiftUI `Binding` that is injected by the ``OnboardingStack``.
    ///     Is managed by the ``OnboardingNavigationPath`` to indicate whether the onboarding flow is complete.
    ///   - startAtStep: An optional SwiftUI (Onboarding) `View` type indicating the first to-be-shown step of the onboarding flow.
    init(views: [any View], complete: Binding<Bool>?, startAtStep: (any View.Type)?) {
        self.complete = complete
        updateViews(with: views)

        // If specified, navigate to the first to-be-shown onboarding step
        if let startAtStep {
            append(startAtStep)
        }
    }
    
    
    /// Moves to the next onboarding step.
    ///
    /// An invocation of this function moves the ``OnboardingNavigationPath`` to the
    /// next onboarding step as outlined by the order of views within the ``OnboardingStack``.
    ///
    /// The tracking of the current state of the onboarding flow is done fully automatic by the ``OnboardingNavigationPath``.
    ///
    /// After all onboarding steps have been shown, the injected `complete` `Binding` is set to true indicating that the onboarding flow is completed.
    public func nextStep() {
        guard let currentStepIndex = onboardingSteps.elements.keys.firstIndex(where: { $0 == currentOnboardingStep }),
              currentStepIndex + 1 < onboardingSteps.elements.count else {
            complete?.wrappedValue = true
            return
        }
        
        appendToInternalNavigationPath(
            of: onboardingSteps.elements.keys[currentStepIndex + 1]
        )
    }
    
    /// Moves the navigation path to the view of the provided type.
    ///
    /// This action integrates seamlessly with the ``nextStep()`` function, meaning one can switch between the ``append(_:)`` and ``nextStep()`` function.
    /// It is important to note that the passed parameter type must correspond to a `View` declared within the ``OnboardingStack``.
    /// If not, no movement of the internal `NavigationPath` will be done and a warning will be printed.
    ///
    /// - Parameters:
    ///   - onboardingStepType: The type of the onboarding `View` which should be displayed next. Must be declared within the ``OnboardingStack``.
    public func append(_ onboardingStepType: any View.Type) {
        let onboardingStepIdentifier = OnboardingStepIdentifier(fromType: onboardingStepType)
        guard onboardingSteps.keys.contains(onboardingStepIdentifier) else {
            print("""
            "Warning: Invocation of `OnboardingNavigationPath.append(_:)` with an Onboarding view
            that is not delineated in the `OnboardingStack`. Navigation action is void."
            """)
            return
        }
        
        appendToInternalNavigationPath(of: onboardingStepIdentifier)
    }
    
    /// Moves the navigation path to the custom view.
    ///
    /// - Note: The custom `View` does not have to be declared within the ``OnboardingStack``.
    ///     Resulting from that, the internal state of the ``OnboardingNavigationPath`` is still referencing to the last regular `OnboardingStep`.
    ///
    /// - Parameters:
    ///   - customView: A custom onboarding `View` instance that should be shown next in the onboarding flow.
    ///     It isn't required to declare this view within the ``OnboardingStack``.
    public func append(customView: any View) {
        let customOnboardingStepIdentifier = OnboardingStepIdentifier(fromView: customView, custom: true)
        customOnboardingSteps[customOnboardingStepIdentifier] = customView
        
        appendToInternalNavigationPath(of: customOnboardingStepIdentifier)
    }

    /// Moves the navigation path to the custom identifiable view.
    ///
    /// - Note: The custom identifiable `View` does not have to be declared within the ``OnboardingStack``.
    ///     Resulting from that, the internal state of the ``OnboardingNavigationPath`` is still referencing to the last regular `OnboardingStep`.
    ///
    /// - Parameters:
    ///   - identifiableView: An instance of ``OnboardingIdentifiableView`` that should be shown next in the onboarding flow.
    ///     It isn't required to declare this view within the ``OnboardingStack``.
    public func append(identifiableView: any OnboardingIdentifiableView) {
        let customOnboardingStepIdentifier = OnboardingStepIdentifier(
            fromIdentifiableView: identifiableView,
            custom: true
        )
        customOnboardingSteps[customOnboardingStepIdentifier] = identifiableView

        appendToInternalNavigationPath(of: customOnboardingStepIdentifier)
    }

    /// Removes the last element on top of the navigation path.
    ///
    /// This method allows to manually move backwards within the onboarding navigation flow.
    public func removeLast() {
        path.removeLast()
    }
    
    /// Internal function used to update the onboarding steps within the ``OnboardingNavigationPath`` if the
    /// result builder associated with the ``OnboardingStack`` is reevaluated.
    ///
    /// This may be the case with `async` properties that are stored as a SwiftUI `State` in the respective view.
    ///
    /// - Parameters:
    ///   - views: The updated `View`s from the ``OnboardingStack``.
    func updateViews(with views: [any View]) {
        // Only allow view updates to views ahead of the current onboarding step.
        // Without this limitation, attempts to navigate backwards or dismiss the currently displayed onboarding step
        // (for example, after receiving HealthKit authorizations) could lead to unintended behavior.
        let currentStepIndex = if let currentOnboardingStep {
            onboardingSteps.elements.keys.firstIndex(of: currentOnboardingStep) ?? 0
        } else {
            0
        }

        // Remove all onboarding steps after the current onboarding step
        let nextStepIndex = currentStepIndex + 1
        if nextStepIndex < onboardingSteps.elements.count {
            self.onboardingSteps.removeSubrange(nextStepIndex...)
        }

        for view in views {
            let onboardingStepIdentifier = OnboardingStepIdentifier(fromView: view)
            let stepIsAfterCurrentStep = !self.onboardingSteps.keys.contains(onboardingStepIdentifier)
            guard stepIsAfterCurrentStep else {
                continue
            }

            guard self.onboardingSteps[onboardingStepIdentifier] == nil else {
                preconditionFailure("""
                    SpeziOnboarding: Duplicate Onboarding step of type `\(onboardingStepIdentifier.onboardingStepType)` identified.
                    Ensure unique Onboarding view instances within the `OnboardingStack`!
                    """)
            }

            self.onboardingSteps[onboardingStepIdentifier] = view
        }
        onboardingComplete()
    }
    
    /// Internal function used to navigate to the respective onboarding `View` via the `NavigationStack.navigationDestination(for:)`,
    /// either regularly declared within the ``OnboardingStack`` or custom steps
    /// passed via ``append(customView:)`` /``append(customViewInit:)``, identified by the `OnboardingStepIdentifier`.
    ///
    /// - Parameters:
    ///   - onboardingStep: The onboarding step identified via `OnboardingStepIdentifier`
    /// - Returns: `View` corresponding to the passed `OnboardingStepIdentifier`
    func navigate(to onboardingStep: OnboardingStepIdentifier) -> AnyView {
        if onboardingStep.custom {
            guard let view = customOnboardingSteps[onboardingStep] else {
                return AnyView(IllegalOnboardingStepView())
            }
            return AnyView(view)
        }
        
        guard let view = onboardingSteps[onboardingStep] else {
            return AnyView(IllegalOnboardingStepView())
        }
        return AnyView(view)
    }
    
    private func appendToInternalNavigationPath(of onboardingStepIdentifier: OnboardingStepIdentifier) {
        path.append(onboardingStepIdentifier)
    }
    
    private func onboardingComplete() {
        if self.onboardingSteps.isEmpty && !(self.complete?.wrappedValue ?? false) {
            self.complete?.wrappedValue = true
        }
    }
}
