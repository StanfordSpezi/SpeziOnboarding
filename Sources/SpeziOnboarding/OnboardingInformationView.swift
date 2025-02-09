//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// Present informational content in a row-based style.
///
/// The `OnboardingInformationView` allows developers to present a unified style to display informational content as defined
/// by the ``OnboardingInformationView/Content`` type.
///
/// The following example displays an ``OnboardingInformationView`` with two information areas:
/// ```swift
/// OnboardingInformationView(
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
///     ]
/// )
/// ```
public struct OnboardingInformationView: View {
    /// A ``Content`` defines the way that information is displayed in an ``OnboardingInformationView``.
    public struct Content {
        /// The icon of the area in the ``OnboardingInformationView``.
        public let icon: AnyView
        /// The title of the area in the ``OnboardingInformationView``.
        public let title: Text
        /// The description of the area in the ``OnboardingInformationView``.
        public let description: Text

        private init(icon: AnyView, title: Text, description: Text) {
            self.icon = icon
            self.title = title
            self.description = description
        }

        /// Creates a new content for an area in the ``OnboardingInformationView``.
        /// - Parameters:
        ///   - icon: The icon of the area in the ``OnboardingInformationView``.
        ///   - title: The title of the area in the ``OnboardingInformationView`` without localization.
        ///   - description: The description of the area in the ``OnboardingInformationView`` without localization.
        @_disfavoredOverload
        public init<Icon: View, Title: StringProtocol, Description: StringProtocol>(
            @ViewBuilder icon: () -> Icon,
            title: Title,
            description: Description
        ) {
            self.init(icon: AnyView(icon()), title: Text(verbatim: String(title)), description: Text(verbatim: String(description)))
        }
        
        /// Creates a new content for an area in the ``OnboardingInformationView``.
        /// - Parameters:
        ///   - icon: The icon of the area in the ``OnboardingInformationView``.
        ///   - title: The localized title of the area in the ``OnboardingInformationView``.
        ///   - description: The localized description of the area in the ``OnboardingInformationView``.
        public init<Icon: View>(
            @ViewBuilder icon: () -> Icon,
            title: LocalizedStringResource,
            description: LocalizedStringResource
        ) {
            self.init(icon: AnyView(icon()), title: Text(title), description: Text(description))
        }
        
        /// Creates a new content for an area in the ``OnboardingInformationView``.
        /// - Parameters:
        ///   - icon: The icon of the area in the ``OnboardingInformationView``.
        ///   - title: The title of the area in the ``OnboardingInformationView`` without localization.
        ///   - description: The description of the area in the ``OnboardingInformationView`` without localization.
        @_disfavoredOverload
        public init<Title: StringProtocol, Description: StringProtocol>(
            icon: Image,
            title: Title,
            description: Description
        ) {
            self.init(icon: { icon }, title: title, description: description)
        }
        
        /// Creates a new content for an area in the ``OnboardingInformationView``.
        /// - Parameters:
        ///   - icon: The icon of the area in the ``OnboardingInformationView``.
        ///   - title: The localized title of the area in the ``OnboardingInformationView``.
        ///   - description: The localized description of the area in the ``OnboardingInformationView``.
        public init(
            icon: Image,
            title: LocalizedStringResource,
            description: LocalizedStringResource
        ) {
            self.init(icon: { icon }, title: title, description: description)
        }
    }
    
    
    private let areas: [Content]
    
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            ForEach(0..<areas.count, id: \.self) { index in
                areaView(area: areas[index])
            }
        }
    }
    
    
    /// Creates an `OnboardingInformationView` instance with a collection of areas defined by the ``Content`` type.
    /// - Parameter areas: The areas that should be displayed.
    public init(areas: [Content]) {
        self.areas = areas
    }
    
    
    private func areaView(area: Content) -> some View {
        HStack(spacing: 10) {
            area.icon
                .font(.system(size: 40))
                .frame(width: 40)
                .foregroundColor(.accentColor)
                .padding()
                .accessibilityHidden(true)
            
            VStack(alignment: .leading) {
                area.title
                    .bold()
                    .accessibilityAddTraits(.isHeader)
                area.description
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}


#if DEBUG
#Preview {
    OnboardingInformationView(
        areas: [
            OnboardingInformationView.Content(
                icon: Image(systemName: "pc"),
                title: String("PC"),
                description: String("This is a PC.")
            ),
            OnboardingInformationView.Content(
                icon: Image(systemName: "desktopcomputer"),
                title: String("Mac"),
                description: String("This is an iMac.")
            )
        ]
    )
}
#endif
