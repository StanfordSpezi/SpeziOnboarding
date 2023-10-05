//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The ``OnboardingTitleView`` allows developers to present a unified style for the in an onboarding flow.
/// The ``OnboardingTitleView`` can contain one title and a optional subtitle below the title.
///
/// ```swift
/// OnboardingTitleView(title: "Title", subtitle: "Subtitle")
/// ```
public struct OnboardingTitleView: View {
    private let title: String
    private let subtitle: String?
    private let paddingTop: CGFloat
    
    
    public var body: some View {
        VStack {
            Text(title)
                .bold()
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .padding(.top, paddingTop)
                .accessibilityAddTraits(.isHeader)
            if let subtitle = subtitle {
                Text(subtitle)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
            }
        }
    }
    
    
    /// Creates an ``OnboardingTitleView`` instance that only contains a title.
    /// - Parameter title: The localized title of the ``OnboardingTitleView``.
    public init(title: LocalizedStringResource, paddingTop: CGFloat = 30) {
        self.title = title.localizedString()
        self.subtitle = nil
        self.paddingTop = paddingTop
    }
    
    /// Creates an ``OnboardingTitleView`` instance that only contains a title.
    /// - Parameter title: The title of the ``OnboardingTitleView`` without localization.
    @_disfavoredOverload
    public init<Title: StringProtocol>(title: Title, paddingTop: CGFloat = 30) {
        self.title = String(title)
        self.subtitle = nil
        self.paddingTop = paddingTop
    }
    
    /// Creates an ``OnboardingTitleView`` instance that contains a title and a subtitle.
    /// - Parameters:
    ///   - title: The localized title of the ``OnboardingTitleView``.
    ///   - subtitle: The localized subtitle of the ``OnboardingTitleView``.
    public init(title: LocalizedStringResource, subtitle: LocalizedStringResource?, paddingTop: CGFloat = 30) {
        self.init(title: title.localizedString(), subtitle: subtitle?.localizedString(), paddingTop: paddingTop)
    }
    
    /// Creates an ``OnboardingTitleView`` instance that contains a title and a subtitle.
    /// - Parameters:
    ///   - title: The title of the ``OnboardingTitleView`` without localization.
    ///   - subtitle: The subtitle of the ``OnboardingTitleView`` without localization.
    @_disfavoredOverload
    public init<Title: StringProtocol, Subtitle: StringProtocol>(title: Title, subtitle: Subtitle?, paddingTop: CGFloat = 30) {
        self.title = String(title)
        self.subtitle = subtitle.flatMap { String($0) }
        self.paddingTop = paddingTop
    }
}


#if DEBUG
struct OnboardingTitleView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTitleView(title: "Title", subtitle: "Subtitle")
    }
}
#endif
