//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


extension ConsentDocument.ExportConfiguration {
    /// Provides default values for fields related to the `ConsentDocumentExportConfiguration`.
    public enum Defaults {
        #if !os(macOS)
        /// Default export font settings with fixed font sizes, ensuring a consistent appearance across platforms.
        ///
        /// This configuration uses `systemFont` and `boldSystemFont` with absolute font sizes to achieve uniform font sizes
        /// on different operating systems such as macOS, iOS, and visionOS.
        public static let defaultExportFontSettings = FontSettings(
            signatureNameFont: UIFont.systemFont(ofSize: 10),
            signaturePrefixFont: UIFont.boldSystemFont(ofSize: 12),
            documentContentFont: UIFont.systemFont(ofSize: 12),
            headerTitleFont: UIFont.boldSystemFont(ofSize: 28),
            headerExportTimeStampFont: UIFont.systemFont(ofSize: 8)
        )

        /// Default font based on system standards. In contrast to defaultExportFontSettings,
        /// the font sizes might change according to the system settings, potentially leading to varying exported PDF documents
        /// on devices with different system settings (e.g., larger default font size).
        public static let defaultSystemDefaultFontSettings = FontSettings(
            signatureNameFont: UIFont.preferredFont(forTextStyle: .subheadline),
            signaturePrefixFont: UIFont.preferredFont(forTextStyle: .title2),
            documentContentFont: UIFont.preferredFont(forTextStyle: .body),
            headerTitleFont: UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize),
            headerExportTimeStampFont: UIFont.preferredFont(forTextStyle: .caption1)
        )
        #else
        /// Default export font settings with fixed font sizes, ensuring a consistent appearance across platforms.
        ///
        /// This configuration uses `systemFont` and `boldSystemFont` with absolute font sizes to achieve uniform font sizes
        /// on different operating systems such as macOS, iOS, and visionOS.
        public static let defaultExportFontSettings = FontSettings(
            signatureNameFont: NSFont.systemFont(ofSize: 10),
            signaturePrefixFont: NSFont.boldSystemFont(ofSize: 12),
            documentContentFont: NSFont.systemFont(ofSize: 12),
            headerTitleFont: NSFont.boldSystemFont(ofSize: 28),
            headerExportTimeStampFont: NSFont.systemFont(ofSize: 8)
        )

        /// Default font based on system standards. In contrast to defaultExportFontSettings,
        /// the font sizes might change according to the system settings, potentially leading to varying exported PDF documents
        /// on devices with different system settings (e.g., larger default font size).
        public static let defaultSystemDefaultFontSettings = FontSettings(
            signatureNameFont: NSFont.preferredFont(forTextStyle: .subheadline),
            signaturePrefixFont: NSFont.preferredFont(forTextStyle: .title2),
            documentContentFont: NSFont.preferredFont(forTextStyle: .body),
            headerTitleFont: NSFont.boldSystemFont(ofSize: NSFont.preferredFont(forTextStyle: .largeTitle).pointSize),
            headerExportTimeStampFont: NSFont.preferredFont(forTextStyle: .caption1)
        )
        #endif
    }
}
