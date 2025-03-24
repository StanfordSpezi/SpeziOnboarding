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
                configuration: self.exportConfiguration
            )
            #else
            .init(
                markdown: await self.markdown(),
                signature: self.signature,
                name: self.name,
                formattedSignatureDate: self.formattedConsentSignatureDate,
                configuration: self.exportConfiguration
            )
            #endif
        }
    }

    #if !os(macOS)
    private var signatureImage: UIImage {
        let scale: CGFloat
        #if os(iOS)
        scale = UIScreen.main.scale
        #else
        scale = 3 // retina scale is default
        #endif

        // As the `PKDrawing.image()` function automatically converts the ink color dependent on the used color scheme (light or dark mode),
        // force the tint color used in the `UIImage` to `black`.
        return signature.image(
            from: .init(x: 0, y: 0, width: signatureSize.width, height: signatureSize.height),
            scale: scale
        ).withRenderingMode(.alwaysTemplate).withTintColor(.black)
    }
    #endif
}
