//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit
@testable import SpeziOnboarding
import SwiftUI
import Testing


@Suite("SpeziOnboardingTests")
struct SpeziOnboardingTests {
    @Test("OnboardingIdentifier ViewModifier")
    @MainActor
    func testOnboardingIdentifierModifier() throws {
        let stack = OnboardingStack {
            Text("Hello World")
                .onboardingIdentifier("Custom Identifier")
        }

        let identifier = try #require(stack.onboardingNavigationPath.firstOnboardingStepIdentifier)

        var hasher = Hasher()
        hasher.combine("Custom Identifier")
        let final = hasher.finalize()
        #expect(identifier.identifierHash == final)
    }

    @Test("PDF Export", arguments:
            zip(
                ["markdown_data_one_page", "markdown_data_two_pages"],
                ["known_good_pdf_one_page", "known_good_pdf_two_pages"]
            )
    )
    func testPDFExport(markdownPath: String, knownGoodPDFPath: String) async throws {
        let exportConfiguration = ConsentDocumentExportRepresentation.Configuration(
            paperSize: .dinA4,
            consentTitle: "Spezi Onboarding",
            includingTimestamp: false
        )

        #if !os(macOS)
        let documentExport = ConsentDocumentExportRepresentation(
            markdown: try #require(self.loadMarkdownDataFromFile(path: markdownPath)),
            signature: .init(),
            name: PersonNameComponents(givenName: "Leland", familyName: "Stanford"),
            formattedSignatureDate: "01/23/25",
            documentIdentifier: ConsentDocumentExportRepresentation.Configuration.Defaults.documentIdentifier,
            configuration: exportConfiguration
        )
        #else
        let documentExport = ConsentDocumentExportRepresentation(
            markdown: try #require(self.loadMarkdownDataFromFile(path: markdownPath)),
            signature: "Stanford",
            name: PersonNameComponents(givenName: "Leland", familyName: "Stanford"),
            formattedSignatureDate: "01/23/25",
            documentIdentifier: ConsentDocumentExportRepresentation.Configuration.Defaults.documentIdentifier,
            configuration: exportConfiguration
        )
        #endif

        #if os(macOS)
        let pdfPath = knownGoodPDFPath + "_mac_os"
        #elseif os(visionOS)
        let pdfPath = knownGoodPDFPath + "_vision_os"
        #else
        let pdfPath = knownGoodPDFPath + "_ios"
        #endif

        let knownGoodPdf = try #require(loadPDFFromPath(path: pdfPath))
        let renderedPdf = try documentExport.render()

        #expect(renderedPdf.equatable == knownGoodPdf.equatable)
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

// Wrapper type to have a proper `Equatable` conformance of the `PDFDocument`
struct PDFEquatableDocument: Equatable {
    let pdf: PDFDocument


    init(_ pdf: PDFDocument) {
        self.pdf = pdf
    }


    static func == (lhs: PDFEquatableDocument, rhs: PDFEquatableDocument) -> Bool {
        // Check if both documents have the same number of pages
        guard lhs.pdf.pageCount == rhs.pdf.pageCount else {
            return false
        }

        // Iterate through each page and compare their contents
        for index in 0..<lhs.pdf.pageCount {
            guard let page1 = lhs.pdf.page(at: index),
                  let page2 = rhs.pdf.page(at: index) else {
                return false
            }

            // Compare the text content of the pages
            let text1 = page1.string ?? ""
            let text2 = page2.string ?? ""
            if text1 != text2 {
                return false
            }
        }

        // If all pages are identical, the documents are equal
        return true
    }
}

extension PDFDocument {
    var equatable: PDFEquatableDocument {
        .init(self)
    }
}
