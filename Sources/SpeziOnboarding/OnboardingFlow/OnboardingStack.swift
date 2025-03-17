//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import OSLog
import SwiftUI


/// Managed Navigation Stack of Onboarding Views.
///
/// The `OnboardingStack` wraps a SwiftUI `NavigationStack` and provides an easy to use API to declare the onboarding steps of health applications,
/// eliminating the need for developers to manually determine the next to be shown step within each onboarding view (e.g. skipped steps as permissions are already granted).
/// All of the (conditional) onboarding views are stated within the `OnboardingStack` from which the order of the onboarding flow is determined.
///
/// Navigation within the `OnboardingStack` is possible via the ``OnboardingNavigationPath`` which works similar to SwiftUI's `NavigationPath`.
/// The ``OnboardingNavigationPath``'s ``OnboardingNavigationPath/nextStep()``, ``OnboardingNavigationPath/appendStep(_:)-1ndu9``,
/// and ``OnboardingNavigationPath/moveToNextStep(ofType:)`` functions can be used to programmatically navigate within the stack.
/// Furthermore, one can append custom onboarding steps that are not declared within the  `OnboardingStack`
/// (e.g. as the structure of these steps isn't linear) via ``OnboardingNavigationPath/append(customView:)``.
/// See the ``OnboardingNavigationPath`` for more details.
///
/// The ``OnboardingNavigationPath`` is injected as an `Observable` into the environment of the `OnboardingStack` view hierarchy.
/// Resulting from that, all views declared within the `OnboardingStack` are able to access a single instance of the ``OnboardingNavigationPath``.
///
/// ```swift
/// struct Onboarding: View {
///     @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
///     @State private var localNotificationAuthorization = false
///
///     var body: some View {
///         OnboardingStack(onboardingFlowComplete: $completedOnboardingFlow) {
///             Welcome()
///             InterestingModules()
///
///             if HKHealthStore.isHealthDataAvailable() {
///                 HealthKitPermissions()
///             }
///
///             if !localNotificationAuthorization {
///                 NotificationPermissions()
///             }
///         }
///         .task {
///             localNotificationAuthorization = await ...
///         }
///     }
/// }
/// ```
///
/// ### Identifying Onboarding Views
///
/// Apply the ``SwiftUICore/View/onboardingIdentifier(_:)`` modifier to clearly identify a view in the `OnboardingStack`.
/// This is particularly useful in scenarios where multiple instances of the same view type might appear in the stack.
///
/// ```swift
/// struct Onboarding: View {
///     @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
///
///     var body: some View {
///         OnboardingStack(onboardingFlowComplete: $completedOnboardingFlow) {
///             MyOwnView()
///                 .onboardingIdentifier("my-own-view-1")
///             MyOwnView()
///                 .onboardingIdentifier("my-own-view-2")
///             // Other views as needed
///         }
///     }
/// }
/// ```
///
/// - Note: When the ``SwiftUICore/View/onboardingIdentifier(_:)`` modifier is applied multiple times to the same view, the outermost identifier takes precedence.
///
/// ## Topics
/// ### Creating an Onboarding Stack
/// - ``init(onboardingFlowComplete:path:startAtStep:_:)-3fn08``
/// - ``init(onboardingFlowComplete:path:startAtStep:_:)-39lmr``
/// - ``OnboardingFlowBuilder``
/// ### SwiftUI Environment Values
/// - ``SwiftUICore/EnvironmentValues/isInOnboardingStack``
public struct OnboardingStack: View {
    static let logger = Logger(subsystem: "edu.stanford.spezi.onboarding", category: "OnboardingStack")
    
    private let onboardingFlow: _OnboardingFlowViewCollection
    private let isComplete: Binding<Bool>?
    private let startAtStep: OnboardingNavigationPath.StepReference?
    private var externalPath: OnboardingNavigationPath?
    @State private var internalPath = OnboardingNavigationPath()
    
    /// The effective ``OnboardingNavigationPath``
    var path: OnboardingNavigationPath {
        externalPath ?? internalPath
    }
    
    /// The ``OnboardingStack/body`` contains a SwiftUI `NavigationStack` that is responsible for the navigation between
    /// the different onboarding views via an ``OnboardingNavigationPath``.
    public var body: some View {
        @Bindable var path = path
        NavigationStack(path: $path.path) {
            path.firstOnboardingView
                .padding(.top, 24)
                .environment(\.isInOnboardingStack, true)
                .navigationDestination(for: OnboardingStepIdentifier.self) { step in
                    path.view(for: step)
                        .environment(\.isInOnboardingStack, true)
                }
        }
        .environment(path)
        .onChange(of: ObjectIdentifier(onboardingFlow)) {
            // ensure the model uses the latest views from the initializer
            path.updateViews(with: onboardingFlow.elements)
        }
    }
    
    private init(
        onboardingFlowComplete: Binding<Bool>? = nil, // swiftlint:disable:this function_default_parameter_at_end
        path externalPath: OnboardingNavigationPath? = nil, // swiftlint:disable:this function_default_parameter_at_end
        startAtStep: OnboardingNavigationPath.StepReference?,
        @OnboardingFlowBuilder _ content: @MainActor () -> _OnboardingFlowViewCollection
    ) {
        onboardingFlow = content()
        isComplete = onboardingFlowComplete
        self.externalPath = externalPath
        self.startAtStep = startAtStep
        if !path.didConfigure {
            // Note: we intentionally perform the initial configuration in here, instead of in the init.
            // The reason for this is that calling path.configure in the init will, for some reason, cause
            // a neverending loop of view updates when using an external path. Calling it in here does not.
            configurePath()
        }
    }
    
    /// A `OnboardingStack` is defined by the passed in views defined by the view builder as well as an boolean `Binding`
    /// that is set to true when the onboarding flow is completed.
    /// - Parameters:
    ///   - onboardingFlowComplete: An optional SwiftUI `Binding` that is automatically set to true by
    ///     the ``OnboardingNavigationPath`` once the onboarding flow is completed.
    ///     Can be used to conditionally show/hide the `OnboardingStack`.
    ///   - externalPath: An optional, externally-managed ``OnboardingNavigationPath`` which will be used by this view.
    ///       Only specify this if you actually need external control over the path; otherwise omit it to get the recommended default behaviour.
    ///   - startAtStep: An optional SwiftUI (Onboarding) `View` type indicating the first to-be-shown step of the onboarding flow.
    ///   - content: The SwiftUI (Onboarding) `View`s that are part of the onboarding flow.
    ///     You can define the `View`s using the ``OnboardingFlowBuilder``.
    public init(
        onboardingFlowComplete: Binding<Bool>? = nil,
        path externalPath: OnboardingNavigationPath? = nil,
        startAtStep: (any View.Type)? = nil,
        @OnboardingFlowBuilder _ content: @MainActor () -> _OnboardingFlowViewCollection
    ) {
        self.init(
            onboardingFlowComplete: onboardingFlowComplete,
            path: externalPath,
            startAtStep: startAtStep.map { .viewType($0) },
            content
        )
    }
    
    /// A `OnboardingStack` is defined by the passed in views defined by the view builder as well as an boolean `Binding`
    /// that is set to true when the onboarding flow is completed.
    /// - Parameters:
    ///   - onboardingFlowComplete: An optional SwiftUI `Binding` that is automatically set to true by
    ///     the ``OnboardingNavigationPath`` once the onboarding flow is completed.
    ///     Can be used to conditionally show/hide the `OnboardingStack`.
    ///   - externalPath: An optional, externally-managed ``OnboardingNavigationPath`` which will be used by this view.
    ///       Only specify this if you actually need external control over the path; otherwise omit it to get the recommended default behaviour.
    ///   - startAtStep: An optional SwiftUI (Onboarding) `View` type indicating the first to-be-shown step of the onboarding flow.
    ///   - content: The SwiftUI (Onboarding) `View`s that are part of the onboarding flow.
    ///     You can define the `View`s using the ``OnboardingFlowBuilder``.
    public init(
        onboardingFlowComplete: Binding<Bool>? = nil, // swiftlint:disable:this function_default_parameter_at_end
        path externalPath: OnboardingNavigationPath? = nil, // swiftlint:disable:this function_default_parameter_at_end
        startAtStep: (any Hashable)?,
        @OnboardingFlowBuilder _ content: @MainActor () -> _OnboardingFlowViewCollection
    ) {
        self.init(
            onboardingFlowComplete: onboardingFlowComplete,
            path: externalPath,
            startAtStep: startAtStep.map { .identifier($0) },
            content
        )
    }
    
    private func configurePath() {
        path.configure(elements: onboardingFlow.elements, isComplete: isComplete, startAtStep: startAtStep)
    }
}


extension EnvironmentValues {
    /// Whether the view is currently contained within an ``OnboardingStack``.
    ///
    /// - Note: Don't set this value manually; ``OnboardingStack`` will set it for you where applicable.
    @Entry public var isInOnboardingStack: Bool = false
}


#if DEBUG
#Preview {
    @Previewable @State var path = OnboardingNavigationPath()
    
    OnboardingStack(path: path, startAtStep: 1) {
        Button("Next") {
            path.nextStep()
        }
        .navigationTitle("First Step")
        .onboardingIdentifier(0)
        Button("Next") {
            path.nextStep()
        }
        .navigationTitle("Second Step")
        .onboardingIdentifier(1)
    }
}
#endif
