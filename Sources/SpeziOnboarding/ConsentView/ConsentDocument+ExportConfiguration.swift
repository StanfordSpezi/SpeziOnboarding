//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


extension ConsentDocument {
    /// The ``ExportConfiguration`` enables developers to define the properties of the exported consent form.
    public struct ExportConfiguration: Sendable {
        /// Represents common paper sizes with their dimensions.
        ///
        /// You can use the `dimensions` property to get the width and height of each paper size in points.
        ///
        /// - Note: The dimensions are calculated based on the standard DPI (dots per inch) of 72 for print.
        public enum PaperSize: Sendable {
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
        }
        
        #if !os(macOS)
        /// The ``FontSettings`` store configuration of the fonts used to render the exported
        /// consent document, i.e., fonts for the content, title and signature.
        public struct FontSettings: Sendable {
            /// The font of the caption rendered below the signature line.
            public let signatureCaptionFont: UIFont
            /// The font of the prefix of the signature ("X" in most cases).
            public let signaturePrefixFont: UIFont
            /// The font of the content of the document (i.e., the rendered markdown text)
            public let documentContentFont: UIFont
            /// The font of the header (i.e., title of the document).
            public let headerTitleFont: UIFont
            /// The font of the export timestamp (optionally rendered in the top right document corner,
            /// if exportConfiguration.includingTimestamp is true).
            public let headerExportTimeStampFont: UIFont
            
            /// Creates an instance`FontSettings` specifying the fonts of various components of the exported document
            ///
            /// - Parameters:
            ///   - signatureCaptionFont: The font used for the signature caption.
            ///   - signaturePrefixFont: The font used for the signature prefix text.
            ///   - documentContentFont: The font used for the main content of the document.
            ///   - headerTitleFont: The font used for the header title.
            ///   - headerExportTimeStampFont: The font used for the header timestamp.
            public init(
                signatureCaptionFont: UIFont,
                signaturePrefixFont: UIFont,
                documentContentFont: UIFont,
                headerTitleFont: UIFont,
                headerExportTimeStampFont: UIFont
            ) {
                self.signatureCaptionFont = signatureCaptionFont
                self.signaturePrefixFont = signaturePrefixFont
                self.documentContentFont = documentContentFont
                self.headerTitleFont = headerTitleFont
                self.headerExportTimeStampFont = headerExportTimeStampFont
            }
        }
        #else
        /// The ``FontSettings`` store configuration of the fonts used to render the exported
        /// consent document, i.e., fonts for the content, title and signature.
        public struct FontSettings: @unchecked Sendable {
            /// The font of the caption rendered below the signature line.
            public let signatureCaptionFont: NSFont
            /// The font of the prefix of the signature ("X" in most cases).
            public let signaturePrefixFont: NSFont
            /// The font of the content of the document (i.e., the rendered markdown text)
            public let documentContentFont: NSFont
            /// The font of the header (i.e., title of the document).
            public let headerTitleFont: NSFont
            /// The font of the export timestamp (optionally rendered in the top right document corner,
            /// if exportConfiguration.includingTimestamp is true).
            public let headerExportTimeStampFont: NSFont
            
            /// Creates an instance`FontSettings` specifying the fonts of various components of the exported document
            ///
            /// - Parameters:
            ///   - signatureCaptionFont: The font used for the signature caption.
            ///   - signaturePrefixFont: The font used for the signature prefix text.
            ///   - documentContentFont: The font used for the main content of the document.
            ///   - headerTitleFont: The font used for the header title.
            ///   - headerExportTimeStampFont: The font used for the header timestamp.
            public init(
                signatureCaptionFont: NSFont,
                signaturePrefixFont: NSFont,
                documentContentFont: NSFont,
                headerTitleFont: NSFont,
                headerExportTimeStampFont: NSFont
            ) {
                self.signatureCaptionFont = signatureCaptionFont
                self.signaturePrefixFont = signaturePrefixFont
                self.documentContentFont = documentContentFont
                self.headerTitleFont = headerTitleFont
                self.headerExportTimeStampFont = headerExportTimeStampFont
            }
        }
        #endif

           
        let consentTitle: LocalizedStringResource
        let paperSize: PaperSize
        let includingTimestamp: Bool
        let fontSettings: FontSettings

        
        /// Creates an `ExportConfiguration` specifying the properties of the exported consent form.
        /// - Parameters:
        ///   - paperSize: The page size of the exported form represented by ``ConsentDocument/ExportConfiguration/PaperSize``.
        ///   - consentTitle: The title of the exported consent form.
        ///   - includingTimestamp: Indicates if the exported form includes a timestamp.
        ///   - fontSettings: Font settings for the exported form.
        public init(
            paperSize: PaperSize = .usLetter,
            consentTitle: LocalizedStringResource = LocalizationDefaults.exportedConsentFormTitle,
            includingTimestamp: Bool = true,
            fontSettings: FontSettings = ExportConfiguration.Defaults.defaultExportFontSettings
        ) {
            self.paperSize = paperSize
            self.consentTitle = consentTitle
            self.includingTimestamp = includingTimestamp
            self.fontSettings = fontSettings
        }
    }
}
