//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

final class OnboardingDynamicFlowTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }
    
    @MainActor
    func testDynamicOnboardingFlow1() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        try app.dynamicOnboardingFlow(showConditionalView: false)
    }

    @MainActor
    func testDynamicOnboardingFlow2() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        try app.dynamicOnboardingFlow(showConditionalView: true)
    }

    @MainActor
    func testDynamicOnboardingFlow3() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssert(app.buttons["Consent View (Markdown)"].waitForExistence(timeout: 2))
        app.buttons["Consent View (Markdown)"].tap()

        try app.consentViewOnboardingFlow(consentTitle: "First Consent", markdownText: "This is the first markdown example")
        try app.consentViewOnboardingFlow(consentTitle: "Second Consent", markdownText: "This is the second markdown example")

        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()

        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()

        XCTAssert(app.buttons["Show Conditional View"].waitForExistence(timeout: 2))
        app.buttons["Show Conditional View"].tap()

        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()

        // Check if on conditional test view
        XCTAssert(app.staticTexts["Conditional Test View"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()

        // Check if on final page
        XCTAssert(app.staticTexts["Onboarding complete"].waitForExistence(timeout: 2))
    }
}
