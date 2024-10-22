//
//  OnboardingView+Information.swift
//  SpeziOnboarding
//
//  Created by Paul Kraft on 21.10.2024.
//

import SpeziOnboardingCore
import SpeziViews
import SwiftUI

extension OnboardingView {
    /// Creates the default style of the `OnboardingView` uses a combination of an ``OnboardingTitleView``, ``OnboardingInformationView``,
    /// and ``OnboardingActionsView``.
    ///
    /// - Parameters:
    ///   - title: The localized title of the ``OnboardingView``.
    ///   - subtitle: The localized subtitle of the ``OnboardingView``.
    ///   - areas: The areas of the ``OnboardingView`` defined using ``OnboardingInformationView/Content`` instances..
    ///   - actionText: The localized text that should appear on the ``OnboardingView``'s primary button.
    ///   - action: The close that is called then the primary button is pressed.
    public init( // swiftlint:disable:this function_default_parameter_at_end
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil,
        areas: [OnboardingInformationView.Content],
        actionText: LocalizedStringResource,
        action: @escaping () async throws -> Void
    ) where TitleView == OnboardingTitleView, ContentView == OnboardingInformationView, ActionView == OnboardingActionsView {
        self.init(
            titleView: {
                OnboardingTitleView(title: title, subtitle: subtitle)
            },
            contentView: {
                OnboardingInformationView(areas: areas)
            }, actionView: {
                OnboardingActionsView(actionText) {
                    try await action()
                }
            }
        )
    }
    
    
    /// Creates the default style of the `OnboardingView` uses a combination of an ``OnboardingTitleView``, ``OnboardingInformationView``,
    /// and ``OnboardingActionsView``.
    ///
    /// - Parameters:
    ///   - title: The title without localization.
    ///   - subtitle: The subtitle without localization.
    ///   - areas: The areas of the `OnboardingView` defined using ``OnboardingInformationView/Content`` instances..
    ///   - actionText: The text that should appear on the `OnboardingView`'s primary button without localization.
    ///   - action: The close that is called then the primary button is pressed.
    @_disfavoredOverload
    public init<Title: StringProtocol, Subtitle: StringProtocol, ActionText: StringProtocol>(
        title: Title,
        subtitle: Subtitle,
        areas: [OnboardingInformationView.Content],
        actionText: ActionText,
        action: @escaping () async throws -> Void
    ) where TitleView == OnboardingTitleView, ContentView == OnboardingInformationView, ActionView == OnboardingActionsView {
        self.init(
            titleView: {
                OnboardingTitleView(title: title, subtitle: subtitle)
            },
            contentView: {
                OnboardingInformationView(areas: areas)
            }, actionView: {
                OnboardingActionsView(verbatim: actionText) {
                    try await action()
                }
            }
        )
    }
    
    /// Creates the default style of the `OnboardingView` uses a combination of an ``OnboardingTitleView``, ``OnboardingInformationView``,
    /// and ``OnboardingActionsView``.
    ///
    /// - Parameters:
    ///   - title: The title without localization.
    ///   - areas: The areas of the `OnboardingView` defined using ``OnboardingInformationView/Content`` instances..
    ///   - actionText: The text that should appear on the `OnboardingView`'s primary button without localization.
    ///   - action: The close that is called then the primary button is pressed.
    @_disfavoredOverload
    public init<Title: StringProtocol, ActionText: StringProtocol>(
        title: Title,
        areas: [OnboardingInformationView.Content],
        actionText: ActionText,
        action: @escaping () async throws -> Void
    ) where TitleView == OnboardingTitleView, ContentView == OnboardingInformationView, ActionView == OnboardingActionsView {
        self.init(
            titleView: {
                OnboardingTitleView(title: title)
            },
            contentView: {
                OnboardingInformationView(areas: areas)
            }, actionView: {
                OnboardingActionsView(verbatim: actionText) {
                    try await action()
                }
            }
        )
    }
}
