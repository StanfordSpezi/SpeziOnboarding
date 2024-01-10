//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Present onboarding information in a unified style.
///
/// The default style of the `OnboardingView` uses a combination of an ``OnboardingTitleView``, ``OnboardingInformationView``,
/// and ``OnboardingActionsView``.
///
/// - Tip: The ``SequentialOnboardingView`` provides an alternative to provide
/// sequential information that is displayed step by step.
///
/// The following example demonstrates the usage of the `OnboardingView` using its default configuration.
/// ```swift
/// OnboardingView(
///     title: "Title",
///     subtitle: "Subtitle",
///     areas: [
///         OnboardingInformationView.Content(
///             icon: Image(systemName: "pc"),
///             title: "PC",
///             description: "This is a PC."
///         ),
///         OnboardingInformationView.Content(
///             icon: Image(systemName: "desktopcomputer"),
///             title: "Mac",
///             description: "This is an iMac."
///         )
///     ],
///     actionText: "Continue"
/// ) {
///     // Action that should be performed on pressing the "Continue" button ...
/// }
/// ```
public struct OnboardingView<TitleView: View, ContentView: View, ActionView: View>: View {
    private let titleView: TitleView
    private let contentView: ContentView
    private let actionView: ActionView
    
    
    public var body: some View {
        Group {
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .center) {
                        VStack {
                            titleView
                            contentView
                        }
                        if !(actionView is EmptyView) {
                            Spacer()
                            actionView
                        }
                        Spacer()
                            .frame(height: 10)
                    }
                    .frame(minHeight: geometry.size.height)
                }
            }
            .padding(24)
        }
    }
    
    
    /// Creates a customized `OnboardingView` allowing a complete customization of the  `OnboardingView`.
    /// - Parameters:
    ///   - titleView: The title view displayed at the top.
    ///   - contentView: The content view.
    ///   - actionView: The action view displayed at the bottom.
    public init(
        @ViewBuilder titleView: () -> TitleView = { EmptyView() },
        @ViewBuilder contentView: () -> ContentView,
        @ViewBuilder actionView: () -> ActionView
    ) {
        self.titleView = titleView()
        self.contentView = contentView()
        self.actionView = actionView()
    }
    
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


#if DEBUG
#Preview {
    OnboardingView(
        title: String("Title"),
        subtitle: String("Subtitle"),
        areas: AreasView_Previews.mock,
        actionText: String("Primary Button")
    ) {
        print("Primary!")
    }
}
#endif
