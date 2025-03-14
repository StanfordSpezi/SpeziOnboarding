//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// Navigation Stack of Onboarding Views.
///
/// The `OnboardingStack` wraps a SwiftUI `NavigationStack` and provides an easy to use API to declare the onboarding steps of health applications,
/// eliminating the need for developers to manually determine the next to be shown step within each onboarding view (e.g. skipped steps as permissions are already granted).
/// All of the (conditional) onboarding views are stated within the `OnboardingStack` from which the order of the onboarding flow is determined.
///
/// Navigation within the `OnboardingStack` is possible via the ``OnboardingNavigationPath`` which works quite similar to the SwiftUI `NavigationPath`.
/// It automatically navigates to the next to-be-shown onboarding step via ``OnboardingNavigationPath/nextStep()`` or manually via  ``OnboardingNavigationPath/append(_:)``.
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
public struct OnboardingStack: View {
    private let onboardingFlow: _OnboardingFlowViewCollection
    private let isComplete: Binding<Bool>?
    private let startAtStep: (any View.Type)?
    private var externalPath: OnboardingNavigationPath?
    @State private var didRunInitialConfig = false
    @State private var internalPath = OnboardingNavigationPath()
    
    /// The effective ``OnboardingNavigationPath``
    private var path: OnboardingNavigationPath {
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
                    path.navigate(to: step)
                        .environment(\.isInOnboardingStack, true)
                }
        }
        .environment(path)
        .onChange(of: ObjectIdentifier(onboardingFlow), initial: true) {
            if !didRunInitialConfig {
                // Note: we intentionally perform the initial configuration in here, instead of in the init.
                // The reason for this is that calling path.configure in the init will, for some reason, cause
                // a neverending loop of view updates when using an external path. Calling it in here does not.
                didRunInitialConfig = true
                path.configure(views: onboardingFlow.views, isComplete: isComplete, startAtStep: startAtStep)
            } else {
                // ensure the model uses the latest views from the initializer
                path.updateViews(with: onboardingFlow.views)
            }
        }
    }
    
    
    /// A `OnboardingStack` is defined by the passed in views defined by the view builder as well as an boolean `Binding`
    /// that is set to true when the onboarding flow is completed.
    /// - Parameters:
    ///   - onboardingFlowComplete: An optional SwiftUI `Binding` that is automatically set to true by
    ///     the ``OnboardingNavigationPath`` once the onboarding flow is completed.
    ///     Can be used to conditionally show/hide the `OnboardingStack`.
    ///   - path: An optional, externally-managed ``OnboardingNavigationPath`` which will be used by this view.
    ///       Only specify this if you actually need external control over the path; otherwise omit it to get the recommended default behaviour.
    ///   - startAtStep: An optional SwiftUI (Onboarding) `View` type indicating the first to-be-shown step of the onboarding flow.
    ///   - content: The SwiftUI (Onboarding) `View`s that are part of the onboarding flow.
    ///     You can define the `View`s using the onboarding view builder.
    @MainActor
    public init(
        onboardingFlowComplete: Binding<Bool>? = nil,
        path: OnboardingNavigationPath? = nil,
        startAtStep: (any View.Type)? = nil,
        @OnboardingViewBuilder _ content: @MainActor () -> _OnboardingFlowViewCollection
    ) {
        onboardingFlow = content()
        externalPath = path
        isComplete = onboardingFlowComplete
        self.startAtStep = startAtStep
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
    OnboardingStack {
        Text(verbatim: "Hello Spezi!")
    }
}
#endif
