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


/// Extension of `ConsentDocument` enabling the export of the signed consent page.
extension ConsentDocument {
    #if !os(macOS)
    /// As the `PKDrawing.image()` function automatically converts the ink color dependent on the used color scheme (light or dark mode),
    /// force the ink used in the `UIImage` of the `PKDrawing` to always be black by adjusting the signature ink according to the color scheme.
    @MainActor private var blackInkSignatureImage: UIImage {
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
    @MainActor
    private func exportBody(markdown: AttributedString) -> some View {
        VStack {
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
            
            Text(markdown)
                .padding()
            
            Spacer()
            
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
                #if !os(macOS)
                .frame(width: signatureSize.width, height: signatureSize.height)
                #else
                .padding(.horizontal, 100)
                #endif
        }
    }
    
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
        
        let renderer = ImageRenderer(content: exportBody(markdown: markdownString))
        let paperSize = CGSize(
            width: exportConfiguration.paperSize.dimensions.width,
            height: exportConfiguration.paperSize.dimensions.height
        )
        renderer.proposedSize = .init(paperSize)
        
        return await withCheckedContinuation { continuation in
            renderer.render { _, context in
                var box = CGRect(origin: .zero, size: paperSize)
                
                /// Create in-memory `CGContext` that stores the PDF
                guard let mutableData = CFDataCreateMutable(kCFAllocatorDefault, 0),
                      let consumer = CGDataConsumer(data: mutableData),
                      let pdf = CGContext(consumer: consumer, mediaBox: &box, nil) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                pdf.beginPDFPage(nil)
                pdf.translateBy(x: 0, y: 0)
                
                context(pdf)
                
                pdf.endPDFPage()
                pdf.closePDF()
                
                continuation.resume(returning: PDFDocument(data: mutableData as Data))
            }
        }
    }
}
