//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import CoreGraphics
import Foundation
import SwiftUI
import PencilKit

extension ConsentView {
    public enum PaperSize {
        case a4
        case usLetter

        var dimensions: (width: CGFloat, height: CGFloat) {
            let pointsPerInch: CGFloat = 72.0

            switch self {
            case .a4:
                let widthInInches: CGFloat = 8.3
                let heightInInches: CGFloat = 11.7
                return (widthInInches * pointsPerInch, heightInInches * pointsPerInch)
            case .usLetter:
                let widthInInches: CGFloat = 8.5
                let heightInInches: CGFloat = 11.0
                return (widthInInches * pointsPerInch, heightInInches * pointsPerInch)
            }
        }
    }

    
    func exportBody(markdown: AttributedString) -> some View {
        VStack {
            HStack {
                Spacer()
                
                Text("Exported: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))")
                    .font(.caption)
            }
            .padding()
            
            Text("Spezi Consent")
                .font(.title)
            
            Text(markdown)
                .padding()
            
            Spacer()
            
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                Text("X")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30 + 2)
                Text(name.formatted(.name(style: .long)))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30 - 18)
                Image(uiImage: signature.image(from: .init(x: 0, y: 0, width: signatureSize.width, height: signatureSize.height), scale: UIScreen.main.scale))
            }
            .frame(width: signatureSize.width, height: signatureSize.height)
        }
    }
    
    
    func export() async {
        guard let asyncMarkdown else {
            return
        }
        
        let markdown = await asyncMarkdown()
        
        guard let markdownString = try? AttributedString(
                markdown: markdown,
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) else {
             return
        }
        
        let renderer = ImageRenderer(content: exportBody(markdown: markdownString))
        let paperSize = CGSize(
            width: PaperSize.usLetter.dimensions.width,
            height: PaperSize.usLetter.dimensions.height
        )
        // US Letter Size
        renderer.proposedSize = .init(paperSize)
        
        renderer.render { size, context in
            //var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            //var box = CGRect(x: 0, y: 0, width: widthInPoints, height: widthInPoints)
            var box = CGRect(origin: .zero, size: paperSize)
            
            guard let mutableData = CFDataCreateMutable(kCFAllocatorDefault, 0),
                  let consumer = CGDataConsumer(data: mutableData),
                  let pdf = CGContext(consumer: consumer, mediaBox: &box, nil) else {
                return
            }
            
            pdf.beginPDFPage(nil)
            pdf.translateBy(
                x: 0,
                y: 0
            )
            
            context(pdf)
            
            pdf.endPDFPage()
            pdf.closePDF()
            
            let data = mutableData as Data
            onboardingDataSource.store(data)
        }
    }
    //}
    
/*
    #if DEBUG
    struct ExportView_Previews: PreviewProvider {
        static var previews: some View {
            ExportView(
                name: .init(givenName: "Philipp", familyName: "Zagar"),
                signature: .init(),
                signatureSize: .zero,
                markdownData: .init("This is a *markdown* **example**".utf8)
            )
        }
    }
    #endif
 */
}
