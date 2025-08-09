//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
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
///         OnboardingInformationView.Area(
///             iconSymbol: "pc",
///             title: "PC",
///             description: "This is a PC."
///         ),
///         OnboardingInformationView.Area(
///             iconSymbol: "desktopcomputer",
///             title: "Mac",
///             description: "This is an iMac."
///         )
///     ],
///     actionText: "Continue"
/// ) {
///     // Action that should be performed upon tapping the "Continue" button ...
/// }
/// ```
///
/// In implementation, you can treat the header, content, and footer as regular SwiftUI Views.
/// However, to simplify things, you can also use the built-in ``OnboardingTitleView`` and built-in ``OnboardingActionsView``, as demonstrated below.
/// ``` swift
/// OnboardingView {
///     OnboardingTitleView(
///         title: "Title",
///         subtitle: "Subtitle"
///     )
/// } content: {
///     VStack {
///         Text("This is the onboarding content.")
///             .font(.headline)
///     }
/// } footer: {
///     OnboardingActionsView("Continue") {
///         // navigate to next onboarding page
///     }
/// }
/// ```
public struct OnboardingView<Header: View, Content: View, Footer: View>: View {
    @Environment(\.verticalScrollIndicatorVisibility) private var scrollIndicatorVisibility
    @Environment(\.isInManagedNavigationStack) private var isInManagedNavigationStack
    @Environment(\.isFirstInManagedNavigationStack) private var isFirstInManagedNavigationStack
    @Environment(\.onboardingViewEdgesWithPaddingDisabled) private var edgesWithPaddingDisabled
    
    private let wrapInScrollView: Bool
    private let header: Header
    private let content: Content
    private let footer: Footer
    
    @_documentation(visibility: internal)
    public var body: some View {
        GeometryReader { geometry in
            if wrapInScrollView {
                ScrollView {
                    makeContents(geometry: geometry)
                }
                .scrollIndicators(effectiveScrollIndicatorVisibility, axes: .vertical)
            } else {
                makeContents(geometry: geometry)
            }
        }
    }
    
    /// The set of edges for which we want to apply implicit padding.
    ///
    /// - Note: This excludes the bottom edge, which is handled separately.
    private var edgesWithImplicitPadding: Edge.Set {
        // if the view is used as part of an `ManagedNavigationStack`, we don't want the extra padding at the top,
        // since that's where the navigation bar will be and we're already getting some padding via that.
        let edges: Edge.Set = isInManagedNavigationStack ? .horizontal : [.horizontal, .top]
        return edges.subtracting(edgesWithPaddingDisabled)
    }
    
    private var bottomPadding: CGFloat {
        // 34, because we hav 10 points of default padding we want, plus the 24 points added to the view as a whole.
        edgesWithPaddingDisabled.contains(.bottom) ? 0 : 34
    }
    
    private var effectiveScrollIndicatorVisibility: ScrollIndicatorVisibility {
        let visibility = scrollIndicatorVisibility
        return visibility == .automatic ? .hidden : visibility
    }
    
    
    /// Creates a customized `OnboardingView` allowing a complete customization of the  `OnboardingView`.
    /// 
    /// - Parameters:
    ///   - wrapInScrollView: Whether the `OnboardingView` should wrap its body (i.e., the `header`, the `content`, and the `footer`) in a `ScrollView`.
    ///       Defaults to `true`, but can be set to `false` to work around some edge cased, like e.g. when the `content` is/contains
    ///       a `Form` (which already wraps its content in a `ScrollView`), in which case this parameter allows you to avoid getting double, nested `ScrollView`s.
    ///   - header: The header view displayed at the top.
    ///   - content: The content view.
    ///   - footer: The footer view displayed at the bottom.
    public init(
        wrapInScrollView: Bool = true,
        @ViewBuilder header: () -> Header = { EmptyView() },
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.wrapInScrollView = wrapInScrollView
        self.header = header()
        self.content = content()
        self.footer = footer()
    }
    
    
    /// Creates the default style of the `OnboardingView` uses a combination of an ``OnboardingTitleView``, ``OnboardingInformationView``,
    /// and ``OnboardingActionsView``.
    ///
    /// - Parameters:
    ///   - title: The onboarding view's localized title.
    ///   - subtitle: The onboarding view's optional localized subtitle.
    ///   - areas: The onboarding view's, defining the view's main content.
    ///   - actionText: The localized text that should appear on the ``OnboardingView``'s primary button.
    ///   - action: The close that is called then the primary button is pressed.
    public init(
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil, // swiftlint:disable:this function_default_parameter_at_end
        areas: [OnboardingInformationView.Area],
        actionText: LocalizedStringResource,
        action: @escaping @MainActor () async throws -> Void
    ) where Header == OnboardingTitleView, Content == OnboardingInformationView, Footer == OnboardingActionsView {
        self.init {
            OnboardingTitleView(title: title, subtitle: subtitle)
        } content: {
            OnboardingInformationView(areas: areas)
        } footer: {
            OnboardingActionsView(actionText) {
                try await action()
            }
        }
    }
    
    /// Creates the default style of the `OnboardingView` uses a combination of an ``OnboardingTitleView``, ``OnboardingInformationView``,
    /// and ``OnboardingActionsView``.
    /// 
    /// - Parameters:
    ///   - title: The title without localization.
    ///   - subtitle: The subtitle without localization.
    ///   - areas: The onboarding view's, defining the view's main content.
    ///   - actionText: The text that should appear on the `OnboardingView`'s primary button without localization.
    ///   - action: The close that is called then the primary button is pressed.
    @_disfavoredOverload
    public init(
        title: some StringProtocol,
        subtitle: (some StringProtocol)? = String?.none, // swiftlint:disable:this function_default_parameter_at_end
        areas: [OnboardingInformationView.Area],
        actionText: some StringProtocol,
        action: @escaping @MainActor () async throws -> Void
    ) where Header == OnboardingTitleView, Content == OnboardingInformationView, Footer == OnboardingActionsView {
        self.init {
            OnboardingTitleView(title: title, subtitle: subtitle)
        } content: {
            OnboardingInformationView(areas: areas)
        } footer: {
            OnboardingActionsView(actionText) {
                try await action()
            }
        }
    }
    
    
    @ViewBuilder
    private func makeContents(geometry: GeometryProxy) -> some View {
        VStack(alignment: .center) {
            VStack {
                header
                content
                    // if we don't have a footer, we apply the bottom padding here
                    .padding(.bottom, footer is EmptyView ? bottomPadding : 0)
            }
            if !(footer is EmptyView) {
                Spacer()
                footer
                    // if we do have a footer, we apply it here
                    .padding(.bottom, bottomPadding)
            }
        }
        .padding(edgesWithImplicitPadding, 24)
        // if this is the first view in a Stack, we need to add an implicit extra top padding,
        // in order to compensate for the fact that the other steps in the stack will get some de-facto
        // top padding via the navigation bar (which won't be present in the first step).
        .padding(.top, isFirstInManagedNavigationStack ? 24 : 0)
        .frame(minHeight: geometry.size.height)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}


extension EnvironmentValues {
    @Entry fileprivate var onboardingViewEdgesWithPaddingDisabled: Edge.Set = []
}


extension OnboardingView {
    /// Disables the ``OnboardingView``'s implicit padding for the specified edges.
    ///
    /// If this modifier is applied multiple times, the outermost call will take precedence.
    ///
    /// - Note: If the ``OnboardingView`` is contained in a `ManagedNavigationStack`, its top edge will already be disabled implicitly.
    public func disablePadding(_ edges: Edge.Set) -> some View {
        self.environment(\.onboardingViewEdgesWithPaddingDisabled, edges)
    }
}


#if DEBUG
#Preview {
    let mock: [OnboardingInformationView.Area] = [
        OnboardingInformationView.Area(
            iconSymbol: "pc",
            title: String("PC"),
            description: String("This is a PC. And we can write a lot about PCs in a section like this. A very long text!")
        ),
        OnboardingInformationView.Area(
            iconSymbol: "desktopcomputer",
            title: String("Mac"),
            description: String("This is an iMac")
        ),
        OnboardingInformationView.Area(
            iconSymbol: "laptopcomputer",
            title: String("MacBook"),
            description: String("This is a MacBook")
        )
    ]

    OnboardingView(
        title: String("Title"),
        subtitle: String("Subtitle"),
        areas: mock,
        actionText: String("Primary Button")
    ) {
        print("Primary!")
    }
}
#endif
