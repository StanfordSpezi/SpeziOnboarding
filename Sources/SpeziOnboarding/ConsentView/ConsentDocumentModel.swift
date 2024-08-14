//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import TPPDF

/// A type holding all information required for exporting a PDF from a `ConsentDocumentVIew`, such as the PDF content (i.e., markdown string) and the ExportConfiguration.
public struct ConsentDocumentModel {
    let asyncMarkdown: () async -> Data
    let exportConfiguration: ConsentDocument.ExportConfiguration
 
    /// Creates a `ConsentDocumentModel` which holds information related to the PDF export of a `ConsentView`.
    ///
    /// - Parameters:
    ///     - markdown: Markdown string of the consent document.
    ///     - exportConfiguration: An `ExportConfiguration` defining properties of the PDF exported from the `ConsentDocument`.
    public init(
        markdown: @escaping () async -> Data,
        exportConfiguration: ConsentDocument.ExportConfiguration
    ) {
        self.asyncMarkdown = markdown
        self.exportConfiguration = exportConfiguration
    }
}
