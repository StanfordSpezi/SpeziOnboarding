//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// The ``OnboardingActionsView`` allows developers to present a unified style for action buttons in an onboarding flow.
/// The ``OnboardingActionsView`` can contain one primary button and a optional secondary button below the primary button.
///
/// ```swift
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
    private let primaryText: String
    private let primaryAction: () async throws -> Void
    private let secondaryText: String?
    private let secondaryAction: (() async throws -> Void)?
    
    @State private var primaryActionState: ViewState = .idle
    @State private var secondaryActionState: ViewState = .idle
    
    
    public var body: some View {
        VStack {
            AsyncButton(state: $primaryActionState, action: primaryAction) {
                Text(primaryText)
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
                .buttonStyle(.borderedProminent)
            if let secondaryText, let secondaryAction {
                AsyncButton(secondaryText, state: $secondaryActionState, action: secondaryAction)
                    .padding(.top, 10)
            }
        }
            .disabled(primaryActionState != .idle || secondaryActionState != .idle)
            .viewStateAlert(state: $primaryActionState)
            .viewStateAlert(state: $secondaryActionState)
    }
    
    
    /// Creates an ``OnboardingActionsView`` instance that only contains a primary button.
    /// - Parameters:
    ///   - text: The title of the primary button without localization.
    ///   - action: The action that should be performed when pressing the primary button
    @_disfavoredOverload
    public init<Text: StringProtocol>(
        _ text: Text,
        action: @escaping () async throws -> Void
    ) {
        self.primaryText = String(text)
        self.primaryAction = action
        self.secondaryText = nil
        self.secondaryAction = nil
    }
    
    /// Creates an ``OnboardingActionsView`` instance that only contains a primary button.
    /// - Parameters:
    ///   - text: The localized title ot the primary button.
    ///   - action: The action that should be performed when pressing the primary button
    public init(
        _ text: LocalizedStringResource,
        action: @escaping () async throws -> Void
    ) {
        self.init(text.localizedString(), action: action)
    }
    
    /// Creates an ``OnboardingActionsView`` instance that contains a primary button and a secondary button.
    /// - Parameters:
    ///   - primaryText: The localized title ot the primary button.
    ///   - primaryAction: The action that should be performed when pressing the primary button
    ///   - secondaryText: The localized title ot the secondary button.
    ///   - secondaryAction: The action that should be performed when pressing the secondary button
    public init(
        primaryText: LocalizedStringResource,
        primaryAction: @escaping () async throws -> Void,
        secondaryText: LocalizedStringResource,
        secondaryAction: @escaping () async throws -> Void
    ) {
        self.init(
            primaryText: primaryText.localizedString(),
            primaryAction: primaryAction,
            secondaryText: secondaryText.localizedString(),
            secondaryAction: secondaryAction
        )
    }
    
    /// Creates an ``OnboardingActionsView`` instance that contains a primary button and a secondary button.
    /// - Parameters:
    ///   - primaryText: The title ot the primary button without localization.
    ///   - primaryAction: The action that should be performed when pressing the primary button
    ///   - secondaryText: The title ot the secondary button without localization.
    ///   - secondaryAction: The action that should be performed when pressing the secondary button
    @_disfavoredOverload
    public init<PrimaryText: StringProtocol, SecondaryText: StringProtocol>(
        primaryText: PrimaryText,
        primaryAction: @escaping () async throws -> Void,
        secondaryText: SecondaryText,
        secondaryAction: @escaping () async throws -> Void
    ) {
        self.primaryText = String(primaryText)
        self.primaryAction = primaryAction
        self.secondaryText = String(secondaryText)
        self.secondaryAction = secondaryAction
    }
}


#if DEBUG
struct OnboardingActionsView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            OnboardingActionsView("PRIMARY") {
                print("Primary!")
            }
            OnboardingActionsView(
                primaryText: "PRIMARY",
                primaryAction: {
                    print("Primary")
                },
                secondaryText: "SECONDARY",
                secondaryAction: {
                    print("Secondary")
                }
            )
        }
    }
}
#endif
