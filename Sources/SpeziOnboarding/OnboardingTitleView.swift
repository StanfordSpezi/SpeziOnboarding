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
    private let title: Text
    private let subtitle: Text?
    
    @_documentation(visibility: internal) // swiftlint:disable:next attributes
    public var body: some View {
        VStack(alignment: ProcessInfo.isIOS26 ? .leading : .center) {
            title
                .bold()
                .font(.largeTitle)
                .multilineTextAlignment(ProcessInfo.isIOS26 ? .leading : .center)
                .padding(.bottom)
                .accessibilityAddTraits(.isHeader)
            
            if let subtitle {
                subtitle
                    .multilineTextAlignment(ProcessInfo.isIOS26 ? .leading : .center)
            }
        }
        .padding(.vertical)
    }
    
    /// Creates an `OnboardingTitleView` instance that contains a title and an optional subtitle.
    /// - Parameters:
    ///   - title: The localized title.
    ///   - subtitle: The optional localized subtitle.
    public init(title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil) {
        self.title = Text(title)
        self.subtitle = subtitle.map { Text($0) }
    }
    
    /// Creates an `OnboardingTitleView` instance that contains a title and an optional subtitle.
    /// - Parameters:
    ///   - title: The title.
    ///   - subtitle: The optional subtitle.
    @_disfavoredOverload
    public init(title: some StringProtocol, subtitle: (some StringProtocol)? = String?.none) {
        self.title = Text(title)
        self.subtitle = subtitle.map { Text($0) }
    }
}


#if DEBUG
#Preview {
    OnboardingTitleView(title: String("Title"), subtitle: String("Subtitle"))
}
#endif
