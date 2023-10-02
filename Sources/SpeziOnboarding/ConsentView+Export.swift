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

/// Extension of the ``ConsentView`` enabling the export of the signed consent page in the onboarding flow
extension ConsentView {
    /// Represents common paper sizes with their dimensions.
    ///
    /// You can use the `dimensions` property to get the width and height of each paper size in points.
    ///
    /// - Note: The dimensions are calculated based on the standard DPI (dots per inch) of 72 for print.
    public enum PaperSize {
        /// Standard A4 paper size.
        case a4
        /// Standard US Letter paper size.
        case usLetter

        /// Provides the dimensions of the paper in points.
        ///
        /// - Returns: A tuple containing the width and height of the paper in points.
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

    /// Creates a view representation of the consent content, ready for PDF export via SwiftUIs `ImageRenderer`
    ///
    /// This function constructs a view for presenting the markdown consent form. It combines the
    /// given markdown and the user's signature with details such as the date of export. It can be
    /// used to create exportable PDF documents of the consent form.
    ///
    /// - Parameters:
    ///   - markdown: The markdown consent content as an `AttributedString`.
    ///
    /// - Returns: A SwiftUI `View` representation of the consent content and signature.
    ///
    /// - Note: This function avoids the use of asynchronous operations.
    /// Asynchronous tasks are incompatible with SwiftUI's `ImageRenderer`,
    /// which expects all rendering processes to be synchronous.
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
    
    
    /// Exports the consent form as a PDF in the specified paper size.
    ///
    /// This function retrieves the markdown content, renders it to an image, and saves it as a PDF
    /// with the provided paper size. The resulting PDF is stored via the Spezi `Standard`.
    /// The `Standard` must conform to the ``OnboardingConstraint``.
    ///
    /// - Parameter paperSize: The desired size for the exported PDF, defaulting to `.usLetter`.
    func export(paperSize: PaperSize = .usLetter) async {
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
            width: paperSize.dimensions.width,
            height: paperSize.dimensions.height
        )
        renderer.proposedSize = .init(paperSize)
        
        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: paperSize)
            
            /// Creates the `CGContext` that stores the to-be-rendered PDF in-memory as a Swift `Data` struct.
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
            
            /// Stores the finished PDF within the Spezi `Standard`.
            onboardingDataSource.store(mutableData as Data)
        }
    }
}
