//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import PencilKit
import SwiftUI
import TPPDF

/// Extension of `ConsentDocumentExport` enabling the export of the signed consent page.
extension ConsentDocumentExport {
    /// Generates a `PDFAttributedText` containing the timestamp of the time at which the PDF was exported.
    ///
    /// - Returns: A TPPDF `PDFAttributedText` representation of the export time stamp.
    private func exportTimeStamp() -> PDFAttributedText {
        let stampText = String(localized: "EXPORTED_TAG", bundle: .module) + ": " +
                DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short) + "\n\n\n\n"

        let attributedTitle = NSMutableAttributedString(
            string: stampText,
            attributes: [
                NSAttributedString.Key.font: exportConfiguration.fontSettings.headerExportTimeStampFont
            ]
        )
        
        return PDFAttributedText(text: attributedTitle)
    }
    
    /// Converts the header text (i.e., document title) to a PDFAttributedText, which can be
    /// added to the exported PDFDocument.
    ///
    /// - Returns: A TPPDF `PDFAttributedText` representation of the document title.
    private func exportHeader() -> PDFAttributedText {
        let attributedTitle = NSMutableAttributedString(
            string: exportConfiguration.consentTitle.localizedString() + "\n\n",
            attributes: [
                NSAttributedString.Key.font: exportConfiguration.fontSettings.headerTitleFont
            ]
        )
        
        return PDFAttributedText(text: attributedTitle)
    }
    
    /// Converts the content (i.e., the markdown text) of the consent document to a PDFAttributedText,  which can be
    /// added to the exported PDFDocument.
    ///
    /// - Returns: A TPPDF `PDFAttributedText` representation of the document content.
    @MainActor
    private func exportDocumentContent() async -> PDFAttributedText {
        let markdown = await asyncMarkdown()
        var markdownString = (try? AttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(String(localized: "MARKDOWN_LOADING_ERROR", bundle: .module))
        
        markdownString.font = exportConfiguration.fontSettings.documentContentFont
        
        return PDFAttributedText(text: NSAttributedString(markdownString))
    }
    
    /// Exports the signature to a `PDFGroup` which can be added to the exported PDFDocument.
    /// The signature group will contain a prefix ("X"), the name of the signee as well as the signature image.
    ///
    /// - Returns: A TPPDF `PDFAttributedText` representation of the export time stamp.
    @MainActor
    private func exportSignature() -> PDFGroup {
        let personName = name.formatted(.name(style: .long))
        
        #if !os(macOS)
        let group = PDFGroup(
            allowsBreaks: false,
            backgroundImage: PDFImage(image: signatureImage),
            padding: EdgeInsets(top: 50, left: 50, bottom: 0, right: 100)
        )
        let signaturePrefix = "X"
        #else
        // On macOS, we do not have a "drawn" signature, hence we do
        // not set a backgroundImage for the PDFGroup.
        // Instead, we render the person name.
        let group = PDFGroup(
            allowsBreaks: false,
            padding: EdgeInsets(top: 50, left: 50, bottom: 0, right: 100)
        )
        let signaturePrefix = "X " + signature
        #endif

        group.set(font: exportConfiguration.fontSettings.signaturePrefixFont)
        group.add(PDFGroupContainer.left, text: signaturePrefix)
    
        group.addLineSeparator(style: PDFLineStyle(color: .black))
        
        group.set(font: exportConfiguration.fontSettings.signatureNameFont)
        group.add(PDFGroupContainer.left, text: personName)
        return group
    }
   
    
    /// Creates a `PDFKit.PDFDocument` containing the header, content and signature from the exported `ConsentDocument`.
    /// An export time stamp can be added optionally.
    ///
    /// - Parameters:
    ///     - header: The header of the document exported to a PDFAttributedText, e.g., using `exportHeader()`.
    ///     - pdfTextContent: The content of the document exported to a PDFAttributedText, e.g., using `exportDocumentContent()`.
    ///     - signatureFooter: The footer including the signature of the document, exported to a PDFGroup, e.g., using `exportSignature()`.
    ///     - exportTimeStamp: Optional parameter representing the timestamp of the time at which the document was exported. Can be created using `exportTimeStamp()`
    /// - Returns: The exported consent form in PDF format as a PDFKit `PDFDocument`
    @MainActor
    private func createDocument(
        header: PDFAttributedText,
        pdfTextContent: PDFAttributedText,
        signatureFooter: PDFGroup,
        exportTimeStamp: PDFAttributedText? = nil
    ) async throws -> PDFKit.PDFDocument {
        let document = TPPDF.PDFDocument(format: exportConfiguration.getPDFPageFormat())
        
        if let exportStamp = exportTimeStamp {
            document.add(.contentRight, attributedTextObject: exportStamp)
        }
        
        document.add(.contentCenter, attributedTextObject: header)
        document.add(attributedTextObject: pdfTextContent)
        document.add(group: signatureFooter)
        
        // Convert TPPDF.PDFDocument to PDFKit.PDFDocument
        let generator = PDFGenerator(document: document)
        
        let data = try generator.generateData()
        
        guard let pdfDocument = PDFKit.PDFDocument(data: data) else {
            throw ConsentDocumentExportError.invalidPdfData("PDF data not compatible with PDFDocument")
        }

        return pdfDocument
    }
    
    /// Exports the signed consent form as a `PDFKit.PDFDocument`.
    /// The PDF generated by TPPDF and then converted to a TPDFKit.PDFDocument.
    /// Renders the `PDFDocument` according to the specified ``ConsentDocument/ExportConfiguration``.
    ///
    /// - Returns: The exported consent form in PDF format as a PDFKit `PDFDocument`
    @MainActor
    public func export() async throws -> PDFKit.PDFDocument {
        let exportTimeStamp = exportConfiguration.includingTimestamp ? exportTimeStamp() : nil
        let header = exportHeader()
        let pdfTextContent = await exportDocumentContent()
        let signature = exportSignature()
            
        return try await createDocument(
            header: header,
            pdfTextContent: pdfTextContent,
            signatureFooter: signature,
            exportTimeStamp: exportTimeStamp
        )
    }
}
