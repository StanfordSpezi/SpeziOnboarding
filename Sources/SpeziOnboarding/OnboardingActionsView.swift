//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// Unified style for action buttons in an onboarding flow.
///
/// The `OnboardingActionsView` can contain one primary button and a optional secondary button below the primary button.
///
/// ```swift
/// // simple, single-button configuration
/// OnboardingActionsView("Continue") {
///     // navigate to next onboarding step
/// }
///
/// // two-button configuration
/// OnboardingActionsView(
///     primaryText: "Primary Text",
///     primaryAction: {
///         // ...
///     },
///     secondaryText: "Secondary Text",
///     secondaryAction: {
///         // ...
///     }
/// )
/// ```
public struct OnboardingActionsView: View {
    private struct ButtonConfig {
        let title: Text
        let viewState: Binding<ViewState>?
        let action: @MainActor () async throws -> Void
    }
    
    private let primaryButton: ButtonConfig
    private let secondaryButton: ButtonConfig?
    
    @State private var internalPrimaryViewState: ViewState = .idle
    @State private var internalSecondaryViewState: ViewState = .idle
    
    
    @_documentation(visibility: internal) // swiftlint:disable:next attributes
    public var body: some View {
        let primaryViewStateBinding = primaryButton.viewState ?? $internalPrimaryViewState
        let secondaryViewStateBinding = secondaryButton?.viewState ?? $internalSecondaryViewState
        VStack(spacing: 0) {
            AsyncButton(state: primaryViewStateBinding, action: primaryButton.action) {
                primaryButton.title
                    .bold()
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
            .buttonStyle(.borderedProminent)
            .applyGlassEffect(.regular, interactive: true)
            if let secondaryButton {
                AsyncButton(state: secondaryViewStateBinding, action: secondaryButton.action) {
                    secondaryButton.title
                }
                .padding(.vertical, 10)
            }
        }
        .disabled(primaryViewStateBinding.wrappedValue != .idle || secondaryViewStateBinding.wrappedValue != .idle)
        .viewStateAlert(state: primaryViewStateBinding)
        .viewStateAlert(state: secondaryViewStateBinding)
    }
    
    private init(
        primaryButton: ButtonConfig,
        secondaryButton: ButtonConfig? = nil
    ) {
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}


extension OnboardingActionsView {
    /// Creates an `OnboardingActionsView` instance that only contains a primary button.
    /// - Parameters:
    ///   - viewState: An optional `ViewState` binding.
    ///   - text: The title of the primary button without localization.
    ///   - action: The action that should be performed when pressing the primary button
    public init(
        viewState: Binding<ViewState>? = nil,
        @ViewBuilder title: () -> Text,
        action: @escaping @MainActor () async throws -> Void
    ) {
        self.init(
            primaryButton: .init(title: title(), viewState: viewState, action: action)
        )
    }
    
    
    /// Creates an `OnboardingActionsView` instance that contains a primary button and a secondary button.
    /// - Parameters:
    ///   - primaryViewState: An optional `ViewState` binding for controlling the primary action's state.
    ///   - primaryText: The localized title of the primary button.
    ///   - primaryAction: The action that should be performed when pressing the primary button
    ///   - secondaryViewState: An optional `ViewState` binding for controlling the secondary action's state.
    ///   - secondaryText: The localized title of the secondary button.
    ///   - secondaryAction: The action that should be performed when pressing the secondary button
    public init(
        primaryViewState: Binding<ViewState>? = nil,
        @ViewBuilder primaryTitle: () -> Text,
        primaryAction: @escaping @MainActor () async throws -> Void,
        secondaryViewState: Binding<ViewState>? = nil,
        @ViewBuilder secondaryTitle: () -> Text,
        secondaryAction: @escaping @MainActor () async throws -> Void
    ) {
        self.init(
            primaryButton: .init(title: primaryTitle(), viewState: primaryViewState, action: primaryAction),
            secondaryButton: .init(title: secondaryTitle(), viewState: secondaryViewState, action: secondaryAction)
        )
    }
    
    
    /// Creates an `OnboardingActionsView` instance that only contains a primary button.
    /// - Parameters:
    ///   - text: The title of the primary button without localization.
    ///   - viewState: An optional `ViewState` binding.
    ///   - action: The action that should be performed when pressing the primary button
    @_disfavoredOverload
    public init(
        _ text: some StringProtocol,
        viewState: Binding<ViewState>? = nil,
        action: @escaping @MainActor () async throws -> Void
    ) {
        self.init(
            primaryButton: .init(title: Text(text), viewState: viewState, action: action)
        )
    }
    
    /// Creates an `OnboardingActionsView` instance that only contains a primary button.
    /// - Parameters:
    ///   - text: The localized title of the primary button.
    ///   - viewState: An optional `ViewState` binding.
    ///   - action: The action that should be performed when pressing the primary button
    public init(
        _ text: LocalizedStringResource,
        viewState: Binding<ViewState>? = nil,
        action: @escaping @MainActor () async throws -> Void
    ) {
        self.init(
            primaryButton: .init(title: Text(text), viewState: viewState, action: action)
        )
    }
    
    /// Creates an `OnboardingActionsView` instance that contains a primary button and a secondary button.
    /// - Parameters:
    ///   - primaryText: The localized title of the primary button.
    ///   - primaryViewState: An optional `ViewState` binding for controlling the primary action's state.
    ///   - primaryAction: The action that should be performed when pressing the primary button
    ///   - secondaryText: The localized title of the secondary button.
    ///   - secondaryViewState: An optional `ViewState` binding for controlling the secondary action's state.
    ///   - secondaryAction: The action that should be performed when pressing the secondary button
    public init(
        primaryText: LocalizedStringResource,
        primaryViewState: Binding<ViewState>? = nil, // swiftlint:disable:this function_default_parameter_at_end
        primaryAction: @escaping @MainActor () async throws -> Void,
        secondaryText: LocalizedStringResource,
        secondaryViewState: Binding<ViewState>? = nil,
        secondaryAction: @escaping @MainActor () async throws -> Void
    ) {
        self.init(
            primaryButton: .init(title: Text(primaryText), viewState: primaryViewState, action: primaryAction),
            secondaryButton: .init(title: Text(secondaryText), viewState: secondaryViewState, action: secondaryAction)
        )
    }
    
    /// Creates an `OnboardingActionsView` instance that contains a primary button and a secondary button.
    /// - Parameters:
    ///   - primaryText: The title of the primary button without localization.
    ///   - primaryViewState: An optional `ViewState` binding for controlling the primary action's state.
    ///   - primaryAction: The action that should be performed when pressing the primary button
    ///   - secondaryText: The title of the secondary button without localization.
    ///   - secondaryViewState: An optional `ViewState` binding for controlling the secondary action's state.
    ///   - secondaryAction: The action that should be performed when pressing the secondary button
    @_disfavoredOverload
    public init(
        primaryText: some StringProtocol,
        primaryViewState: Binding<ViewState>? = nil, // swiftlint:disable:this function_default_parameter_at_end
        primaryAction: @escaping @MainActor () async throws -> Void,
        secondaryText: some StringProtocol,
        secondaryViewState: Binding<ViewState>? = nil,
        secondaryAction: @escaping @MainActor () async throws -> Void
    ) {
        self.init(
            primaryButton: .init(title: Text(primaryText), viewState: primaryViewState, action: primaryAction),
            secondaryButton: .init(title: Text(secondaryText), viewState: secondaryViewState, action: secondaryAction)
        )
    }
}


extension View {
    func transform(@ViewBuilder _ transform: @MainActor (Self) -> some View) -> some View {
        transform(self)
    }
}


#if DEBUG
#Preview {
    VStack {
        OnboardingActionsView("PRIMARY") {
            print("Primary!")
        }
        OnboardingActionsView(
            primaryText: String("PRIMARY"),
            primaryAction: {
                print("Primary")
            },
            secondaryText: String("SECONDARY"),
            secondaryAction: {
                print("Secondary")
            }
        )
    }
}
#endif
