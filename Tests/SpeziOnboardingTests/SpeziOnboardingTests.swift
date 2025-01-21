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
import XCTest


final class SpeziOnboardingTests: XCTestCase {
    func testSpeziOnboardingTests() throws {
        XCTAssert(true)
    }

    @MainActor
    func testAnyViewIssue() throws {
        let view = Text("Hello World")
            .onboardingIdentifier("Custom Identifier")

        XCTAssertFalse((view as Any) is AnyView)
    }

    @MainActor
    func testOnboardingIdentifierModifier() throws {
        let stack = OnboardingStack {
            Text("Hello World")
                .onboardingIdentifier("Custom Identifier")
        }

        let identifier = try XCTUnwrap(stack.onboardingNavigationPath.firstOnboardingStepIdentifier)

        var hasher = Hasher()
        hasher.combine("Custom Identifier")
        let final = hasher.finalize()
        XCTAssertEqual(identifier.identifierHash, final)
    }
    
    @MainActor
    func testPDFExport() async throws {
        let markdownDataFiles: [String] = ["markdown_data_one_page", "markdown_data_two_pages"]
        let knownGoodPDFFiles: [String] = ["known_good_pdf_one_page", "known_good_pdf_two_pages"]
        
        for (markdownPath, knownGoodPDFPath) in zip(markdownDataFiles, knownGoodPDFFiles) {
            let markdownData = {
                self.loadMarkdownDataFromFile(path: markdownPath)
            }
            
            let exportConfiguration = ConsentDocument.ExportConfiguration(
                paperSize: .dinA4,
                consentTitle: "Spezi Onboarding",
                includingTimestamp: false
            )
            
            let documentExport = ConsentDocumentExport(
                markdown: markdownData,
                exportConfiguration: exportConfiguration,
                documentIdentifier: ConsentDocumentExport.Defaults.documentIdentifier
            )
            documentExport.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
            
            #if os(macOS)
            let pdfPath = knownGoodPDFPath + "_mac_os"
            #elseif os(visionOS)
            let pdfPath = knownGoodPDFPath + "_vision_os"
            #else
            let pdfPath = knownGoodPDFPath + "_ios"
            #endif
            
            let knownGoodPdf = loadPDFFromPath(path: pdfPath)
            
            #if !os(macOS)
            documentExport.signature = .init()
            #else
            documentExport.signature = "Stanford"
            #endif
            
            if let pdf = try? await documentExport.export() {
                XCTAssert(comparePDFDocuments(pdf1: pdf, pdf2: knownGoodPdf))
            } else {
                XCTFail("Failed to export PDF from ConsentDocumentExport.")
            }
        }
    }
    
    private func loadMarkdownDataFromFile(path: String) -> Data {
        let bundle = Bundle.module  // Access the test bundle
        guard let fileURL = bundle.url(forResource: path, withExtension: "md") else {
            XCTFail("Failed to load \(path).md from resources.")
            return Data()
        }
        
        // Load the content of the file into Data
        var markdownData = Data()
        do {
            markdownData = try Data(contentsOf: fileURL)
        } catch {
            XCTFail("Failed to read \(path).md from resources: \(error.localizedDescription)")
        }
        return markdownData
    }
    
    private func loadPDFFromPath(path: String) -> PDFDocument {
        let bundle = Bundle.module  // Access the test bundle
        guard let url = bundle.url(forResource: path, withExtension: "pdf") else {
            XCTFail("Failed to locate \(path) in resources.")
            return .init()
        }
   
        guard let knownGoodPdf = PDFDocument(url: url) else {
            XCTFail("Failed to load \(path) from resources.")
            return .init()
        }
        return knownGoodPdf
    }
    
    private func comparePDFDocuments(pdf1: PDFDocument, pdf2: PDFDocument) -> Bool {
        // Check if both documents have the same number of pages
        guard pdf1.pageCount == pdf2.pageCount else {
            return false
        }

        // Iterate through each page and compare their contents
        for index in 0..<pdf1.pageCount {
            guard let page1 = pdf1.page(at: index),
                  let page2 = pdf2.page(at: index) else {
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

    func savePDF(fileName: String, pdfDocument: PDFDocument) -> Bool {
    // Get the document directory path
    let fileManager = FileManager.default
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Could not find the documents directory.")
        return false
    }
    
    // Create the full file path
    let filePath = documentsDirectory.appendingPathComponent("\(fileName).pdf")
    
    // Attempt to write the PDF document to the file path
    if pdfDocument.write(to: filePath) {
        print("PDF saved successfully at: \(filePath)")
        return true
    } else {
        print("Failed to save PDF.")
        return false
    }
}
}
