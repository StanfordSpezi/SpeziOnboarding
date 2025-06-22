//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit
@testable import SpeziConsent
@testable import SpeziFoundation
import SwiftUI
import Testing


@Suite
struct SpeziConsentTests {
    @Test("PDF Export", arguments:
            zip(
                ["markdown_data_one_page", "markdown_data_two_pages"],
                ["known_good_pdf_one_page", "known_good_pdf_two_pages"]
            )
    )
    @MainActor
    func testPDFExport(markdownPath: String, knownGoodPDFPath: String) async throws {
        let exportConfiguration = ConsentDocument.ExportConfiguration(
            paperSize: .dinA4,
            includingTimestamp: false
        )
        
        let document = try ConsentDocument(
            contentsOf: try #require(Bundle.module.url(forResource: markdownPath, withExtension: "md"))
        )
        document.signatureDate = "01/23/25"
        let sig1 = ConsentDocument.SignatureConfig(id: "sig1")
        
        document.binding(for: sig1).wrappedValue.name = .init(
            givenName: "Leland",
            familyName: "Stanford"
        )
        #if os(macOS)
        document.binding(for: sig1).wrappedValue.signature = "Stanford"
        #endif

        #if os(macOS)
        let pdfPath = knownGoodPDFPath + "_mac_os"
        #elseif os(visionOS)
        let pdfPath = knownGoodPDFPath + "_vision_os"
        #else
        let pdfPath = knownGoodPDFPath + "_ios"
        #endif

        let knownGoodPdf = try #require(loadPDFFromPath(path: pdfPath))
        let exportResult = try document.export(using: exportConfiguration)
        #expect(exportResult.pdf.equatable == knownGoodPdf.equatable)
        #expect(exportResult.userResponses.toggles.isEmpty)
        #expect(exportResult.userResponses.selects.isEmpty)
        #expect(exportResult.userResponses.signatures.count == 1)
        let signature = try #require(exportResult.userResponses.signatures["sig1"])
        #expect(signature.name == .init(givenName: "Leland", familyName: "Stanford"))
        #if os(macOS)
        #expect(signature.signature == "Stanford")
        #else
        #expect(signature.signature.strokes.isEmpty)
        #endif
    }
    
    
    private func loadMarkdownDataFromFile(path: String) -> Data? {
        let bundle = Bundle.module  // Access the test bundle
        guard let fileURL = bundle.url(forResource: path, withExtension: "md") else {
            Issue.record("Failed to load \(path).md from resources.")
            return nil
        }
        // Load the content of the file into Data
        var markdownData = Data()
        do {
            markdownData = try Data(contentsOf: fileURL)
        } catch {
            Issue.record("Failed to read \(path).md from resources: \(error.localizedDescription)")
            return nil
        }
        return markdownData
    }

    private func loadPDFFromPath(path: String) -> PDFDocument? {
        let bundle = Bundle.module  // Access the test bundle
        guard let url = bundle.url(forResource: path, withExtension: "pdf") else {
            Issue.record("Failed to locate \(path) in resources.")
            return nil
        }
        guard let knownGoodPdf = PDFDocument(url: url) else {
            Issue.record("Failed to load \(path) from resources.")
            return nil
        }
        return knownGoodPdf
    }
}
