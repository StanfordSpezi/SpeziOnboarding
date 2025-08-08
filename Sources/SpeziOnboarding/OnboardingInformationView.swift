//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
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
    private let areas: [Area]
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            ForEach(0..<areas.count, id: \.self) { index in
                areaView(area: areas[index])
            }
        }
    }
    
    /// Creates an `OnboardingInformationView` instance with a collection of areas defined by the ``Area`` type.
    /// - Parameter areas: The areas that should be displayed.
    public init(areas: [Area]) {
        self.areas = areas
    }
    
    /// Creates an `OnboardingInformationView` instance with a collection of areas defined by the ``Area`` type.
    /// - Parameter areas: The areas that should be displayed.
    public init(@ArrayBuilder<Area> areas: () -> [Area]) {
        self.init(areas: areas())
    }
    
    private func areaView(area: Area) -> some View {
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
    OnboardingInformationView {
        OnboardingInformationView.Area(
            systemSymbol: "pc",
            title: String("PC"),
            description: String("This is a PC.")
        )
        OnboardingInformationView.Area(
            systemSymbol: "desktopcomputer",
            title: String("Mac"),
            description: String("This is an iMac.")
        )
    }
}
#endif
