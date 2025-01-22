//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Error that can occur if PDF export fails in ``ConsentDocumentExport``.
enum ConsentDocumentExportError: LocalizedError {
    case invalidPdfData(String)


    var errorDescription: String? {
        switch self {
        case .invalidPdfData:
            String(
                localized: "Unable to generate valid PDF document from PDF data.",
                comment: """
                Error thrown if we generated a PDF document using TPPDF,
                but were unable to convert the generated data into a PDFDocument.
                """
            )
        }
    }
}
