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
public struct OnboardingStack: View {
    @State var onboardingNavigationPath: OnboardingNavigationPath
    private let collection: _OnboardingFlowViewCollection

    
    /// The ``OnboardingStack/body`` contains a SwiftUI `NavigationStack` that is responsible for the navigation between
    /// the different onboarding views via an ``OnboardingNavigationPath``.
    public var body: some View {
        NavigationStack(path: $onboardingNavigationPath.path) {
            onboardingNavigationPath.firstOnboardingView
                .navigationDestination(for: OnboardingStepIdentifier.self) { onboardingStep in
                    onboardingNavigationPath.navigate(to: onboardingStep)
                }
        }
            .environment(onboardingNavigationPath)
            .onChange(of: ObjectIdentifier(collection)) {
                // ensure the model uses the latest views from the initializer
                self.onboardingNavigationPath.updateViews(with: collection.views)
            }
    }
    
    
    /// A `OnboardingStack` is defined by the passed in views defined by the view builder as well as an boolean `Binding`
    /// that is set to true when the onboarding flow is completed.
    /// - Parameters:
    ///   - onboardingFlowComplete: An optional SwiftUI `Binding` that is automatically set to true by
    ///     the ``OnboardingNavigationPath`` once the onboarding flow is completed.
    ///     Can be used to conditionally show/hide the `OnboardingStack`.
    ///   - startAtStep: An optional SwiftUI (Onboarding) `View` type indicating the first to-be-shown step of the onboarding flow.
    ///   - content: The SwiftUI (Onboarding) `View`s that are part of the onboarding flow.
    ///     You can define the `View`s using the onboarding view builder.
    @MainActor
    public init(
        onboardingFlowComplete: Binding<Bool>? = nil,
        startAtStep: (any View.Type)? = nil,
        @OnboardingViewBuilder _ content: @escaping () -> _OnboardingFlowViewCollection
    ) {
        let onboardingFlowViewCollection = content()
        self.collection = onboardingFlowViewCollection

        self._onboardingNavigationPath = State(
            wrappedValue: OnboardingNavigationPath(
                views: onboardingFlowViewCollection.views,
                complete: onboardingFlowComplete,
                startAtStep: startAtStep
            )
        )
    }
}


#if DEBUG
#Preview {
    OnboardingStack {
        Text(verbatim: "Hello Spezi!")
    }
}
#endif
