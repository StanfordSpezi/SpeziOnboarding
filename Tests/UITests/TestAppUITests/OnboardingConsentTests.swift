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
        try app.textFields["Enter your first name ..."].enter(value: "Leland")

        XCTAssert(app.staticTexts["Last Name"].exists)
        try app.textFields["Enter your last name ..."].enter(value: "Stanford")

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
}
