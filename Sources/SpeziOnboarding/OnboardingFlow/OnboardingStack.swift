//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// The ``OnboardingStack`` represents one of the main components of the ``SpeziOnboarding`` package. It wraps the SwiftUI `NavigationStack` and provides an easy to use API to declare the onboarding steps of health applications, eliminating the need for developers to manually determine the next to be shown step within each onboarding view (e.g. skipped steps as permissions are already granted). All of the (conditional) onboarding views are stated within the ``OnboardingStack`` from which the order of the onboarding flow is determined.
///
/// Navigation within the ``OnboardingStack`` is possible via the ``OnboardingNavigationPath`` which works quite similar to the SwiftUI `NavigationPath`. It automatically navigates to the next to-be-shown onboarding step via ``OnboardingNavigationPath/nextStep()`` or manually via  ``OnboardingNavigationPath/append(_:)``. Furthermore, one can append custom onboarding steps that are not decleared within the  ``OnboardingStack`` (e.g. as the structure of these steps isn't linear) via ``OnboardingNavigationPath/append(customView:)`` or ``OnboardingNavigationPath/append(customViewInit:)``. See the ``OnboardingNavigationPath`` for more details.
/// 
/// The ``OnboardingNavigationPath`` is injeceted as a SwiftUI `EnvironmentObject` into the ``OnboardingStack`` view hierachy. Resulting from that, all views declared within the ``OnboardingStack`` are able to access a single instance of the ``OnboardingNavigationPath``.
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
    @StateObject var onboardingNavigationPath: OnboardingNavigationPath
    @ObservedObject var onboardingFlowViewCollection: _OnboardingFlowViewCollection
    
    
    /// The ``OnboardingStack/body`` contains a SwiftUI `NavigationStack` that is responsible for the navigation between the different onboarding views via an ``OnboardingNavigationPath``
    public var body: some View {
        NavigationStack(path: $onboardingNavigationPath.path) {
            onboardingNavigationPath.firstOnboardingView
                .navigationDestination(for: OnboardingStepIdentifier.self) { onboardingStep in
                    onboardingNavigationPath.navigate(to: onboardingStep)
                }
        }
        .environmentObject(onboardingNavigationPath)
        /// Inject onboarding views resulting from a retriggered evaluation of the onboarding result builder into the `OnboardingNavigationPath`
        .onReceive(onboardingFlowViewCollection.$views, perform: { updatedOnboardingViews in
            self.onboardingNavigationPath.updateViews(with: updatedOnboardingViews)
        })
    }
    
    
    /// A ``OnboardingStack`` is defined by the `_OnboardingFlowViewCollection` resulting from the evaluation of the ``OnboardingViewBuilder`` result builder as well as an boolean `Binding` that is set to true when the onboarding flow is completed.
    /// - Parameters:
    ///   - onboardingFlowComplete: An optional SwiftUI `Binding` that is automatically set to true by the ``OnboardingNavigationPath`` once the onboarding flow is completed. Can be used to conditionally show/hide the ``OnboardingStack``.
    ///   - startAtStep: An optional SwiftUI (Onboarding) `View` type indicating the first to-be-shown step of the onboarding flow.
    ///   - content: The SwiftUI (Onboarding) `View`s that are part of the onboarding flow. You can define the `View`s using the ``OnboardingViewBuilder`` result builder.
    public init(
        onboardingFlowComplete: Binding<Bool>? = nil,
        startAtStep: (any View.Type)? = nil,
        @OnboardingViewBuilder _ content: @escaping () -> _OnboardingFlowViewCollection
    ) {
        let onboardingFlowViewCollection = content()
        self.onboardingFlowViewCollection = onboardingFlowViewCollection
        
        self._onboardingNavigationPath = StateObject(
            wrappedValue: OnboardingNavigationPath(
                views: onboardingFlowViewCollection.views,
                complete: onboardingFlowComplete,
                startAtStep: startAtStep
            )
        )
    }
}


#if DEBUG
struct OnboardingStack_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingStack {
            Text("Hello Spezi!")
        }
    }
}
#endif
