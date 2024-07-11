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

/// Extension of `ConsentDocument` enabling the export of the signed consent page.
extension ConsentDocument {
    #if !os(macOS)
    /// As the `PKDrawing.image()` function automatically converts the ink color dependent on the used color scheme (light or dark mode),
    /// force the ink used in the `UIImage` of the `PKDrawing` to always be black by adjusting the signature ink according to the color scheme.
    private var blackInkSignatureImage: UIImage {
        var updatedDrawing = PKDrawing()
    
        for stroke in signature.strokes {
            let blackStroke = PKStroke(
                ink: PKInk(stroke.ink.inkType, color: colorScheme == .light ? .black : .white),
                path: stroke.path,
                transform: stroke.transform,
                mask: stroke.mask
            )

            updatedDrawing.strokes.append(blackStroke)
        }

        #if os(iOS)
        let scale = UIScreen.main.scale
        #else
        let scale = 3.0 // retina scale is default
        #endif

        return updatedDrawing.image(
            from: .init(x: 0, y: 0, width: signatureSize.width, height: signatureSize.height),
            scale: scale
        )
    }
    #endif
    
    /// Generates a `PDFAttributedText` containing the timestamp of when the PDF was exported.
    ///
    /// - Returns: A TPPDF `PDFAttributedText` representation of the export time stamp.
    func exportTimeStamp() -> PDFAttributedText {
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
    func exportHeader() -> PDFAttributedText {
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
    /// Exports the signature to a `PDFGroup` which can be added to the exported PDFDocument.
    /// The signature group will contain a prefix ("X"), the name of the signee as well as the signature image.
    ///
    /// - Returns: A TPPDF `PDFAttributedText` representation of the export time stamp.
    func exportSignature() -> PDFGroup {
        let personName = name.formatted(.name(style: .long))

        #if !os(macOS)
        
        let group = PDFGroup(
            allowsBreaks: false,
            backgroundImage: PDFImage(image: blackInkSignatureImage),
            padding: EdgeInsets(top: 50, left: 50, bottom: 0, right: 100)
        )
        
        let signaturePrefixFont = UIFont.preferredFont(forTextStyle: .title2)
        let nameFont = UIFont.preferredFont(forTextStyle: .subheadline)
        let signatureColor = UIColor.secondaryLabel
        let signaturePrefix = "X"
        #else
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
        let signaturePrefix = "X " + personName
        #endif
        
        group.set(font: signaturePrefixFont)
        group.set(textColor: signatureColor)
        group.add(PDFGroupContainer.left, text: signaturePrefix)
    
        group.addLineSeparator(style: PDFLineStyle(color: .black))
        
        group.set(font: nameFont)
        group.add(PDFGroupContainer.left, text: personName)
        return group
    }
    
    /// Returns a  `TPPDF.PDFPageFormat` which corresponds to Spezi's `ExportConfiguration.PaperSize`.
    ///
    /// - Parameters:
    ///   - paperSize: The paperSize of an ExportConfiguration.
    /// - Returns: A TPPDF `PDFPageFormat` according to the `ExportConfiguration.PaperSize`.
    func getPDFFormat(paperSize: ExportConfiguration.PaperSize) -> PDFPageFormat {
        switch paperSize {
        case .dinA4:
            return PDFPageFormat.a4
        case .usLetter:
            return PDFPageFormat.usLetter
        }
    }
    
    /// Exports the signed consent form as a `PDFKit.PDFDocument`.
    /// The PDF generated by TPPDF and then converted to a TPDFKit.PDFDocument.
    /// Renders the `PDFDocument` according to the specified ``ConsentDocument/ExportConfiguration``.
    ///
    /// - Returns: The exported consent form in PDF format as a PDFKit `PDFDocument`
    @MainActor
    func export() async -> PDFKit.PDFDocument? {
        // swiftlint:disable:all

        let markdown = await asyncMarkdown()
        let markdownString = (try? AttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(String(localized: "MARKDOWN_LOADING_ERROR", bundle: .module))
        
        let document = TPPDF.PDFDocument(format: getPDFFormat(paperSize: exportConfiguration.paperSize))
        
        if exportConfiguration.includingTimestamp {
            document.add(.contentRight, attributedTextObject: exportTimeStamp())
        }
        
        document.add(.contentCenter, attributedTextObject: exportHeader())
        document.add(attributedText: NSAttributedString(markdownString))
        document.add(group: exportSignature())
        
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
}
