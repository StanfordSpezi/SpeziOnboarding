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
    private let title: Text
    private let subtitle: Text?

    
    public var body: some View {
        VStack {
            title
                .bold()
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .padding(.bottom)
                .accessibilityAddTraits(.isHeader)
            
            if let subtitle {
                subtitle
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
            }
        }
        .padding(.vertical)
    }
    
    
    /// Creates an ``OnboardingTitleView`` instance that only contains a title.
    /// - Parameter title: The localized title of the ``OnboardingTitleView``.
    public init(title: LocalizedStringResource) {
        self.init(title: title, subtitle: nil)
    }
    
    /// Creates an ``OnboardingTitleView`` instance that only contains a title.
    /// - Parameter title: The title of the ``OnboardingTitleView`` without localization.
    @_disfavoredOverload
    public init<Title: StringProtocol>(title: Title) {
        self.title = Text(verbatim: String(title))
        self.subtitle = nil
    }
    
    /// Creates an ``OnboardingTitleView`` instance that contains a title and a subtitle.
    /// - Parameters:
    ///   - title: The localized title of the ``OnboardingTitleView``.
    ///   - subtitle: The localized subtitle of the ``OnboardingTitleView``.
    public init(title: LocalizedStringResource, subtitle: LocalizedStringResource?) {
        self.title = Text(title)
        self.subtitle = subtitle.map { Text($0) }
    }
    
    /// Creates an ``OnboardingTitleView`` instance that contains a title and a subtitle.
    /// - Parameters:
    ///   - title: The title of the ``OnboardingTitleView`` without localization.
    ///   - subtitle: The subtitle of the ``OnboardingTitleView`` without localization.
    @_disfavoredOverload
    public init<Title: StringProtocol, Subtitle: StringProtocol>(title: Title, subtitle: Subtitle?) {
        self.title = Text(verbatim: String(title))
        self.subtitle = subtitle.map { Text(verbatim: String($0)) }
    }
}


#if DEBUG
struct OnboardingTitleView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTitleView(title: String("Title"), subtitle: String("Subtitle"))
    }
}
#endif
