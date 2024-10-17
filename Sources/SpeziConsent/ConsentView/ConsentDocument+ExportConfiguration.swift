//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension ConsentDocument {
    /// The ``ExportConfiguration`` enables developers to define the properties of the exported consent form.
    public struct ExportConfiguration {
        /// Represents common paper sizes with their dimensions.
        ///
        /// You can use the `dimensions` property to get the width and height of each paper size in points.
        ///
        /// - Note: The dimensions are calculated based on the standard DPI (dots per inch) of 72 for print.
        public struct PaperSize {
            let width: CGFloat
            let height: CGFloat
            
            /// Standard US Letter paper size.
            public static var usLetter: PaperSize { usLetter() }
            /// Standard DIN A4 paper size.
            public static var dinA4: PaperSize { dinA4() }
            
            /// Standard US Letter paper size with variable resolution.
            public static func usLetter(pointsPerInch: CGFloat = 72) -> PaperSize {
                let widthInInches: CGFloat = 8.5
                let heightInInches: CGFloat = 11.0
                return .init(
                    width: widthInInches * pointsPerInch,
                    height: heightInInches * pointsPerInch
                )
            }
            
            /// Standard DIN A4 paper size with variable resolution.
            public static func dinA4(pointsPerInch: CGFloat = 72) -> PaperSize {
                let widthInInches: CGFloat = 8.3
                let heightInInches: CGFloat = 11.7
                return .init(
                    width: widthInInches * pointsPerInch,
                    height: heightInInches * pointsPerInch
                )
            }
            
            /// Create a custom paper size in points by points.
            public init(width: CGFloat, height: CGFloat) {
                self.width = width
                self.height = height
            }
        }
        
        
        let consentTitle: LocalizedStringResource
        let paperSize: PaperSize
        let includingTimestamp: Bool
        
        
        /// Creates an `ExportConfiguration` specifying the properties of the exported consent form.
        /// - Parameters:
        ///   - paperSize: The page size of the exported form represented by ``ConsentDocument/ExportConfiguration/PaperSize``.
        ///   - consentTitle: The title of the exported consent form.
        ///   - includingTimestamp: Indicates if the exported form includes a timestamp.
        public init(
            paperSize: PaperSize = .usLetter,
            consentTitle: LocalizedStringResource = LocalizationDefaults.exportedConsentFormTitle,
            includingTimestamp: Bool = true
        ) {
            self.paperSize = paperSize
            self.consentTitle = consentTitle
            self.includingTimestamp = includingTimestamp
        }
    }
}
