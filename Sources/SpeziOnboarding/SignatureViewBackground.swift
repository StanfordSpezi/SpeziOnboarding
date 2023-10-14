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
    private let lineOffset: CGFloat
    private let backgroundColor: UIColor
    
    
    var body: some View {
        Color(uiColor: backgroundColor)
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

        let name = name.formatted(.name(style: .long))
        Text(name)
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.horizontal, 20)
            .padding(.bottom, lineOffset - 18)
            .accessibilityLabel(Text("SIGNATURE_NAME \(name)", bundle: .module))
            .accessibilityHidden(name.isEmpty)
    }
    
    
    /// Creates a new instance of an ``SignatureViewBackground``.
    /// - Parameters:
    ///   - name: The name that is displayed under the signature line.
    ///   - lineOffset: Defines the distance of the signature line from the bottom of the view. The default value is 30.
    ///   - backgroundColor: The color of the background of the signature canvas.
    init(
        name: PersonNameComponents = PersonNameComponents(),
        lineOffset: CGFloat = 30,
        backgroundColor: UIColor = .secondarySystemBackground
    ) {
        self.name = name
        self.lineOffset = lineOffset
        self.backgroundColor = backgroundColor
    }
}
