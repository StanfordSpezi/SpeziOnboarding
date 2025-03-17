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


// MARK: OnboardingNavigationPath

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
///
/// ## Topics
/// - ``init()``
/// ### Navigating
/// - ``nextStep()``
/// - ``appendStep(_:)-1ndu9``
/// - ``appendStep(_:)-6x3z0``
/// - ``moveToNextStep(ofType:)``
/// - ``moveToNextStep(withIdentifier:)``
/// - ``removeLast()``
@MainActor
@Observable
public class OnboardingNavigationPath {
    enum StepReference {
        case viewType(any View.Type)
        case identifier(any Hashable)
    }
    
    /// The actual path of onboarding steps currently presented.
    var path: [OnboardingStepIdentifier] = [] {
        didSet {
            // Remove dismissed custom steps when navigating backwards
            let removedSteps = oldValue.filter { !path.contains($0) }
            for step in removedSteps where step.isCustom {
                customOnboardingSteps.removeValue(forKey: step)
            }
        }
    }
    /// Boolean binding that is injected via the ``OnboardingStack``.
    /// Indicates if the onboarding flow is completed, meaning the last view declared within the ``OnboardingStack`` is completed.
    private var isComplete: Binding<Bool>?

    /// Stores all onboarding views as declared within the ``OnboardingStack`` and keep them in order.
    private var onboardingSteps: OrderedDictionary<OnboardingStepIdentifier, any View> = [:]
    /// Stores all custom onboarding views that are appended to the `OnboardingNavigationPath`
    /// via the ``append(customView:)``  instance methods
    private var customOnboardingSteps: [OnboardingStepIdentifier: any View] = [:]
    /// Indicates whether the Path's ``OnboardingNavigationPath/configure`` function has been called at least once.
    private(set) var didConfigure = false


    /// ``OnboardingStepIdentifier`` of first view in ``OnboardingStack``.
    /// `nil` if ``OnboardingStack`` is empty.
    internal var firstOnboardingStepIdentifier: OnboardingStepIdentifier? {
        onboardingSteps.elements.first?.key
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
        guard let lastElement = path.last(where: { !$0.isCustom }) else {
            return firstOnboardingStepIdentifier
        }
        return lastElement
    }
    
    /// Creates an empty, unconfigured `OnboardingNavigationPath`.
    ///
    /// This initializer is intended for creating empty, unconfigured `OnboardingNavigationPaths` which are then injected into an ``OnboardingStack``.
    public init() {}
    
    
    /// An `OnboardingNavigationPath` represents the current navigation path within the ``OnboardingStack``.
    /// - Parameters:
    ///   - views: SwiftUI `View`s that are declared within the ``OnboardingStack``.
    ///   - isComplete: An optional SwiftUI `Binding` that is injected by the ``OnboardingStack``.
    ///     Is managed by the ``OnboardingNavigationPath`` to indicate whether the onboarding flow is complete.
    ///   - startAtStep: Optionally, the step the OnboardingNavigationPath should initially move to.
    func configure(elements: [_OnboardingFlowViewCollection.Element], isComplete: Binding<Bool>?, startAtStep: StepReference?) {
        didConfigure = true
        self.isComplete = isComplete
        updateViews(with: elements)
        // If specified, navigate to the first to-be-shown onboarding step
        switch startAtStep {
        case nil:
            break
        case .viewType(let viewType):
            appendStep(viewType)
        case .identifier(let hashable):
            appendStep(hashable)
        }
    }
    
    
    /// Internal function used to update the onboarding steps within the ``OnboardingNavigationPath`` if the
    /// result builder associated with the ``OnboardingStack`` is reevaluated.
    ///
    /// This may be the case with `async` properties that are stored as a SwiftUI `State` in the respective view.
    ///
    /// - Parameters:
    ///   - views: The updated `View`s from the ``OnboardingStack``.
    func updateViews(with elements: [_OnboardingFlowViewCollection.Element]) {
        do {
            // Ensure that the incoming navigation stack elements are all unique.
            // Note: we don't need to worry about collisions between OnboardingFlow-provided
            // views and manually-added custom views, since the non-custom ones will
            // always also be identified by their source location, which is never the case for the custom ones.
            var identifiersSeenSoFar = Set<OnboardingStepIdentifier>()
            for element in elements {
                let identifier = OnboardingStepIdentifier(element: element)
                guard identifiersSeenSoFar.insert(identifier).inserted else {
                    let conflictingIdentifier = identifiersSeenSoFar.first(where: { $0 == identifier })
                    preconditionFailure("""
                        SpeziOnboarding: OnboardingStack contains elements with duplicate onboarding step identifiers.
                        This is invalid. If your OnboardingStack contains multiple instances of the same View type,
                        use the 'onboardingIdentifier(_:)' View modifier to uniquely identify it within the Stack.
                        Problematic identifier: \(identifier).
                        Conflicting identifier: \(conflictingIdentifier as Any)
                        """)
                }
            }
        }
        // Only allow view updates to views ahead of the current onboarding step.
        // Without this limitation, attempts to navigate backwards or dismiss the currently displayed onboarding step
        // (for example, after receiving HealthKit authorizations) could lead to unintended behavior.
        // Note: This approach isn't perfect. Imaging we're at step 5 in the OnboardingStack, and some condition in the
        // view changes and we remove step 3 from the OnboardingFlow. In this case, we won't actually remove it from the Stack,
        // since we're at a later step and removing step 3 while being at step 5 is not a good idea.
        // But now if you return to step 1, and then start going forward again, it still will include step 3.
        // We might want to keep track of such situations, and re-apply the changes when the Stack navigates back?
        let currentStepIndex = currentOnboardingStep.flatMap {
            onboardingSteps.elements.keys.firstIndex(of: $0)
        } ?? 0
        // Remove all onboarding steps after the current onboarding step
        let nextStepIndex = currentStepIndex + 1
        if nextStepIndex < onboardingSteps.elements.endIndex {
            onboardingSteps.removeSubrange(nextStepIndex...)
        }
        for element in elements {
            let identifier = OnboardingStepIdentifier(element: element)
            let stepIsAfterCurrentStep = !onboardingSteps.keys.contains(identifier)
            guard stepIsAfterCurrentStep else {
                continue
            }
            if let conflictingIdentifier = onboardingSteps.keys.first(where: { $0 == identifier }) {
                // We need the check again in here, since there might also be collisions between
                // the part of the incoming steps we integrate into the view and the existing,
                // already-visited steps we keep around.
                preconditionFailure("""
                    SpeziOnboarding: OnboardingStack contains elements with duplicate onboarding step identifiers.
                    This is invalid. If your OnboardingStack contains multiple instances of the same View type,
                    use the 'onboardingIdentifier(_:)' View modifier to uniquely identify it within the Stack.
                    Problematic identifier: \(identifier).
                    Conflicting identifier: \(conflictingIdentifier)
                    """)
            }
            onboardingSteps[identifier] = element.view
        }
        onboardingComplete()
    }
    
    
    private func onboardingComplete() {
        if self.onboardingSteps.isEmpty && !(self.isComplete?.wrappedValue ?? false) {
            self.isComplete?.wrappedValue = true
        }
    }
}


// MARK: Navigation

extension OnboardingNavigationPath {
    /// Internal function used to navigate to the respective onboarding `View` via the `NavigationStack.navigationDestination(for:)`,
    /// either regularly declared within the ``OnboardingStack`` or custom steps
    /// passed via ``append(customView:)``, identified by the `OnboardingStepIdentifier`.
    ///
    /// - Parameters:
    ///   - stepIdentifier: The onboarding step identified via `OnboardingStepIdentifier`
    /// - Returns: `View` corresponding to the passed `OnboardingStepIdentifier`
    func view(for stepIdentifier: OnboardingStepIdentifier) -> AnyView {
        if stepIdentifier.isCustom {
            guard let view = customOnboardingSteps[stepIdentifier] else {
                return AnyView(IllegalOnboardingStepView())
            }
            return AnyView(view)
        }
        guard let view = onboardingSteps[stepIdentifier] else {
            return AnyView(IllegalOnboardingStepView())
        }
        return AnyView(view)
    }
    
    /// Pushes an ``OnboardingStepIdentifier`` onto the stack.
    private func pushStep(identifiedBy identifier: OnboardingStepIdentifier) {
        path.append(identifier)
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
            isComplete?.wrappedValue = true
            return
        }
        pushStep(identifiedBy: onboardingSteps.elements.keys[currentStepIndex + 1])
    }
    
    /// Move the path.
    @_documentation(visibility: internal)
    @available(*, deprecated, renamed: "appendStep(_:)")
    public func append(_ stepType: any View.Type) {
        appendStep(stepType)
    }
    
    /// Moves the navigation path to the first onboarding step with a view matching the specified type.
    ///
    /// This action integrates seamlessly with the ``nextStep()`` function, meaning one can switch between the ``append(_:)`` and ``nextStep()`` function.
    ///
    /// - Important: The specified parameter type must correspond to a `View` type declared within the ``OnboardingStack``. Otherwise, this function will have no effect.
    ///
    /// - Note: When using this function to append a step, any intermediate steps between the current step and the step being moved to will be skipped, and won't be added to the navigation path.
    ///     Use ``moveToNextStep(ofType:)`` instead if you want intermediate steps to be included.
    ///
    /// - Parameters:
    ///   - onboardingStepType: The type of the onboarding `View` which should be displayed next. Must be declared within the ``OnboardingStack``.
    public func appendStep(_ stepType: any View.Type) {
        moveToNextStep(identifiedBy: .viewType(stepType), includeIntermediateSteps: false)
    }
    
    /// Moves the navigation path to the first onboarding step matching the identifier `id`.
    ///
    /// This action integrates seamlessly with the ``nextStep()`` function, meaning one can switch between the ``append(_:)`` and ``nextStep()`` function.
    ///
    /// - Important: The specified parameter type must correspond to a `View` type declared within the ``OnboardingStack``. Otherwise, this function will have no effect.
    ///
    /// - Note: When using this function to append a step, any intermediate steps between the current step and the step being moved to will be skipped, and won't be added to the navigation path.
    ///     Use ``moveToNextStep(withIdentifier:)`` instead if you want intermediate steps to be included.
    ///
    /// - Parameters:
    ///   - id: The identifier of the onboarding step to move to.
    public func appendStep(_ id: some Hashable) {
        moveToNextStep(identifiedBy: .identifier(id), includeIntermediateSteps: false)
    }
    
    /// Modifies the navigation path to move to the first onboarding step of the specified type, and also add all steps inbetween.
    public func moveToNextStep(ofType type: any View.Type) {
        moveToNextStep(identifiedBy: .viewType(type), includeIntermediateSteps: true)
    }
    
    /// Modifies the navigation path to move to the first onboarding step identified by the specified value, and also add all steps inbetween.
    public func moveToNextStep(withIdentifier id: some Hashable) {
        moveToNextStep(identifiedBy: .identifier(id), includeIntermediateSteps: true)
    }
    
    /// Modifies the navigation path to move to the next onboarding step identified by the specified value, and also add all steps inbetween.
    ///
    /// This function will look at all onboarding steps after the current step, identify the first one that matches `stepRef`,
    /// and push all steps between the current step and that step onto the stack (including, of course, the step matching `stepRef`).
    ///
    /// If no step matching `stepRef` exists, this function will have no effect.
    ///
    /// - Note: If `stepRef` is a `View` type, this function will navigate to the first step (following the current step) with a matching view type,
    ///     even if that step is also using a custom identifier. If there are multiple steps with this type, and you want to select a step other than the first one,
    ///     use an explicit identifier for matching instead.
    private func moveToNextStep(identifiedBy stepRef: StepReference, includeIntermediateSteps: Bool) {
        let currentOnboardingIndex = currentOnboardingStep.flatMap {
            onboardingSteps.keys.firstIndex(of: $0)
        } ?? 0
        guard let stepIdentifierIdx = onboardingSteps.keys[currentOnboardingIndex...].firstIndex(where: { stepIdentifier in
            guard !stepIdentifier.isCustom else {
                return false
            }
            switch (stepRef, stepIdentifier.identifierKind) {
            case (.viewType(let type), _):
                return stepIdentifier.viewType == type
            case let (.identifier(valueA), .identifiable(valueB)):
                return valueA.isEqual(valueB)
            case (.identifier, .viewTypeAndSourceLoc):
                return false
            }
        }) else {
            OnboardingStack.logger.error("Unable to find OnboardingStack step with identifier '\(String(describing: stepRef))'")
            return
        }
        if includeIntermediateSteps {
            path = Array(onboardingSteps.keys[...stepIdentifierIdx].dropFirst())
        } else {
            path.append(onboardingSteps.keys[stepIdentifierIdx])
        }
    }
    
    
    /// Moves the navigation path to the custom view.
    ///
    /// - Note: The custom `View` does not have to be declared within the ``OnboardingStack``.
    ///     Resulting from that, the internal state of the ``OnboardingNavigationPath`` is still referencing to the last regular `OnboardingStep`.
    ///
    /// - Parameters:
    ///   - customView: A custom onboarding `View` instance that should be shown next in the onboarding flow.
    ///     It isn't required to declare this view within the ``OnboardingStack``.
    public func append(customView: some View) {
        let customOnboardingStepIdentifier = OnboardingStepIdentifier(
            element: .init(view: customView, sourceLocation: nil)
        )
        customOnboardingSteps[customOnboardingStepIdentifier] = customView
        pushStep(identifiedBy: customOnboardingStepIdentifier)
    }
    
    /// Removes the last element on top of the navigation path.
    ///
    /// This method allows to manually move backwards within the onboarding navigation flow.
    public func removeLast() {
        path.removeLast()
    }
}
