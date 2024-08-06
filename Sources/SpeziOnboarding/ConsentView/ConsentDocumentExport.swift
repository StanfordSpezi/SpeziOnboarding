//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit

/// A type representing an exported `ConsentDocument`. It holds the exported `PDFDocument` and the corresponding document identifier String.
public actor ConsentDocumentExport {
    private var cachedPDF: PDFDocument
    
    /// An unique identifier for the exported `ConsentDocument`.
    /// Corresponds to the identifier which was passed  when creating the `ConsentDocument` using an `OnboardingConsentView`.
    public let documentIdentifier: String
    /// The `PDFDocument` exported from a `ConsentDocument`.
    /// This property is asynchronous and accesing it potentially triggers the export of the PDF from the underlying `ConsentDocument`,
    /// if the `ConsentDocument` has not been previously exported or the `PDFDocument` was not cached.
    /// For now, we always require a PDF to be cached to create a ConsentDocumentExport. In the future, we might change this to lazy-PDF loading.
    public var pdf: PDFDocument {
        get async {
            cachedPDF
        }
    }
    

    /// Creates a `ConsentDocumentExport`, which holds an exported PDF and the corresponding document identifier string.
    /// - Parameters:
    ///   - documentIdentfier: A unique String identifying the exported `ConsentDocument`.
    ///   - cachedPDF: A `PDFDocument` exported from a `ConsentDocument`.
    init(
        documentIdentifier: String,
        cachedPDF: PDFDocument
    ) {
        self.documentIdentifier = documentIdentifier
        self.cachedPDF = cachedPDF
    }
}
