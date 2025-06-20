//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The `SignatureViewBackground` provides the background view for the ``SignatureView`` including the name and the signature line.
struct SignatureViewBackground: View {
    private let footer: SignatureView.Footer
    private let lineOffset: CGFloat

    #if !os(macOS)
    private let backgroundColor: UIColor
    #else
    private let backgroundColor: NSColor
    #endif
    
    
    var body: some View {
        #if !os(macOS)
        Color(uiColor: backgroundColor)
        #else
        Color(nsColor: backgroundColor)
        #endif
        Rectangle()
            .fill(.secondary)
            .frame(maxWidth: .infinity, maxHeight: 1)
            .padding(.horizontal, 20)
            .padding(.bottom, lineOffset)
        Text(verbatim: "X")
            .font(.title2)
            .foregroundColor(.secondary)
            .padding(.horizontal, 20)
            .padding(.bottom, lineOffset + 2)
            .accessibilityHidden(true)

        HStack {
            Text(footer.nameText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1) // Ensures the name is restricted to a single line
                .truncationMode(.tail) // Truncate name at the end
                .padding(.horizontal, 20)
                .padding(.bottom, lineOffset - 18)
                .accessibilityLabel(Text("SIGNATURE_NAME \(footer.nameText)", bundle: .module))
                .accessibilityHidden(footer.nameText.isEmpty)
            Spacer()
            Text(footer.dateText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1) // Ensures the date is restricted to a single line
                .truncationMode(.middle) // Truncate date in the middle
                .padding(.horizontal, 20)
                .padding(.bottom, lineOffset - 18)
                .accessibilityLabel(Text("SIGNATURE_DATE \(footer.dateText)", bundle: .module))
                .accessibilityHidden(footer.dateText.isEmpty)
        }
    }
    
    
    /// Creates a new instance of an `SignatureViewBackground`.
    /// - Parameters:
    ///   - footer: The footer's content.
    ///   - formattedDate: The formatted date that is displayed under the signature line.
    ///   - lineOffset: Defines the distance of the signature line from the bottom of the view. The default value is 30.
    ///   - backgroundColor: The color of the background of the signature canvas.
    #if !os(macOS)
    init(
        footer: SignatureView.Footer,
        lineOffset: CGFloat = 30,
        backgroundColor: UIColor = .secondarySystemBackground
    ) {
        self.footer = footer
        self.lineOffset = lineOffset
        self.backgroundColor = backgroundColor
    }
    #else
    init(
        footer: SignatureView.Footer,
        lineOffset: CGFloat = 30,
        backgroundColor: NSColor = .secondarySystemFill
    ) {
        self.footer = footer
        self.lineOffset = lineOffset
        self.backgroundColor = backgroundColor
    }
    #endif
}


#if DEBUG
#Preview("No signature date") {
    let name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    ZStack(alignment: .bottomLeading) {
        SignatureViewBackground(footer: .init(
            name: name.formatted(.name(style: .long))
        ))
    }
    .frame(height: 120)
}

#Preview("Including signature date") {
    let name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    ZStack(alignment: .bottomLeading) {
        SignatureViewBackground(
            footer: .init(
                name: name.formatted(.name(style: .long)),
                date: Date.now.formatted(date: .numeric, time: .omitted)
            )
        )
    }
    .frame(height: 120)
}
#endif
