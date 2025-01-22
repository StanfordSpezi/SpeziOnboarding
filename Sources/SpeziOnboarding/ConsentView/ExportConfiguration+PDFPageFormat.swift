//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import TPPDF


/// The ``ExportConfiguration`` enables developers to define the properties of the exported consent form.
extension ConsentDocument.ExportConfiguration {
    ///  `TPPDF.PDFPageFormat` which corresponds to SpeziOnboarding's `ExportConfiguration.PaperSize`.
    var pdfPageFormat: PDFPageFormat {
        switch paperSize {
        case .dinA4:
            return PDFPageFormat.a4
        case .usLetter:
            return PDFPageFormat.usLetter
        }
    }
}
