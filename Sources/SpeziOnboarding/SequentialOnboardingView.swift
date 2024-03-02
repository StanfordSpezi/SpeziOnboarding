//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Present onboarding information step by step.
///
/// The `SequentialOnboardingView` provides a view to display information that is displayed step by step.
///
/// - Tip: The ``OnboardingView`` provides an alternative to provide  information that is displayed all at once.
///
/// The following example demonstrates the usage of the ``SequentialOnboardingView``:
/// ```swift
/// SequentialOnboardingView(
///     title: "Title",
///     subtitle: "Subtitle",
///     content: [
///         .init(
///             title: "A thing to know",
///             description: "This is a first thing that you should know, read carefully!")
///         ,
///         .init(
///             title: "Second thing to know",
///             description: "This is a second thing that you should know, read carefully!"
///         ),
///         .init(
///             title: "Third thing to know",
///             description: "This is a third thing that you should know, read carefully!"
///         )
///     ],
///     actionText: "Continue"
/// ) {
///     // Action that should be performed on pressing the "Continue" button ...
/// }
/// ```
public struct SequentialOnboardingView<TitleView: View>: View {
    /// A `Content` defines the way that information is displayed in an ``SequentialOnboardingView``.
    public struct Content {
        /// The title of the area in the ``SequentialOnboardingView``.
        public let title: Text?
        /// The description of the area in the ``SequentialOnboardingView``.
        public let description: Text

        
        /// Creates a new content for an area in the ``SequentialOnboardingView``.
        /// - Parameters:
        ///   - title: The localized title of the area in the ``SequentialOnboardingView``.
        ///   - description: The localized description of the area in the ``SequentialOnboardingView``.
        public init( // swiftlint:disable:this function_default_parameter_at_end
            title: LocalizedStringResource? = nil,
            description: LocalizedStringResource
        ) {
            self.title = title.map { Text($0) }
            self.description = Text(description)
        }
        
        /// Creates a new content for an area in the ``SequentialOnboardingView``.
        /// - Parameters:
        ///   - title: The title of the area in the ``SequentialOnboardingView`` without localization.
        ///   - description: The description of the area in the ``SequentialOnboardingView`` without localization.
        @_disfavoredOverload
        public init<Title: StringProtocol, Description: StringProtocol>(
            title: Title,
            description: Description
        ) {
            self.title = Text(verbatim: String(title))
            self.description = Text(verbatim: String(description))
        }

        /// Creates a new content for an area in the ``SequentialOnboardingView``.
        /// - Parameters:
        ///   - description: The description of the area in the ``SequentialOnboardingView`` without localization.
        @_disfavoredOverload
        public init<Description: StringProtocol>(
            description: Description
        ) {
            self.title = nil
            self.description = Text(verbatim: String(description))
        }
    }
    
    
    private let titleView: TitleView
    private let content: [Content]
    private let actionText: Text
    private let action: () async throws -> Void

    @State private var currentContentIndex: Int = 0
    
    
    public var body: some View {
        ScrollViewReader { proxy in
            OnboardingView(
                titleView: {
                    titleView
                },
                contentView: {
                    ForEach(0..<content.count, id: \.self) { index in
                        if index <= currentContentIndex {
                            stepView(index: index)
                                .id(index)
                        }
                    }
                },
                actionView: {
                    OnboardingActionsView(
                        primaryText: actionButtonTitle
                    ) {
                        if currentContentIndex < content.count - 1 {
                            currentContentIndex += 1
                            withAnimation {
                                proxy.scrollTo(currentContentIndex - 1, anchor: .top)
                            }
                        } else {
                            try await action()
                        }
                    }
                }
            )
        }
    }
    
    private var actionButtonTitle: Text {
        if currentContentIndex < content.count - 1 {
            return Text("SEQUENTIAL_ONBOARDING_NEXT", bundle: .module)
        } else {
            return actionText
        }
    }

    private init(titleView: TitleView, content: [Content], actionText: Text, action: @escaping () async throws -> Void) {
        self.titleView = titleView
        self.content = content
        self.actionText = actionText
        self.action = action
    }

    /// Creates the default style of the `SequentialOnboardingView` that uses a combination of an ``OnboardingTitleView``
    /// and ``OnboardingActionsView``.
    ///
    /// - Parameters:
    ///   - title: The localized title.
    ///   - subtitle: The localized subtitle.
    ///   - content: The areas of the `SequentialOnboardingView` defined using ``SequentialOnboardingView/Content`` instances..
    ///   - actionText: The localized text that should appear on the `SequentialOnboardingView`'s primary button.
    ///   - action: The close that is called then the primary button is pressed.
    public init( // swiftlint:disable:this function_default_parameter_at_end
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil,
        content: [Content],
        actionText: LocalizedStringResource,
        action: @escaping () async throws -> Void
    ) where TitleView == OnboardingTitleView {
        self.init(
            titleView: OnboardingTitleView(title: title, subtitle: subtitle),
            content: content,
            actionText: Text(actionText),
            action: action
        )
    }
    
    /// Creates the default style of the `SequentialOnboardingView` that uses a combination of an ``OnboardingTitleView``
    /// and ``OnboardingActionsView``.
    ///
    /// - Parameters:
    ///   - title: The title  without localization.
    ///   - content: The areas of the `SequentialOnboardingView` defined using ``SequentialOnboardingView/Content`` instances..
    ///   - actionText: The text that should appear on the `SequentialOnboardingView`'s primary button.
    ///   - action: The close that is called then the primary button is pressed.
    @_disfavoredOverload
    public init<Title: StringProtocol, ActionText: StringProtocol>(
        title: Title,
        content: [Content],
        actionText: ActionText,
        action: @escaping () async throws -> Void
    ) where TitleView == OnboardingTitleView {
        self.init(
            titleView: OnboardingTitleView(title: title),
            content: content,
            actionText: Text(verbatim: String(actionText)),
            action: action
        )
    }
    
    /// Creates the default style of the `SequentialOnboardingView` that uses a combination of an ``OnboardingTitleView``
    /// and ``OnboardingActionsView``.
    ///
    /// - Parameters:
    ///   - title: The title without localization.
    ///   - subtitle: The subtitle without localization.
    ///   - content: The areas of the `SequentialOnboardingView` defined using ``SequentialOnboardingView/Content`` instances..
    ///   - actionText: The text that should appear on the `SequentialOnboardingView`'s primary button.
    ///   - action: The close that is called then the primary button is pressed.
    @_disfavoredOverload
    public init<Title: StringProtocol, Subtitle: StringProtocol, ActionText: StringProtocol>(
        title: Title,
        subtitle: Subtitle?,
        content: [Content],
        actionText: ActionText,
        action: @escaping () async throws -> Void
    ) where TitleView == OnboardingTitleView {
        self.init(
            titleView: OnboardingTitleView(title: title, subtitle: subtitle),
            content: content,
            actionText: Text(verbatim: String(actionText)),
            action: action
        )
    }
    
    
    /// Creates a customized `SequentialOnboardingView` allowing a complete customization of the  `SequentialOnboardingView`'s title view.
    ///
    /// - Parameters:
    ///   - titleView: The title view displayed at the top.
    ///   - content: The areas of the `SequentialOnboardingView` defined using ``SequentialOnboardingView/Content`` instances..
    ///   - actionText: The text that should appear on the `SequentialOnboardingView`'s primary button without localization.
    ///   - action: The close that is called then the primary button is pressed.
    @_disfavoredOverload
    public init<ActionText: StringProtocol>(
        titleView: TitleView,
        content: [Content],
        actionText: ActionText,
        action: @escaping () async throws -> Void
    ) {
        self.init(
            titleView: titleView,
            content: content,
            actionText: Text(verbatim: String(actionText)),
            action: action
        )
    }
    
    /// Creates a customized `SequentialOnboardingView` allowing a complete customization of the  `SequentialOnboardingView`'s title view.
    ///
    /// - Parameters:
    ///   - titleView: The title view displayed at the top.
    ///   - content: The areas of the ``SequentialOnboardingView`` defined using ``SequentialOnboardingView/Content`` instances..
    ///   - actionText: The localized text that should appear on the ``SequentialOnboardingView``'s primary button.
    ///   - action: The close that is called then the primary button is pressed.
    public init(
        titleView: TitleView,
        content: [Content],
        actionText: LocalizedStringResource,
        action: @escaping () async throws -> Void
    ) {
        self.init(
            titleView: titleView,
            content: content,
            actionText: Text(actionText),
            action: action
        )
    }
    
    
    private func stepView(index: Int) -> some View {
        let content = content[index]
        return HStack {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(verbatim: "\(index + 1)")
                    .bold()
                    .foregroundColor(.white)
                    .padding(12)
                    .background {
                        Circle()
                            .fill(Color.accentColor)
                    }
                    .accessibilityLabel(String("\(index + 1)."))
                    .accessibilityHidden(content.title != nil)
                VStack(alignment: .leading, spacing: 8) {
                    if let title = content.title {
                        title
                            .bold()
                            .accessibilityLabel(Text(verbatim: "\(index + 1). ") + title)
                            .accessibilityAddTraits(.isHeader)
                    }
                    content.description
                }
                Spacer()
            }
                .padding(.horizontal, 12)
                .padding(.top, 4)
                .padding(.bottom, 12)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        #if !os(macOS)
                        .fill(Color(.systemGroupedBackground))
                        #else
                        .fill(Color(.windowBackgroundColor))
                        #endif
                }
        }
    }
}


#if DEBUG
#Preview {
    SequentialOnboardingView(
        title: String("Title"),
        subtitle: String("Subtitle"),
        content: [
            .init(title: String("A thing to know"), description: String("This is a first thing that you should know, read carefully!")),
            .init(title: String("Second thing to know"), description: String("This is a second thing that you should know, read carefully!")),
            .init(title: String("Third thing to know"), description: String("This is a third thing that you should know, read carefully!"))
        ],
        actionText: String("Continue")
    ) {
        print("Done!")
    }
}
#endif
