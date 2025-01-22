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
    private let name: PersonNameComponents
    private let formattedDate: String?
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
            let name = name.formatted(.name(style: .long))
            Text(name)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, lineOffset - 18)
                .accessibilityLabel(Text("SIGNATURE_NAME \(name)", bundle: .module))
                .accessibilityHidden(name.isEmpty)

            Spacer()

            if let formattedDate {
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, lineOffset - 18)
                    .accessibilityLabel(Text("SIGNATURE_DATE \(formattedDate)", bundle: .module))
                    .accessibilityHidden(formattedDate.isEmpty)
            }
        }
    }
    
    
    /// Creates a new instance of an `SignatureViewBackground`.
    /// - Parameters:
    ///   - name: The name that is displayed under the signature line.
    ///   - formattedDate: The formatted date that is displayed under the signature line.
    ///   - lineOffset: Defines the distance of the signature line from the bottom of the view. The default value is 30.
    ///   - backgroundColor: The color of the background of the signature canvas.
    #if !os(macOS)
    init(
        name: PersonNameComponents = PersonNameComponents(),
        formattedDate: String? = nil,
        lineOffset: CGFloat = 30,
        backgroundColor: UIColor = .secondarySystemBackground
    ) {
        self.name = name
        self.formattedDate = formattedDate
        self.lineOffset = lineOffset
        self.backgroundColor = backgroundColor
    }
    #else
    init(
        name: PersonNameComponents = PersonNameComponents(),
        formattedDate: String? = nil,
        lineOffset: CGFloat = 30,
        backgroundColor: NSColor = .secondarySystemFill
    ) {
        self.name = name
        self.formattedDate = formattedDate
        self.lineOffset = lineOffset
        self.backgroundColor = backgroundColor
    }
    #endif
}


#if DEBUG
#Preview("No signature date") {
    ZStack(alignment: .bottomLeading) {
        SignatureViewBackground(
            name: .init(givenName: "Leland", familyName: "Stanford"),
            formattedDate: nil
        )
    }
        .frame(height: 120)
}

#Preview("Including signature date") {
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()


    ZStack(alignment: .bottomLeading) {
        SignatureViewBackground(
            name: .init(givenName: "Leland", familyName: "Stanford"),
            formattedDate: dateFormatter.string(from: .now)
        )
    }
        .frame(height: 120)
}
#endif
