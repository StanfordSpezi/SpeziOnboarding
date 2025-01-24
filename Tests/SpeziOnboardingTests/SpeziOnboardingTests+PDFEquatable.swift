//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit


// Wrapper type to have a proper `Equatable` conformance of the `PDFDocument`
struct PDFEquatableDocument: Equatable {
    let pdf: PDFDocument


    init(_ pdf: PDFDocument) {
        self.pdf = pdf
    }


    static func == (lhs: PDFEquatableDocument, rhs: PDFEquatableDocument) -> Bool {
        // Check if both documents have the same number of pages
        guard lhs.pdf.pageCount == rhs.pdf.pageCount else {
            return false
        }

        // Iterate through each page and compare their contents
        for index in 0..<lhs.pdf.pageCount {
            guard let page1 = lhs.pdf.page(at: index),
                  let page2 = rhs.pdf.page(at: index) else {
                return false
            }

            // Compare the text content of the pages
            let text1 = page1.string ?? ""
            let text2 = page2.string ?? ""
            if text1 != text2 {
                return false
            }
        }

        // If all pages are identical, the documents are equal
        return true
    }
}

extension PDFDocument {
    var equatable: PDFEquatableDocument {
        .init(self)
    }
}
