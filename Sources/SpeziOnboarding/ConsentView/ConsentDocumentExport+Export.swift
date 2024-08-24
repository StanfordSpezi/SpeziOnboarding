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

        #if !os(macOS)
        let font = UIFont.preferredFont(forTextStyle: .caption1)
        #else
        let font = NSFont.preferredFont(forTextStyle: .caption1)
        #endif
        
        let attributedTitle = NSMutableAttributedString(
            string: stampText,
            attributes: [
                NSAttributedString.Key.font: font
            ]
        )
        
        return PDFAttributedText(text: attributedTitle)
    }
    
    /// Converts the header text (i.e., document title) to a PDFAttributedText, which can be
    /// added to the exported PDFDocument.
    ///
    /// - Returns: A TPPDF `PDFAttributedText` representation of the document title.
    private func exportHeader() -> PDFAttributedText {
        #if !os(macOS)
        let largeTitleFont = UIFont.preferredFont(forTextStyle: .largeTitle)
        let boldLargeTitleFont = UIFont.boldSystemFont(ofSize: largeTitleFont.pointSize)
        #else
        let largeTitleFont = NSFont.preferredFont(forTextStyle: .largeTitle)
        let boldLargeTitleFont = NSFont.boldSystemFont(ofSize: largeTitleFont.pointSize)
        #endif

        let attributedTitle = NSMutableAttributedString(
            string: exportConfiguration.consentTitle.localizedString() + "\n\n",
            attributes: [
                NSAttributedString.Key.font: boldLargeTitleFont
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
        let markdownString = (try? AttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(String(localized: "MARKDOWN_LOADING_ERROR", bundle: .module))
        
        return PDFAttributedText(text: NSAttributedString(markdownString))
    }
    
    #if !os(macOS)
    /// Exports the signature to a `PDFGroup` which can be added to the exported PDFDocument.
    /// The signature group will contain a prefix ("X"), the name of the signee as well as the signature image.
    ///
    /// - Parameters:
    ///     - personName: A string containing the name of the person who signed the document.
    ///     - signatureImage: Signature drawn when signing the document.
    /// - Returns: A TPPDF `PDFAttributedText` representation of the export time stamp.
    @MainActor
    private func exportSignature() -> PDFGroup {
        let personName = name.formatted(.name(style: .long))

        let group = PDFGroup(
            allowsBreaks: false,
            backgroundImage: PDFImage(image: signatureImage),
            padding: EdgeInsets(top: 50, left: 50, bottom: 0, right: 100)
        )
        
        let signaturePrefixFont = UIFont.preferredFont(forTextStyle: .title2)
        let nameFont = UIFont.preferredFont(forTextStyle: .subheadline)
        let signatureColor = UIColor.secondaryLabel
        let signaturePrefix = "X"

        group.set(font: signaturePrefixFont)
        group.set(textColor: signatureColor)
        group.add(PDFGroupContainer.left, text: signaturePrefix)
    
        group.addLineSeparator(style: PDFLineStyle(color: .black))
        
        group.set(font: nameFont)
        group.add(PDFGroupContainer.left, text: personName)
        return group
    }
    #else
    /// Exports the signature to a `PDFGroup` which can be added to the exported PDFDocument.
    /// The signature group will contain a prefix ("X"), the name of the signee as well as the signature image.
    ///
    /// - Parameters:
    ///     - personName: A string containing the name of the person who signed the document.
    /// - Returns: A TPPDF `PDFAttributedText` representation of the export time stamp.
    @MainActor
    private func exportSignature() -> PDFGroup {
        let personName = name.formatted(.name(style: .long))

        // On macOS, we do not have a "drawn" signature, hence do
        // not set a backgroundImage for the PDFGroup.
        // Instead, we render the person name.
        let group = PDFGroup(
            allowsBreaks: false,
            padding: EdgeInsets(top: 50, left: 50, bottom: 0, right: 100)
        )
        
        let signaturePrefixFont = NSFont.preferredFont(forTextStyle: .title2)
        let nameFont = NSFont.preferredFont(forTextStyle: .subheadline)
        let signatureColor = NSColor.secondaryLabelColor
        let signaturePrefix = "X " + signature
        
        group.set(font: signaturePrefixFont)
        group.set(textColor: signatureColor)
        group.add(PDFGroupContainer.left, text: signaturePrefix)
    
        group.addLineSeparator(style: PDFLineStyle(color: .black))
        
        group.set(font: nameFont)
        group.add(PDFGroupContainer.left, text: personName)
        return group
    }
    #endif
    
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
    ) async -> PDFKit.PDFDocument? {
        let document = TPPDF.PDFDocument(format: exportConfiguration.getPDFPageFormat())
        
        if let exportStamp = exportTimeStamp {
            document.add(.contentRight, attributedTextObject: exportStamp)
        }
        
        document.add(.contentCenter, attributedTextObject: header)
        document.add(attributedTextObject: pdfTextContent)
        document.add(group: signatureFooter)
        
        // Convert TPPDF.PDFDocument to PDFKit.PDFDocument
        let generator = PDFGenerator(document: document)
        
        if let data = try? generator.generateData() {
            if let pdfKitDocument = PDFKit.PDFDocument(data: data) {
                return pdfKitDocument
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    #if !os(macOS)
    /// Exports the signed consent form as a `PDFKit.PDFDocument`.
    /// The PDF generated by TPPDF and then converted to a TPDFKit.PDFDocument.
    /// Renders the `PDFDocument` according to the specified ``ConsentDocument/ExportConfiguration``.
    ///
    /// - Parameters:
    ///     - personName: A string containing the name of the person who signed the document.
    ///     - signatureImage: Signature drawn when signing the document.
    /// - Returns: The exported consent form in PDF format as a PDFKit `PDFDocument`
    @MainActor
    public func export() async -> PDFKit.PDFDocument? {
        let exportTimeStamp = exportConfiguration.includingTimestamp ? exportTimeStamp() : nil
        let header = exportHeader()
        let pdfTextContent = await exportDocumentContent()
        let signature = exportSignature()
            
        return await createDocument(
            header: header,
            pdfTextContent: pdfTextContent,
            signatureFooter: signature,
            exportTimeStamp: exportTimeStamp
        )
    }
    #else
    /// Exports the signed consent form as a `PDFKit.PDFDocument`.
    /// The PDF generated by TPPDF and then converted to a TPDFKit.PDFDocument.
    /// Renders the `PDFDocument` according to the specified ``ConsentDocument/ExportConfiguration``.
    ///
    /// - Parameters:
    ///     - personName: A string containing the name of the person who signed the document.
    /// - Returns: The exported consent form in PDF format as a PDFKit `PDFDocument`
    @MainActor
    public func export() async -> PDFKit.PDFDocument? {
        let exportTimeStamp = exportConfiguration.includingTimestamp ? exportTimeStamp() : nil
        let header = exportHeader()
        let pdfTextContent = await exportDocumentContent()
        let signature = exportSignature()
            
        return await createDocument(
            header: header,
            pdfTextContent: pdfTextContent,
            signatureFooter: signature,
            exportTimeStamp: exportTimeStamp
        )
    }
    #endif
}
