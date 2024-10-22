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
/// ### Usage
///
/// The following example demonstrates the usage of the ``OnboardingView`` using its default configuration. The default configuration divides up
/// each screen into sections and allows you to add a title and subtitle for the overall view itself, as well as create separate information areas. Finally,
/// there is an option for an action that should be performed (which can be used to go to the next screen in the onboarding flow).
///
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
///
/// In implementation, you can treat the titleView, contentView, and actionView as regular SwiftUI Views. However, to simplify things, you can also use the built-in ``OnboardingTitleView`` and built-in ``OnboardingActionsView``, as demonstrated below.
/// ``` swift
/// OnboardingView(
///     titleView: {
///         OnboardingTitleView(
///             title: "Title",
///             subtitle: "Subtitle"
///         )
///     },
///     contentView: {
///         VStack {
///             Text("This is the onboarding content.")
///                 .font(.headline)
///         }
///     },
///     actionView: {
///         OnboardingActionsView (
///             Text: "Action Text",
///             Action: {
///                 // Desired Action
///             }
///         )
///     }
/// )
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
    /// 
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
}
