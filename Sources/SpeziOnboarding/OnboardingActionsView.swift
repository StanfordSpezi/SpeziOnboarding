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
    private let primaryText: Text
    private let primaryAction: () async throws -> Void
    private let secondaryText: Text?
    private let secondaryAction: (() async throws -> Void)?
    
    @State private var primaryActionState: ViewState = .idle
    @State private var secondaryActionState: ViewState = .idle
    
    
    public var body: some View {
        VStack {
            AsyncButton(state: $primaryActionState, action: primaryAction) {
                primaryText
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
                .buttonStyle(.borderedProminent)
            if let secondaryText, let secondaryAction {
                AsyncButton(state: $secondaryActionState, action: secondaryAction) {
                    secondaryText
                }
                    .padding(.top, 10)
            }
        }
            .disabled(primaryActionState != .idle || secondaryActionState != .idle)
            .viewStateAlert(state: $primaryActionState)
            .viewStateAlert(state: $secondaryActionState)
    }


    init(
        primaryText: Text,
        primaryAction: @escaping () async throws -> Void,
        secondaryText: Text? = nil,
        secondaryAction: (() async throws -> Void)? = nil
    ) {
        self.primaryText = primaryText
        self.primaryAction = primaryAction
        self.secondaryText = secondaryText
        self.secondaryAction = secondaryAction
    }

    /// Creates an `OnboardingActionsView` instance that only contains a primary button.
    /// - Parameters:
    ///   - text: The title of the primary button without localization.
    ///   - action: The action that should be performed when pressing the primary button
    @_disfavoredOverload
    public init<Text: StringProtocol>(
        verbatim text: Text,
        action: @escaping () async throws -> Void
    ) {
        self.init(primaryText: SwiftUI.Text(verbatim: String(text)), primaryAction: action)
    }
    
    /// Creates an `OnboardingActionsView` instance that only contains a primary button.
    /// - Parameters:
    ///   - text: The localized title of the primary button.
    ///   - action: The action that should be performed when pressing the primary button
    public init(
        _ text: LocalizedStringResource,
        action: @escaping () async throws -> Void
    ) {
        self.init(primaryText: Text(text), primaryAction: action)
    }
    
    /// Creates an `OnboardingActionsView` instance that contains a primary button and a secondary button.
    /// - Parameters:
    ///   - primaryText: The localized title of the primary button.
    ///   - primaryAction: The action that should be performed when pressing the primary button
    ///   - secondaryText: The localized title of the secondary button.
    ///   - secondaryAction: The action that should be performed when pressing the secondary button
    public init(
        primaryText: LocalizedStringResource,
        primaryAction: @escaping () async throws -> Void,
        secondaryText: LocalizedStringResource,
        secondaryAction: @escaping () async throws -> Void
    ) {
        self.init(primaryText: Text(primaryText), primaryAction: primaryAction, secondaryText: Text(secondaryText), secondaryAction: secondaryAction)
    }
    
    /// Creates an `OnboardingActionsView` instance that contains a primary button and a secondary button.
    /// - Parameters:
    ///   - primaryText: The title of the primary button without localization.
    ///   - primaryAction: The action that should be performed when pressing the primary button
    ///   - secondaryText: The title of the secondary button without localization.
    ///   - secondaryAction: The action that should be performed when pressing the secondary button
    @_disfavoredOverload
    public init<PrimaryText: StringProtocol, SecondaryText: StringProtocol>(
        primaryText: PrimaryText,
        primaryAction: @escaping () async throws -> Void,
        secondaryText: SecondaryText,
        secondaryAction: @escaping () async throws -> Void
    ) {
        self.init(
            primaryText: Text(verbatim: String(primaryText)),
            primaryAction: primaryAction,
            secondaryText: Text(verbatim: String(secondaryText)),
            secondaryAction: secondaryAction
        )
    }
}


#if DEBUG
#Preview {
    VStack {
        OnboardingActionsView(verbatim: "PRIMARY") {
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
