//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

final class OnboardingConsentTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testOnboardingConsentMarkdown() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        // Test that the consent view can render markdown
        XCTAssert(app.buttons["Consent View (Markdown)"].waitForExistence(timeout: 2))
        app.buttons["Consent View (Markdown)"].tap()

        try app.consentViewOnboardingFlow(consentTitle: "First Consent", markdownText: "This is the first markdown example")
        try app.consentViewOnboardingFlow(consentTitle: "Second Consent", markdownText: "This is the second markdown example")
    }

    @MainActor
    func testOnboardingConsentMarkdownRendering() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        // Test that the consent view is not exported
        XCTAssert(app.buttons["Rendered Consent View (Markdown)"].waitForExistence(timeout: 2))
        app.buttons["Rendered Consent View (Markdown)"].tap()

        XCTAssert(app.staticTexts["First Consent PDF rendering doesn't exist"].waitForExistence(timeout: 2))

        // Navigate back to start screen
        XCTAssert(app.navigationBars.buttons["Back"].exists)
        app.buttons["Back"].tap()

        // Go through markdown consent form and check rendering
        XCTAssert(app.buttons["Consent View (Markdown)"].waitForExistence(timeout: 2))
        app.buttons["Consent View (Markdown)"].tap()

        XCTAssert(app.staticTexts["First Consent"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["This is the first markdown example"].exists)

        XCTAssertFalse(app.staticTexts["Leland Stanford"].exists)
        XCTAssertFalse(app.staticTexts["X"].exists)

        app.hitConsentButton()

        #if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
            throw XCTSkip("PKCanvas view-related tests are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
        #endif

        XCTAssert(app.staticTexts["First Name"].exists)
        try app.textFields["Enter your first name…"].enter(value: "Leland")

        XCTAssert(app.staticTexts["Last Name"].exists)
        try app.textFields["Enter your last name…"].enter(value: "Stanford")

        app.hitConsentButton()

        XCTAssert(app.staticTexts["Name: Leland Stanford"].waitForExistence(timeout: 2))

        #if !os(macOS)
        XCTAssert(app.scrollViews["Signature Field"].exists)
        app.scrollViews["Signature Field"].swipeRight()
        #else
        XCTAssert(app.textFields["Signature Field"].exists)
        try app.textFields["Signature Field"].enter(value: "Leland Stanford")
        #endif

        app.hitConsentButton()

        XCTAssert(app.staticTexts["First Consent PDF rendering exists"].waitForExistence(timeout: 2))
    }
    
    
    @MainActor
    func testInteractiveConsentContent() async throws { // swiftlint:disable:this function_body_length
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        
        app.buttons["Complex Consent View"].tap()
        print(app.debugDescription)
        
        let shareButton = app.navigationBars.firstMatch.buttons["Share Consent Form"]
        XCTAssert(shareButton.waitForExistence(timeout: 1))
        XCTAssertFalse(shareButton.isEnabled)
        
        func flipToggle(beforeValue: Bool, afterValue: Bool, line: UInt = #line) async throws {
            let element = app.switches["ConsentForm:data-sharing"].firstMatch
            XCTAssert(element.exists, line: line)
            XCTAssertEqual(try XCTUnwrap(XCTUnwrap(element.value) as? String), beforeValue ? "1" : "0", line: line)
            try element.toggleSwitch()
            try await Task.sleep(for: .seconds(0.25))
            XCTAssertEqual(try XCTUnwrap(XCTUnwrap(element.value) as? String), afterValue ? "1" : "0", line: line)
        }
        
        XCTAssertFalse(shareButton.isEnabled)
        try await flipToggle(beforeValue: false, afterValue: true)
        XCTAssertFalse(shareButton.isEnabled)
        
        #if !os(visionOS)
        app.swipeUp()
        #endif
        try await Task.sleep(for: .seconds(1))
        
        func select(in elementId: String, option: String?, expectedCurrentSelection: String?, line: UInt = #line) async throws {
            let noSelectionTitle = "(No selection)"
            let button = app.buttons["ConsentForm:\(elementId)"]
            print(button.debugDescription)
            XCTAssert(button.exists)
            XCTAssert(button.staticTexts[expectedCurrentSelection ?? noSelectionTitle].waitForExistence(timeout: 1), line: line)
            button.tap()
            app.buttons[option ?? noSelectionTitle].tap()
            try await Task.sleep(for: .seconds(0.25))
            XCTAssert(button.staticTexts[expectedCurrentSelection ?? noSelectionTitle].waitForNonExistence(timeout: 1), line: line)
            XCTAssert(button.staticTexts[option ?? noSelectionTitle].waitForExistence(timeout: 1), line: line)
        }
        
        XCTAssertFalse(shareButton.isEnabled)
        try await select(in: "select1", option: "Mountains", expectedCurrentSelection: nil)
        XCTAssertFalse(shareButton.isEnabled)
        
        try await select(in: "select2", option: "No", expectedCurrentSelection: nil)
        
        do {
            for (nameComponent, name) in zip(["first", "last"], ["Leland", "Stanford"]) {
                let textField = app.textFields["Enter your \(nameComponent) name…"]
                XCTAssert(textField.waitForExistence(timeout: 2))
                try textField.enter(value: name)
            }
            XCTAssertFalse(shareButton.isEnabled)
            let signatureCanvas = app.scrollViews["ConsentForm:sig"]
            signatureCanvas.swipeRight()
        }
        try await Task.sleep(for: .seconds(1))
        
        XCTAssertTrue(shareButton.isEnabled)
        try await select(in: "select1", option: nil, expectedCurrentSelection: "Mountains")
        XCTAssertFalse(shareButton.isEnabled)
        try await select(in: "select1", option: "Beach", expectedCurrentSelection: nil)
        XCTAssertTrue(shareButton.isEnabled)
        try await select(in: "select1", option: "Mountains", expectedCurrentSelection: "Beach")
        XCTAssertTrue(shareButton.isEnabled)
        
        #if !os(visionOS)
        app.swipeDown()
        #endif
        try await Task.sleep(for: .seconds(1))
        
        XCTAssertTrue(shareButton.isEnabled)
        try await flipToggle(beforeValue: true, afterValue: false)
        XCTAssertFalse(shareButton.isEnabled)
        try await flipToggle(beforeValue: false, afterValue: true)
        XCTAssertTrue(shareButton.isEnabled)
        
        shareButton.tap()
        
        app.assertShareSheetTextElementExists("Knee Replacement Study Consent Form")
    }
}


extension XCUIApplication {
    fileprivate func assertShareSheetTextElementExists(_ text: String, file: StaticString = #filePath, line: UInt = #line) {
        let exists = self.staticTexts[text].waitForExistence(timeout: 2) || self.otherElements[text].waitForExistence(timeout: 2)
        XCTAssert(exists, file: file, line: line)
    }
}


extension XCUIElement {
    func toggleSwitch(file: StaticString = #filePath, line: UInt = #line) throws {
        #if os(visionOS)
        let value = switch try XCTUnwrap(value as? String, file: file, line: line) {
        case "0":
            false
        case "1":
            true
        case let rawValue:
            throw NSError(domain: "edu.stanford.SpezOnboarding.UITests", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Unexpected switch value: '\(rawValue)'"
            ])
        }
        if value {
            swipeLeft()
        } else {
            swipeRight()
        }
        #else
        if isHittable {
            tap()
        } else {
            coordinate(withNormalizedOffset: .init(dx: 0.5, dy: 0.5)).tap()
        }
        #endif
    }
}
