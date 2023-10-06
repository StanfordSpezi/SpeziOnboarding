//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PDFKit


extension ConsentView {
    /// Represents common paper sizes with their dimensions.
    ///
    /// You can use the `dimensions` property to get the width and height of each paper size in points.
    ///
    /// - Note: The dimensions are calculated based on the standard DPI (dots per inch) of 72 for print.
    public enum PaperSize {
        /// Standard DIN A4 paper size.
        case dinA4
        /// Standard US Letter paper size.
        case usLetter

        /// Provides the dimensions of the paper in points.
        ///
        /// - Returns: A tuple containing the width and height of the paper in points.
        var dimensions: (width: CGFloat, height: CGFloat) {
            let pointsPerInch: CGFloat = 72.0

            switch self {
            case .dinA4:
                let widthInInches: CGFloat = 8.3
                let heightInInches: CGFloat = 11.7
                return (widthInInches * pointsPerInch, heightInInches * pointsPerInch)
            case .usLetter:
                let widthInInches: CGFloat = 8.5
                let heightInInches: CGFloat = 11.0
                return (widthInInches * pointsPerInch, heightInInches * pointsPerInch)
            }
        }
    }
}
