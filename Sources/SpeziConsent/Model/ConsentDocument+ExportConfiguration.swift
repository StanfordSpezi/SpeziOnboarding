//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziViews
import SwiftUI
import TPPDF


extension ConsentDocument {
    /// Define the properties of an exported ``ConsentDocument``.
    public struct ExportConfiguration: Equatable, Sendable {
        /// Represents common paper sizes with their dimensions.
        ///
        /// You can use the ``dimensions`` property to get the width and height of each paper size in points.
        ///
        /// - Note: The dimensions are calculated based on the standard DPI (dots per inch) of 72 for print.
        public enum PaperSize: Equatable, Sendable {
            /// Standard US Letter paper size.
            case usLetter
            /// Standard DIN A4 paper size.
            case dinA4
            
            /// Provides the dimensions of the paper in points.
            ///
            /// - Returns: A tuple containing the width and height of the paper in points.
            var dimensions: (width: CGFloat, height: CGFloat) {
                let pointsPerInch: CGFloat = 72.0
                switch self {
                case .usLetter:
                    let widthInInches: CGFloat = 8.5
                    let heightInInches: CGFloat = 11.0
                    return (widthInInches * pointsPerInch, heightInInches * pointsPerInch)
                case .dinA4:
                    let widthInInches: CGFloat = 8.3
                    let heightInInches: CGFloat = 11.7
                    return (widthInInches * pointsPerInch, heightInInches * pointsPerInch)
                }
            }

            ///  `TPPDF/PDFPageFormat` which corresponds to SpeziOnboarding's `PaperSize`.
            var pdfPageFormat: PDFPageFormat {
                switch self {
                case .usLetter: .usLetter
                case .dinA4: .a4
                }
            }
        }
        
        /// The ``FontSettings`` store configuration of the fonts used to render the exported
        /// consent document, i.e., fonts for the content, title and signature.
        public struct FontSettings: Equatable, @unchecked Sendable {
            /// The font of the caption rendered below the signature line.
            public let signatureCaptionFont: UINSFont
            /// The font of the prefix of the signature ("X" in most cases).
            public let signaturePrefixFont: UINSFont
            /// The font of the content of the document (i.e., the rendered markdown text)
            public let documentContentFont: UINSFont
            /// The font of the header (i.e., title of the document).
            public let headerTitleFont: UINSFont
            /// The font of the export timestamp (optionally rendered in the top right document corner,
            /// if exportConfiguration.includingTimestamp is true).
            public let headerExportTimeStampFont: UINSFont
            
            /// Creates an instance`FontSettings` specifying the fonts of various components of the exported document
            ///
            /// - Parameters:
            ///   - signatureCaptionFont: The font used for the signature caption.
            ///   - signaturePrefixFont: The font used for the signature prefix text.
            ///   - documentContentFont: The font used for the main content of the document.
            ///   - headerTitleFont: The font used for the header title.
            ///   - headerExportTimeStampFont: The font used for the header timestamp.
            public init(
                signatureCaptionFont: UINSFont,
                signaturePrefixFont: UINSFont,
                documentContentFont: UINSFont,
                headerTitleFont: UINSFont,
                headerExportTimeStampFont: UINSFont
            ) {
                self.signatureCaptionFont = signatureCaptionFont
                self.signaturePrefixFont = signaturePrefixFont
                self.documentContentFont = documentContentFont
                self.headerTitleFont = headerTitleFont
                self.headerExportTimeStampFont = headerExportTimeStampFont
            }
        }

        let paperSize: PaperSize
        let includingTimestamp: Bool
        let fontSettings: FontSettings
        
        /// Creates an Export Configuration
        ///
        /// - Parameters:
        ///   - paperSize: The desired page size of the exported form.
        ///   - includingTimestamp: Indicates if the exported form includes a timestamp.
        ///   - fontSettings: Font settings for the exported form.
        public init(
            paperSize: PaperSize = .usLetter,
            includingTimestamp: Bool = true,
            fontSettings: FontSettings = .default
        ) {
            self.paperSize = paperSize
            self.includingTimestamp = includingTimestamp
            self.fontSettings = fontSettings
        }
    }
}


extension ConsentDocument.ExportConfiguration.FontSettings {
    /// Default export font settings with fixed font sizes, ensuring a consistent appearance across platforms.
    ///
    /// This configuration uses `systemFont` and `boldSystemFont` with absolute font sizes to achieve uniform font sizes
    /// on different operating systems such as macOS, iOS, and visionOS.
    public static let `default` = Self(
        signatureCaptionFont: .systemFont(ofSize: 10),
        signaturePrefixFont: .boldSystemFont(ofSize: 12),
        documentContentFont: .systemFont(ofSize: 12),
        headerTitleFont: .boldSystemFont(ofSize: 28),
        headerExportTimeStampFont: .systemFont(ofSize: 8)
    )

    /// Default font based on system standards. In contrast to defaultExportFontSettings,
    /// the font sizes might change according to the system settings, potentially leading to varying exported PDF documents
    /// on devices with different system settings (e.g., larger default font size).
    public static let systemDefault = Self(
        signatureCaptionFont: .preferredFont(forTextStyle: .subheadline),
        signaturePrefixFont: .preferredFont(forTextStyle: .title2),
        documentContentFont: .preferredFont(forTextStyle: .body),
        headerTitleFont: .boldSystemFont(ofSize: UINSFont.preferredFont(forTextStyle: .largeTitle).pointSize),
        headerExportTimeStampFont: .preferredFont(forTextStyle: .caption1)
    )
}
