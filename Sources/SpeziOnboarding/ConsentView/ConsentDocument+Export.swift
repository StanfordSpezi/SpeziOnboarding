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
import WebKit
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
    
    /// Creates a representation of the consent form that is ready to be exported via the SwiftUI `ImageRenderer`.
    ///
    /// - Parameters:
    ///   - markdown: The markdown consent content as an `AttributedString`.
    ///
    /// - Returns: A SwiftUI `View` representation of the consent content and signature.
    ///
    /// - Note: This function avoids the use of asynchronous operations.
    /// Asynchronous tasks are incompatible with SwiftUI's `ImageRenderer`,
    /// which expects all rendering processes to be synchronous.
    
    
    /// Exports the signed consent form as a `PDFDocument` via the SwiftUI `ImageRenderer`.
    ///
    /// Renders the `PDFDocument` according to the specified ``ConsentDocument/ExportConfiguration``.
    ///
    /// - Returns: The exported consent form in PDF format as a PDFKit `PDFDocument`
    @MainActor
    func export() async -> PDFDocument? {
        let markdown = await asyncMarkdown()

        let markdownString = (try? AttributedString(
            markdown: markdown,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(String(localized: "MARKDOWN_LOADING_ERROR", bundle: .module))

        let pageSize = CGSize(
            width: exportConfiguration.paperSize.dimensions.width,
            height: exportConfiguration.paperSize.dimensions.height
        )

        let pages = paginatedViews(markdown: markdownString)

        print("NumPages: \(pages.count)")
    
        guard let mutableData = CFDataCreateMutable(kCFAllocatorDefault, 0),
                let consumer = CGDataConsumer(data: mutableData),
                let pdf = CGContext(consumer: consumer, mediaBox: nil, nil) else {
            
            return nil;
        }

        for page in pages {
            pdf.beginPDFPage(nil)
            
            let hostingController = UIHostingController(rootView: page)
                hostingController.view.frame = CGRect(origin: .zero, size: pageSize)

                let renderer = UIGraphicsImageRenderer(bounds: hostingController.view.bounds)
                let image = renderer.image { ctx in
                    hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
                }

            pdf.saveGState()

            pdf.translateBy(x: 0, y: pageSize.height)
            pdf.scaleBy(x: 1.0, y: -1.0)

            hostingController.view.layer.render(in: pdf)

            pdf.restoreGState()
                
            
            pdf.endPDFPage()
        }

        pdf.closePDF()
        return PDFDocument(data: mutableData as Data); 
    }
    
    private func paginatedViews(markdown: AttributedString) -> [AnyView] 
    {
        /*
        This algorithm splits the consent document consisting of title, text and signature
        across multiple pages, if titleHeight + signatureHeight + textHeight is larger than 1 page. 
        
        Let's call header = title, and footer = signature.
        
        The algorithm ensures that headerHeight + footerHeight + textHeight <= pageHeight.
        headerHeight is set to 200 on the first page, and to 50 on all subsequent pages (as we do not have a title anymore).
        footerHeight is always constant at 150 on each page, even if there is no footer, because we need the footerHeight
        to determine if we are actually on the last page (check improvements below).
        Tested for 1, 2 and 3 pages for dinA4 and usLetter size documents.

        Possible improvements:
            * The header height on the first page should not be hardcoded to 200, but calculated from 
            VStack consisting of export tag + title; if there is no export tag, the headerHeight can be smaller.
            * The footerHeight could/should only be set for the last page. However, the algorithm then becomes more complicated: To know if we are on the last page, we check if headerHeight + footerHeight + textHeight <= pageHeight. If footerHeight is 0 we have more space for the text. If we then find out that we are actually 
            on the last page, we would have to set footerHeight to 150 and thus we have less space for the text. Thus,
            it could happen that know we are not on the last page anymore but need one extra page.

        Known problems:
            * If we assume headerHeight too small (e.g., 100), then truncation happens.
        */
        var pages = [AnyView]()
        var remainingMarkdown = markdown
        let pageSize = CGSize(width: exportConfiguration.paperSize.dimensions.width, height: exportConfiguration.paperSize.dimensions.height)
        // Maximum header height on the first page, i.e., size of
        // the VStack containing the export tag + title.
        // Better calculate this instead of hardcoding.
        let headerHeightFirstPage: CGFloat = 200
        // Header height on all subsequent pages. Should come from exportConfiguration.
        let headerHeightOtherPages: CGFloat = 50
        let footerHeight: CGFloat = 150

        var headerHeight = headerHeightFirstPage

        while !remainingMarkdown.unicodeScalars.isEmpty {
            let (currentPageContent, nextPageContent) = split(markdown: remainingMarkdown, pageSize: pageSize, headerHeight: headerHeight, footerHeight: footerHeight)
            
            // In the first iteration, headerHeight was headerHeightFirstPage.
            // In all subsequent iterations, we only need headerHeightOtherPages.
            // Hence, more text fits on the page.
            headerHeight = headerHeightOtherPages;

            let currentPage: AnyView = AnyView(
                VStack {
                    if pages.isEmpty {  // First page
                        
                        VStack{
                            if exportConfiguration.includingTimestamp {
                                HStack {
                                    Spacer()

                                    Text("EXPORTED_TAG", bundle: .module)
                                        + Text(verbatim: ": \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))")
                                }
                                .font(.caption)
                                .padding()
                            }
                            
                            OnboardingTitleView(title: exportConfiguration.consentTitle)
                        }
                        .padding()

                    } else {
                        // If we are not on the first page, we add a spacing of headerHeight,
                        // which should now be set to "headerHeightOtherPages".
                        VStack{}.padding(.top, headerHeight)
                    }

                    Text(currentPageContent)
                        .padding()

                    Spacer()

                    if nextPageContent.unicodeScalars.isEmpty {  // Last page
                        ZStack(alignment: .bottomLeading) {
                            SignatureViewBackground(name: name, backgroundColor: .clear)

                            #if !os(macOS)
                            Image(uiImage: blackInkSignatureImage)
                            #else
                            Text(signature)
                                .padding(.bottom, 32)
                                .padding(.leading, 46)
                                .font(.custom("Snell Roundhand", size: 24))
                            #endif
                        }
                        .padding(.bottom, footerHeight)
                    }
                }
                .frame(width: pageSize.width, height: pageSize.height)
            )

            pages.append(currentPage)
            remainingMarkdown = nextPageContent
        }

        return pages
    }

    private func split(markdown: AttributedString, pageSize: CGSize, headerHeight: CGFloat, footerHeight: CGFloat) -> (AttributedString, AttributedString) 
    {
        // This algorithm determines at which index to split the text, if textHeight + headerHeight + footerHeight > pageSize.
        // The algorithm returns the text that still fits on the current page,
        // and the remaining text which needs to be placed on subsequent page(s).
        // If remaining == 0, this means we have reached the last page, as all remaining text
        // can fit on the current page.

        // The algorithm works by creating a virtual text storage container with width = pageSize.width
        // and height = pageSize.height - footerHeight - headerHeight.
        // We can then ask "how much text fits in this virtual text storage container" by checking it's
        // glyphRange. The glyphRange tells us how many characters of the given text fit into the text container.
        // Specifically, glyphRange is exactly the index AFTER the last word (not character) that STILL FITS on the page.
        // We can then split the text as follows:
        // let index = container.glyphRange // Index after last word which still fits on the page.
        // currentPage = markdown[0:index]
        // remaining = markdown[index:]

        let contentHeight = pageSize.height - headerHeight - footerHeight
        var currentPage = AttributedString()
        var remaining = markdown

        let textStorage = NSTextStorage(attributedString: NSAttributedString(markdown))
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: pageSize.width, height: contentHeight))
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        var accumulatedHeight: CGFloat = 0       
        let maximumRange = layoutManager.glyphRange(for: textContainer)
     
        currentPage = AttributedString(textStorage.attributedSubstring(from: maximumRange))
        remaining = AttributedString(textStorage.attributedSubstring(from: NSRange(location: maximumRange.length, length: textStorage.length - maximumRange.length)))

        return (currentPage, remaining)
    }
}