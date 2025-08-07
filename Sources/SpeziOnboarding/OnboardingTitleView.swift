//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A unified onboarding title with an optional subtitle.
///
/// ```swift
/// OnboardingTitleView(title: "Title", subtitle: "Subtitle")
/// ```
public struct OnboardingTitleView: View {
    private static let isIOS26 = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
    
    private let title: Text
    private let subtitle: Text?
    
    public var body: some View {
        VStack(alignment: .leading) {
            title
                .bold()
                .font(.largeTitle)
                .multilineTextAlignment(Self.isIOS26 ? .leading : .center)
                .padding(.bottom)
                .accessibilityAddTraits(.isHeader)
            
            if let subtitle {
                subtitle
                    .multilineTextAlignment(Self.isIOS26 ? .leading : .center)
                    .padding(.bottom)
            }
        }
        .padding(.vertical)
    }
    
    
    /// Creates an `OnboardingTitleView` instance that only contains a title.
    /// - Parameter title: The localized title.
    public init(title: LocalizedStringResource) {
        self.init(title: title, subtitle: nil)
    }
    
    /// Creates an `OnboardingTitleView` instance that only contains a title.
    /// - Parameter title: The title.
    @_disfavoredOverload
    public init<Title: StringProtocol>(title: Title) {
        self.title = Text(verbatim: String(title))
        self.subtitle = nil
    }
    
    /// Creates an `OnboardingTitleView` instance that contains a title and a subtitle.
    /// - Parameters:
    ///   - title: The localized title.
    ///   - subtitle: The localized subtitle.
    public init(title: LocalizedStringResource, subtitle: LocalizedStringResource?) {
        self.title = Text(title)
        self.subtitle = subtitle.map { Text($0) }
    }
    
    /// Creates an `OnboardingTitleView` instance that contains a title and a subtitle.
    /// - Parameters:
    ///   - title: The title.
    ///   - subtitle: The subtitle.
    @_disfavoredOverload
    public init<Title: StringProtocol, Subtitle: StringProtocol>(title: Title, subtitle: Subtitle?) {
        self.title = Text(verbatim: String(title))
        self.subtitle = subtitle.map { Text(verbatim: String($0)) }
    }
}


#if DEBUG
#Preview {
    OnboardingTitleView(title: String("Title"), subtitle: String("Subtitle"))
}
#endif
