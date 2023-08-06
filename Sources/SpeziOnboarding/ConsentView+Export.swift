//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI
import PencilKit

extension ConsentView {
    @MainActor
    struct ExportView: View {
        private var name: PersonNameComponents
        private var signature: PKDrawing
        private var markdown: AttributedString
        private var signatureSize: CGSize?
        
        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    
                    Text("Exported: \(Date.now.formatted(.iso8601))")
                        .font(.caption)
                }
                .padding()
                
                Text("Consent")
                    .font(.title)
                
                Text(markdown)
                    .padding()
                
                Spacer()
                
                ZStack(alignment: .bottomLeading) {
                    Color(.secondarySystemBackground)
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
                    Image(uiImage: signature.image(from: .init(x: 0, y: 0, width: signatureSize!.width, height: signatureSize!.height), scale: UIScreen.main.scale))
                        //.padding(.bottom, 45)
                        //.padding(.horizontal, 34)
                    // TODO: Is size of view relevant here? need to get it via init somehow, probably as a State in the ConsentView and then passed to this view
                    /*
                        .onPreferenceChange(CanvasView.CanvasSizePreferenceKey.self, perform: { value in
                            print(value)
                        })
                     */
                }
                .frame(width: signatureSize?.width, height: signatureSize?.height)
            }
        }
        
        init(name: PersonNameComponents, signature: PKDrawing, signatureSize: CGSize?, markdownData: Data) {
            self.name = name
            self.signature = signature
            self.signatureSize = signatureSize
            
            // Test data
            let markdownData = Data("""
            This is a *markdown* **example**
            This is a *markdown* **example**
            This is a *markdown* **example**
            This is a *markdown* **example**
            This is a *markdown* **example**
            This is a *markdown* **example**
            This is a *markdown* **example**
            This is a *markdown* **example**
            This is a *markdown* **example**
            This is a *markdown* **example**
            This is a *markdown* **example**
            This is a *markdown* **example**
            This is a *markdown* **example**
            """.utf8)
            
            self.markdown = try! AttributedString(
              markdown: markdownData,
              options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )
            
            1 + 1
        }
        
        func testRender() {
            // US Letter size
            let widthInInches: CGFloat = 8.5
            let heightInInches: CGFloat = 11.0
            let pointsPerInch: CGFloat = 72.0

            let widthInPoints = widthInInches * pointsPerInch
            let heightInPoints = heightInInches * pointsPerInch
            
            let renderer = ImageRenderer(content: body)
            renderer.proposedSize = .init(CGSize(width: widthInPoints, height: heightInPoints))
            
            // 2: Save it to our documents directory
            let url = URL.documentsDirectory.appending(path: "output.pdf")
            
            // 3: Start the rendering process
            renderer.render { size, context in
                // 4: Tell SwiftUI our PDF should be the same size as the views we're rendering
                //var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                //var box = CGRect(x: 0, y: 0, width: widthInPoints, height: widthInPoints)
                var box = CGRect(origin: .zero, size: CGSize(width: widthInPoints, height: heightInPoints))
                
                // 5: Create the CGContext for our PDF pages
                guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                    return
                }
                
                // 6: Start a new PDF page
                pdf.beginPDFPage(nil)
                pdf.translateBy(
                    x: 0, // mediaBox.size.width / 2 - size.width / 2,
                    y: 0 // mediaBox.size.height / 2 - size.height / 2
                )
                
                // 7: Render the SwiftUI view data onto the page
                context(pdf)
                
                // 8: End the page and close the file
                pdf.endPDFPage()
                pdf.closePDF()
            }
        }
    }
    
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
}
