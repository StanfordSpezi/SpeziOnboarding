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
///     steps: [
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
public struct SequentialOnboardingView<Header: View>: View {
    /// A `Step` defines the way that information is displayed in an ``SequentialOnboardingView``.
    public struct Step {
        /// The title of the area in the ``SequentialOnboardingView``.
        public let title: Text?
        /// The description of the area in the ``SequentialOnboardingView``.
        public let description: Text
        
        /// Creates a new content for an area in the ``SequentialOnboardingView``.
        /// - Parameters:
        ///   - title: The localized title of the area in the ``SequentialOnboardingView``.
        ///   - description: The localized description of the area in the ``SequentialOnboardingView``.
        public init(
            title: LocalizedStringResource? = nil, // swiftlint:disable:this function_default_parameter_at_end
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
        public init(
            title: (some StringProtocol)? = String?.none, // swiftlint:disable:this function_default_parameter_at_end
            description: some StringProtocol
        ) {
            self.title = title.map { Text($0) }
            self.description = Text(description)
        }
    }
    
    
    private let header: Header
    private let steps: [Step]
    private let actionText: Text
    private let action: @MainActor () async throws -> Void

    @State private var currentStepIndex: Int = 0
    
    @_documentation(visibility: internal) // swiftlint:disable:next attributes
    public var body: some View {
        ScrollViewReader { proxy in
            OnboardingView {
                header
            } content: {
                ForEach(0..<steps.count, id: \.self) { index in
                    if index <= currentStepIndex {
                        stepView(index: index)
                            .id(index)
                    }
                }
            } footer: {
                OnboardingActionsView(primaryText: actionButtonTitle) {
                    if currentStepIndex < steps.count - 1 {
                        currentStepIndex += 1
                        withAnimation {
                            proxy.scrollTo(currentStepIndex - 1, anchor: .top)
                        }
                    } else {
                        try await action()
                    }
                }
            }
        }
    }
    
    private var actionButtonTitle: Text {
        if currentStepIndex < steps.count - 1 {
            return Text("SEQUENTIAL_ONBOARDING_NEXT", bundle: .module)
        } else {
            return actionText
        }
    }

    private init(
        header: Header,
        steps: [Step],
        actionText: Text,
        action: @escaping @MainActor () async throws -> Void
    ) {
        self.header = header
        self.steps = steps
        self.actionText = actionText
        self.action = action
    }
    
    private func stepView(index: Int) -> some View {
        let step = steps[index]
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
                    .accessibilityHidden(step.title != nil)
                VStack(alignment: .leading, spacing: 8) {
                    if let title = step.title {
                        title
                            .bold()
                            .accessibilityLabel(Text(verbatim: "\(index + 1). ") + title)
                            .accessibilityAddTraits(.isHeader)
                    }
                    step.description
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


extension SequentialOnboardingView {
    /// Creates the default style of the `SequentialOnboardingView` that uses a combination of an ``OnboardingTitleView``
    /// and ``OnboardingActionsView``.
    ///
    /// - Parameters:
    ///   - title: The localized title.
    ///   - subtitle: The localized subtitle.
    ///   - steps: The sequential onboarding view's steps, defining the main content being built up step-by-step by the view.
    ///   - actionText: The localized text that should appear on the `SequentialOnboardingView`'s primary button.
    ///   - action: The close that is called then the primary button is pressed.
    public init(
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil, // swiftlint:disable:this function_default_parameter_at_end
        steps: [Step],
        actionText: LocalizedStringResource,
        action: @escaping @MainActor () async throws -> Void
    ) where Header == OnboardingTitleView {
        self.init(
            header: OnboardingTitleView(title: title, subtitle: subtitle),
            steps: steps,
            actionText: Text(actionText),
            action: action
        )
    }
    
    /// Creates the default style of the `SequentialOnboardingView` that uses a combination of an ``OnboardingTitleView``
    /// and ``OnboardingActionsView``.
    ///
    /// - Parameters:
    ///   - title: The title without localization.
    ///   - subtitle: The view's optional subtitle
    ///   - steps: The sequential onboarding view's steps, defining the main content being built up step-by-step by the view.
    ///   - actionText: The text that should appear on the `SequentialOnboardingView`'s primary button.
    ///   - action: The close that is called then the primary button is pressed.
    @_disfavoredOverload
    public init(
        title: some StringProtocol,
        subtitle: (some StringProtocol)? = String?.none, // swiftlint:disable:this function_default_parameter_at_end
        steps: [Step],
        actionText: some StringProtocol,
        action: @escaping @MainActor () async throws -> Void
    ) where Header == OnboardingTitleView {
        self.init(
            header: OnboardingTitleView(title: title, subtitle: subtitle),
            steps: steps,
            actionText: Text(actionText),
            action: action
        )
    }
    
    
    /// Creates a customized `SequentialOnboardingView` allowing a complete customization of the  `SequentialOnboardingView`'s title view.
    ///
    /// - Parameters:
    ///   - header: The header displayed at the top.
    ///   - steps: The sequential onboarding view's steps, defining the main content being built up step-by-step by the view.
    ///   - actionText: The text that should appear on the `SequentialOnboardingView`'s primary button without localization.
    ///   - action: The close that is called then the primary button is pressed.
    @_disfavoredOverload
    public init(
        @ViewBuilder header: () -> Header,
        steps: [Step],
        actionText: some StringProtocol,
        action: @escaping @MainActor () async throws -> Void
    ) {
        self.init(
            header: header(),
            steps: steps,
            actionText: Text(verbatim: String(actionText)),
            action: action
        )
    }
    
    /// Creates a customized `SequentialOnboardingView` allowing a complete customization of the  `SequentialOnboardingView`'s title view.
    ///
    /// - Parameters:
    ///   - header: The header displayed at the top.
    ///   - steps: The sequential onboarding view's steps, defining the main content being built up step-by-step by the view.
    ///   - actionText: The localized text that should appear on the ``SequentialOnboardingView``'s primary button.
    ///   - action: The close that is called then the primary button is pressed.
    public init(
        @ViewBuilder header: () -> Header,
        steps: [Step],
        actionText: LocalizedStringResource,
        action: @escaping @MainActor () async throws -> Void
    ) {
        self.init(
            header: header(),
            steps: steps,
            actionText: Text(actionText),
            action: action
        )
    }
}


#if DEBUG
#Preview {
    SequentialOnboardingView(
        title: String("Title"),
        subtitle: String("Subtitle"),
        steps: [
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
