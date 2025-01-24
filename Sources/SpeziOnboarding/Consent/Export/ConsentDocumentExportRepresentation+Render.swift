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


/// Extension of `ConsentDocumentExportRepresentation` enabling the export of the signed consent page.
extension ConsentDocumentExportRepresentation {
    /// Generates a `PDFAttributedText` containing the timestamp of the time at which the PDF was exported.
    private var renderedTimeStamp: PDFAttributedText? {
        guard configuration.includingTimestamp else {
            return nil
        }

        let stampText = String(localized: "EXPORTED_TAG", bundle: .module) + ": " +
                DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short) + "\n\n\n\n"

        let attributedTitle = NSMutableAttributedString(
            string: stampText,
            attributes: [
                NSAttributedString.Key.font: configuration.fontSettings.headerExportTimeStampFont
            ]
        )

        return PDFAttributedText(text: attributedTitle)
    }

    /// Exports the header text (i.e., document title) as a `PDFAttributedText`
    private var renderedHeader: PDFAttributedText {
        let attributedTitle = NSMutableAttributedString(
            string: configuration.consentTitle.localizedString() + "\n\n",
            attributes: [
                NSAttributedString.Key.font: configuration.fontSettings.headerTitleFont
            ]
        )
        
        return PDFAttributedText(text: attributedTitle)
    }
    
    /// Renders the content (i.e., the markdown text) of the consent document as a `PDFAttributedText`.
    private var renderedDocumentContent: PDFAttributedText {
        var markdownString = (try? AttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(String(localized: "MARKDOWN_LOADING_ERROR", bundle: .module))
        
        markdownString.font = configuration.fontSettings.documentContentFont

        return PDFAttributedText(text: NSAttributedString(markdownString))
    }
    
    /// Exports the signature as a `PDFGroup`, including the prefix ("X"), the name of the signee, the date, as well as the signature image.
    private var renderedSignature: PDFGroup {
        let personName = name.formatted(.name(style: .long))

        #if !os(macOS)
        let group = PDFGroup(
            allowsBreaks: false,
            backgroundImage: PDFImage(image: signature),
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

        group.set(font: configuration.fontSettings.signaturePrefixFont)
        group.add(.left, text: signaturePrefix)
    
        group.addLineSeparator(style: PDFLineStyle(color: .black))

        // Add person name and date as the caption below the signature line
        // Sadly a quite complex table is required to have the caption within one line
        let table = PDFTable(rows: 1, columns: 2)
        table.widths = [0.5, 0.5] // Two equal-width columns for left and right alignment
        table.margin = .zero
        table.padding = 0
        table.style.outline = .none

        let cellStyle = PDFTableCellStyle(
            colors: (Color.clear, Color.black),
            borders: .none,
            font: configuration.fontSettings.signatureCaptionFont
        )

        // Add person name to the left cell
        table[0, 0] = PDFTableCell(
            content: try? .init(content: personName),
            alignment: .left,
            style: cellStyle
        )

        // Add formatted date to the right cell
        table[0, 1] = PDFTableCell(
            content: try? .init(content: formattedSignatureDate ?? ""),
            alignment: .right,
            style: cellStyle
        )

        group.add(.left, table: table)

        return group
    }


    /// Render the signed consent form in PDF format as a `PDFKit.PDFDocument`.
    public func render() throws -> PDFKit.PDFDocument {
        let document = TPPDF.PDFDocument(format: configuration.paperSize.pdfPageFormat)

        if let renderedTimeStamp {
            document.add(.contentRight, attributedTextObject: renderedTimeStamp)
        }
        document.add(.contentCenter, attributedTextObject: renderedHeader)
        document.add(attributedTextObject: renderedDocumentContent)
        document.add(group: renderedSignature)

        // Convert `TPPDF.PDFDocument` to `PDFKit.PDFDocument`
        let pdfData = try PDFGenerator(document: document).generateData()
        
        guard let pdfDocument = PDFKit.PDFDocument(data: pdfData) else {
            preconditionFailure("Rendered PDF data from TPPDF could not be converted to PDFKit.PDFDocument.")   // never happens
        }

        return pdfDocument
    }
}
