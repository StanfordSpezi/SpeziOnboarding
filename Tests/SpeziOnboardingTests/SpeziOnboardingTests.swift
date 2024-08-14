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
        let markdownData = {
            Data("This is a *markdown* **example**".utf8)
        }
        
        let exportConfiguration = ConsentDocument.ExportConfiguration(
            paperSize: .dinA4,
            consentTitle: "Spezi Onboarding",
            includingTimestamp: false
        )

        let viewModel = ConsentDocumentModel(markdown: markdownData, exportConfiguration: exportConfiguration)
        
        let bundle = Bundle.module  // Access the test bundle
        var resourceName = "known_good_pdf"
        #if os(macOS)
        resourceName = "known_good_pdf_mac_os"
        #elseif os(visionOS)
        resourceName = "known_good_pdf_vision_os"
        #endif
      
        guard let url = bundle.url(forResource: resourceName, withExtension: "pdf") else {
           XCTFail("Failed to locate \(resourceName) in resources.")
           return
        }
   
        guard let knownGoodPdf = PDFDocument(url: url) else {
            XCTFail("Failed to load \(resourceName) from resources.")
            return
        }
        
        #if !os(macOS)
        if let pdf = await viewModel.export(personName: "Leland Stanford", signatureImage: .init()) {
            XCTAssert(comparePDFDocuments(pdf1: pdf, pdf2: knownGoodPdf))
        } else {
            XCTFail("Failed to export PDF from ConsentDocumentModel.")
        }
        #else
        if let pdf = await viewModel.export(personName: "Leland Stanford", signature: "Stanford") {
            XCTAssert(comparePDFDocuments(pdf1: pdf, pdf2: knownGoodPdf))
        } else {
            XCTFail("Failed to export PDF from ConsentDocumentModel.")
        }
        #endif
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
}
