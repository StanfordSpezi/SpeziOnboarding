//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import SpeziOnboarding
import PDFKit
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
            includingTimestamp: true
        )
        let viewModel = ConsentDocumentViewModel(markdown: markdownData, exportConfiguration: exportConfiguration)
        
        
        let bundle = Bundle.module  // Access the test bundle
        
        #if !os(macOS)
        guard let url = bundle.url(forResource: "known_good_pdf", withExtension: "pdf") else {
           XCTFail("Failed to locate known_good.pdf in resources.")
           return
        }
        #else
        guard let url = bundle.url(forResource: "known_good_pdf_macos", withExtension: "pdf") else {
           XCTFail("Failed to locate known_good.pdf in resources.")
           return
        }
        #endif

        guard let knownGoodPdf = PDFDocument(url: url) else {
            XCTFail("Failed to load known good PDF from resources.")
            return
        }
        
        #if !os(macOS)
        if let pdf = await viewModel.export(personName: "Leland Stanford", signatureImage: .init()) {
            XCTAssert(comparePDFDocuments(doc1: pdf, doc2: knownGoodPdf))
        } else {
            XCTFail("Failed to export PDF from ConsentDocumentViewModel.")
        }
        #else
        if let pdf = await viewModel.export(personName: "Leland Stanford") {
            XCTAssert(comparePDFDocuments(doc1: pdf, doc2: knownGoodPdf))
        } else {
            XCTFail("Failed to export PDF from ConsentDocumentViewModel.")
        }
        #endif
    }
    
    private func comparePDFDocuments(doc1: PDFDocument, doc2: PDFDocument) -> Bool {
  
        guard let data1 = doc1.dataRepresentation(),
              let data2 = doc2.dataRepresentation() else {
            return false
        }
        
        return data1 == data2
    }
}
