//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

final class OnboardingTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }


    @MainActor
    func testOverallOnboardingFlow() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssert(app.buttons["Welcome View"].waitForExistence(timeout: 2))
        app.buttons["Welcome View"].tap()

        // Check if on welcome page
        XCTAssert(app.staticTexts["Welcome"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Spezi UI Tests"].exists)

        XCTAssert(app.buttons["Learn More"].exists)
        app.buttons["Learn More"].tap()

        // Check if on sequential onboarding view
        XCTAssert(app.staticTexts["Things to know"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["And you should pay close attention ..."].exists)

        XCTAssert(app.buttons["Next"].exists)
        app.buttons["Next"].tap()

        XCTAssert(app.buttons["Next"].exists)
        app.buttons["Next"].tap()

        XCTAssert(app.buttons["Next"].exists)
        app.buttons["Next"].tap()

        XCTAssert(app.buttons["Continue"].waitForExistence(timeout: 2.0))
        app.buttons["Continue"].tap()

        // Check first and second consent export
        try app.consentViewOnboardingFlow(consentTitle: "First Consent", markdownText: "This is the first markdown example")
        try app.consentViewOnboardingFlow(consentTitle: "Second Consent", markdownText: "This is the second markdown example")

        XCTAssert(app.staticTexts["Leland"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()

        XCTAssert(app.staticTexts["Stanford"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()
        
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()

        // Check if on final page
        XCTAssert(app.staticTexts["Onboarding complete"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testOnboardingWelcomeView() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssert(app.buttons["Welcome View"].waitForExistence(timeout: 2))
        app.buttons["Welcome View"].tap()

        XCTAssert(app.staticTexts["Welcome"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Spezi UI Tests"].exists)

        XCTAssert(app.staticTexts["Tortoise"].exists)
        XCTAssert(app.staticTexts["A Tortoise!"].exists)

        XCTAssert(app.staticTexts["Tree"].exists)
        XCTAssert(app.staticTexts["A Tree!"].exists)

        XCTAssert(app.staticTexts["Letter"].exists)
        XCTAssert(app.staticTexts["A letter!"].exists)

        XCTAssert(app.staticTexts["Circle"].exists)
        XCTAssert(app.staticTexts["A circle!"].exists)

        XCTAssert(app.buttons["Learn More"].exists)
        app.buttons["Learn More"].tap()

        XCTAssert(app.staticTexts["Things to know"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["And you should pay close attention ..."].exists)
    }

    @MainActor
    func testSequentialOnboarding() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssert(app.buttons["Sequential Onboarding"].waitForExistence(timeout: 2))
        app.buttons["Sequential Onboarding"].tap()

        XCTAssert(app.staticTexts["Things to know"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["And you should pay close attention ..."].exists)

        XCTAssert(app.staticTexts["1. A thing to know"].exists)
        XCTAssertFalse(app.staticTexts["2. A second thing to know"].exists)
        XCTAssertFalse(app.staticTexts["3. Third thing to know"].exists)

        XCTAssert(app.buttons["Next"].exists)
        app.buttons["Next"].tap()
        XCTAssert(app.staticTexts["2. Second thing to know"].waitForExistence(timeout: 2))

        XCTAssert(app.buttons["Next"].exists)
        app.buttons["Next"].tap()
        XCTAssert(app.staticTexts["3. Third thing to know"].waitForExistence(timeout: 2))

        XCTAssert(app.buttons["Next"].exists)
        app.buttons["Next"].tap()
        XCTAssert(app.staticTexts["Now you should know all the things!"].waitForExistence(timeout: 2))

        XCTAssert(app.staticTexts["1. A thing to know"].exists)
        XCTAssert(app.staticTexts["2. Second thing to know"].exists)
        XCTAssert(app.staticTexts["3. Third thing to know"].exists)
        XCTAssert(app.staticTexts["4."].exists)

        XCTAssert(app.buttons["Continue"].exists)
        app.buttons["Continue"].tap()

        XCTAssert(app.staticTexts["First Consent"].waitForExistence(timeout: 2))
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

    @MainActor
    func testOnboardingCustomViews() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssert(app.buttons["Custom Onboarding View 1"].waitForExistence(timeout: 2))
        app.buttons["Custom Onboarding View 1"].tap()

        // Check if on custom test view 1
        XCTAssert(app.staticTexts["Custom Test View 1: Hello Spezi!"].waitForExistence(timeout: 2))

        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()

        // Check if on custom test view 2
        XCTAssert(app.staticTexts["Custom Test View 2"].waitForExistence(timeout: 2))

        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()

        // Check if on welcome onboarding view
        XCTAssert(app.staticTexts["Welcome"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Spezi UI Tests"].exists)
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

    @MainActor
    func testIdentifiableViews() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        app.buttons["Onboarding Identifiable View"].tap()

        XCTAssert(app.staticTexts["ID: 1"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()

        XCTAssert(app.staticTexts["ID: 2"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()

        XCTAssert(app.staticTexts["Welcome"].waitForExistence(timeout: 2))
    }
}
