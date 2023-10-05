//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import SwiftUI
import UIKit

extension ConsentView {
    struct ShareSheet: UIViewControllerRepresentable {
        let sharedItem: PDFDocument

        func makeUIViewController(context: Context) -> UIActivityViewController {
            /// Note: Need to write down the PDF to storage as in-memory PDFs are not recognized properly
            let temporaryPath = FileManager.default.temporaryDirectory.appendingPathComponent("Signed Consent Form.pdf")
            try? sharedItem.dataRepresentation()?.write(to: temporaryPath)
            
            let controller = UIActivityViewController(
                activityItems: [temporaryPath],
                applicationActivities: nil
            )
            return controller
        }

        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
}
