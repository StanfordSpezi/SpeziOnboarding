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
    /// Creates the export representation of the ``ConsentDocument`` including all necessary content.
    var exportRepresentation: ConsentDocumentExportRepresentation {
        get async {
            #if !os(macOS)
            .init(
                markdown: await self.markdown(),
                signature: signatureImage,
                name: self.name,
                formattedSignatureDate: self.formattedConsentSignatureDate,
                documentIdentifier: self.documentIdentifier,
                configuration: self.exportConfiguration
            )
            #else
            .init(
                markdown: await self.markdown(),
                signature: self.signature,
                name: self.name,
                formattedSignatureDate: self.formattedConsentSignatureDate,
                documentIdentifier: self.documentIdentifier,
                configuration: self.exportConfiguration
            )
            #endif
        }
    }

    #if !os(macOS)
    private var signatureImage: UIImage {
        var updatedDrawing = PKDrawing()

        for stroke in signature.strokes {
            // As the `PKDrawing.image()` function automatically converts the ink color dependent on the used color scheme (light or dark mode),
            // force the ink used in the `UIImage` of the `PKDrawing` to always be black by adjusting the signature ink according to the color scheme.
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
}
