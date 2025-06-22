//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import PencilKit
import SwiftUI
import TPPDF


@MainActor
struct PDFRenderer {
    enum ExportError: Error {
        case unableToProducePDF
    }
    
    private let consentDocument: ConsentDocument
    private let config: ConsentDocument.ExportConfiguration
    
    private let pdf: TPPDF.PDFDocument
    private let bodyTextStyle: PDFTextStyle
    
    init(consentDocument: ConsentDocument, config: ConsentDocument.ExportConfiguration) {
        self.consentDocument = consentDocument
        self.config = config
        self.bodyTextStyle = PDFTextStyle(name: "", font: config.fontSettings.documentContentFont)
        self.pdf = TPPDF.PDFDocument(format: config.paperSize.pdfPageFormat)
    }
    
    
    consuming func render() throws -> sending PDFKit.PDFDocument {
        if let title = consentDocument.metadata.title, !title.isEmpty {
            pdf.info.title = title
        }
        if config.includingTimestamp {
            pdf.add(.contentRight, attributedTextObject: renderedExportTimestamp())
        }
        if let header = renderedHeader() {
            pdf.add(.contentCenter, attributedTextObject: header)
        }
        for section in consentDocument.sections {
            try add(section)
        }
        let pdfData = try PDFGenerator(document: pdf).generateData()
        guard let pdfDocument = PDFKit.PDFDocument(data: pdfData) else {
            throw ExportError.unableToProducePDF // should be unreachable
        }
        return pdfDocument
    }
    
    
    private func renderedExportTimestamp() -> PDFAttributedText {
        var text = String(localized: "EXPORTED_TAG", bundle: .module)
        text += ": "
        text += DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        text += "\n\n\n\n"
        let attributedTitle = NSMutableAttributedString(
            string: text,
            attributes: [.font: config.fontSettings.headerExportTimeStampFont]
        )
        return PDFAttributedText(text: attributedTitle)
    }
    
    /// Exports the header text (i.e., document title) as a `PDFAttributedText`
    private func renderedHeader() -> PDFAttributedText? {
        guard let title = consentDocument.metadata.title, !title.isEmpty else {
            return nil
        }
        let attributedTitle = NSMutableAttributedString(
            string: title + "\n\n",
            attributes: [.font: config.fontSettings.headerTitleFont]
        )
        return PDFAttributedText(text: attributedTitle)
    }
}

extension PDFRenderer {
    private func add(_ section: ConsentDocument.Section) throws {
        switch section {
        case .markdown(let rawContent):
            addMarkdownBlock(rawContent)
        case .signature(let config):
            addRenderedSignature(config)
        case .toggle(let config):
            try addToggleBlock(config)
        case .select(let config):
            try addSelectBlock(config)
        }
    }
    
    
    private func addMarkdownBlock(_ text: String) {
        var markdownString = (try? AttributedString(
            markdown: text,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(String(localized: "MARKDOWN_LOADING_ERROR", bundle: .module))
        // Indirection needed to hide `Sendable` warnings of `NSFont` on macOS
        markdownString.mergeAttributes(.init([.font: config.fontSettings.documentContentFont]))
        let attrText = PDFAttributedText(text: NSAttributedString(markdownString))
        pdf.add(attributedTextObject: attrText)
    }
    
    
    private func addToggleBlock(_ toggleConfig: ConsentDocument.ToggleConfig) throws {
        let state = consentDocument.value(for: toggleConfig)
        let cellStyle = PDFTableCellStyle(
            borders: .none,
            font: config.fontSettings.documentContentFont
        )
        let table = PDFTable(rows: 1, columns: 2)
        table.widths = [0.8, 0.2] // sadly can't make this dynamic :/
        table.style.outline = .none
        table[0, 0] = PDFTableCell(
            content: try .init(content: toggleConfig.prompt),
            alignment: .left,
            style: cellStyle
        )
        table[0, 1] = PDFTableCell(
            content: try .init(content: String(localized: state ? "Yes" : "No")),
            alignment: .right,
            style: cellStyle
        )
        pdf.add(table: table)
        pdf.add(space: 12)
    }
    
    
    private func addSelectBlock(_ selectConfig: ConsentDocument.SelectConfig) throws {
        let selection = consentDocument.value(for: selectConfig)
        let cellStyle = PDFTableCellStyle(
            borders: .none,
            font: config.fontSettings.documentContentFont
        )
        let table = PDFTable(rows: 1, columns: 2)
        table.widths = [0.75, 0.25] // sadly can't make this dynamic :/
        table.style.outline = .none
        table[0, 0] = PDFTableCell(
            content: try .init(content: selectConfig.prompt),
            alignment: .left,
            style: cellStyle
        )
        table[0, 1] = PDFTableCell(
            content: try .init(content: selectConfig.options.first { $0.id == selection }?.title),
            alignment: .right,
            style: cellStyle
        )
        pdf.add(table: table)
        pdf.add(space: 12)
    }
    
    /// Exports the signature as a `PDFGroup`, including the prefix ("X"), the name of the signee, the date, as well as the signature image.
    private func addRenderedSignature(_ signatureConfig: ConsentDocument.SignatureConfig) {
        let storage = consentDocument.value(for: signatureConfig)
        let personName = storage.name.formatted(.name(style: .long))
        #if !os(macOS)
        let group = PDFGroup(
            allowsBreaks: false,
            backgroundImage: PDFImage(image: storage.signatureImage(size: storage.size)),
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
        let signaturePrefix = "X " + storage.signature
        #endif
        group.set(font: config.fontSettings.signaturePrefixFont)
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
            font: config.fontSettings.signatureCaptionFont
        )
        // Add person name to the left cell
        table[0, 0] = PDFTableCell(
            content: try? .init(content: personName),
            alignment: .left,
            style: cellStyle
        )
        // Add formatted date to the right cell
        table[0, 1] = PDFTableCell(
            content: try? .init(content: consentDocument.signatureDate ?? ""),
            alignment: .right,
            style: cellStyle
        )
        group.add(.left, table: table)
        pdf.add(group: group)
    }
}


extension ConsentDocument.SignatureStorage {
    #if !os(macOS)
    @MainActor
    fileprivate func signatureImage(size: CGSize) -> UIImage {
        let scale: CGFloat
        #if os(iOS)
        scale = UIScreen.main.scale
        #else
        scale = 3 // retina scale is default
        #endif
        // As the `PKDrawing.image()` function automatically converts the ink color dependent on the used color scheme (light or dark mode),
        // force the tint color used in the `UIImage` to `black`.
        let image = signature.image(
            from: .init(x: 0, y: 0, width: size.width, height: size.height),
            scale: scale
        )
        return image
            .withRenderingMode(.alwaysTemplate)
            .withTintColor(.black)
    }
    #endif
}
