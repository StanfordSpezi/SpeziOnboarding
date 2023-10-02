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
/// The ``OnboardingActionsView`` can contain one primary button and a optional secondary button below or next to the primary button.
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
    public enum Orientation {
        case vertical
        case horizontal(proportions: Double)
    }
    
    public enum Content {
        case text(LocalizedStringResource)
        case image(String)
        
        
        var view: any View {
            switch self {
            case .text(let text):
                return Text(text.localizedString())
            case .image(let imageName):
                return Image(systemName: imageName).imageScale(.large)
            }
        }
    }
    
    
    private let primaryView: any View
    private let primaryAction: () async throws -> Void
    private let secondaryView: (any View)?
    private let secondaryAction: (() async throws -> Void)?
    private let orientation: Orientation

    
    @State private var primaryActionState: ViewState = .idle
    @State private var secondaryActionState: ViewState = .idle


    @MainActor
    private var verticalBody: some View {
        VStack {
            AsyncButton(state: $primaryActionState, action: primaryAction) {
                AnyView(primaryView)
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
            
            if let secondaryView, let secondaryAction {
                AsyncButton(state: $secondaryActionState, action: secondaryAction) {
                    AnyView(secondaryView)
                        .frame(maxWidth: .infinity, minHeight: 38)
                }
                    .padding(.top, 10)
            }
        }
            .buttonStyle(.borderedProminent)
            .disabled(primaryActionState != .idle || secondaryActionState != .idle)
            .viewStateAlert(state: $primaryActionState)
            .viewStateAlert(state: $secondaryActionState)
    }
    
    @MainActor
    private func horizontalBody(proportions: Double) -> some View {
        VStack {
            HStack {
                AsyncButton(state: $primaryActionState, action: primaryAction) {
                    AnyView(primaryView)
                        /// The `UIScreen` width isn't a perfect measure, but using SwiftUI's `GeometryReader` results in too many limitations as the component attempts to fill all available space.
                        .frame(maxWidth: UIScreen.main.bounds.width * proportions, minHeight: 38)
                }
                
                if let secondaryView, let secondaryAction {
                    AsyncButton(state: $secondaryActionState, action: secondaryAction) {
                        AnyView(secondaryView)
                            /// The `UIScreen` width isn't a perfect measure, but using SwiftUI's `GeometryReader` results in too many limitations as the component attempts to fill all available space.
                            .frame(maxWidth: UIScreen.main.bounds.width * (1 - proportions), minHeight: 38)
                    }
                }
            }
                .buttonStyle(.borderedProminent)
        }
            .disabled(primaryActionState != .idle || secondaryActionState != .idle)
            .viewStateAlert(state: $primaryActionState)
            .viewStateAlert(state: $secondaryActionState)
    }
    
    public var body: some View {
        switch orientation {
        case .vertical:
            verticalBody
        case .horizontal(let proportions):
            horizontalBody(proportions: proportions)
        }
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
        self.primaryView = SwiftUI.Text(text)
        self.primaryAction = action
        self.secondaryView = nil
        self.secondaryAction = nil
        self.orientation = .vertical
    }
    
    /// Creates an ``OnboardingActionsView`` instance that only contains a primary button.
    /// - Parameters:
    ///   - text: The localized title of the primary button.
    ///   - action: The action that should be performed when pressing the primary button
    public init(
        _ text: LocalizedStringResource,
        action: @escaping () async throws -> Void
    ) {
        self.init(text.localizedString(), action: action)
    }
    
    /// Creates an ``OnboardingActionsView`` instance that contains a primary button and a secondary button.
    /// - Parameters:
    ///   - primaryText: The localized title of the primary button.
    ///   - primaryAction: The action that should be performed when pressing the primary button
    ///   - secondaryText: The localized title of the secondary button.
    ///   - secondaryAction: The action that should be performed when pressing the secondary button
    public init(
        primaryText: LocalizedStringResource,
        primaryAction: @escaping () async throws -> Void,
        secondaryText: LocalizedStringResource,
        secondaryAction: @escaping () async throws -> Void,
        orientation: Orientation = .vertical
    ) {
        self.init(
            primaryText: primaryText.localizedString(),
            primaryAction: primaryAction,
            secondaryText: secondaryText.localizedString(),
            secondaryAction: secondaryAction,
            orientation: orientation
        )
    }
    
    /// Creates an ``OnboardingActionsView`` instance that contains a primary button and a secondary button with a specific content, either a text or an image.
    /// - Parameters:
    ///   - primaryContent: The localized content of the primary button.
    ///   - primaryAction: The action that should be performed when pressing the primary button
    ///   - secondaryText: The localized content of the secondary button.
    ///   - secondaryAction: The action that should be performed when pressing the secondary button
    public init(
        primaryContent: Content,
        primaryAction: @escaping () async throws -> Void,
        secondaryContent: Content,
        secondaryAction: @escaping () async throws -> Void,
        orientation: Orientation = .vertical
    ) {
        guard case .horizontal(let proportions) = orientation,
              0.0...1.0 ~= proportions else {
            preconditionFailure("OnboardingActionsView Horizontal proportions must be between 0 and 1.")
        }
        
        self.primaryView = primaryContent.view
        self.primaryAction = primaryAction
        self.secondaryView = secondaryContent.view
        self.secondaryAction = secondaryAction
        self.orientation = orientation
    }
    
    /// Creates an ``OnboardingActionsView`` instance that contains a primary button and a secondary button.
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
        secondaryAction: @escaping () async throws -> Void,
        orientation: Orientation = .vertical
    ) {
        guard case .horizontal(let proportions) = orientation,
              0.0...1.0 ~= proportions else {
            preconditionFailure("OnboardingActionsView Horizontal proportions must be between 0 and 1.")
        }
        
        self.primaryView = Text(primaryText)
        self.primaryAction = primaryAction
        self.secondaryView = Text(secondaryText)
        self.secondaryAction = secondaryAction
        self.orientation = orientation
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
