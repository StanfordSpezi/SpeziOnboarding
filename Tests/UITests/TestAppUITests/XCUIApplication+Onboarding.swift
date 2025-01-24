//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    func hitConsentButton() {
        if staticTexts["This is the first markdown example"].isHittable {
            staticTexts["This is the first markdown example"].swipeUp()
        } else if staticTexts["This is the second markdown example"].isHittable {
            staticTexts["This is the second markdown example"].swipeUp()
        } else {
            print("Can not scroll down.")
        }
        XCTAssert(buttons["I Consent"].waitForExistence(timeout: 2))
        buttons["I Consent"].tap()
    }

    func dynamicOnboardingFlow(showConditionalView: Bool) throws {
        // Dynamically show onboarding views
        if showConditionalView {
            XCTAssert(buttons["Show Conditional View"].waitForExistence(timeout: 2))
            buttons["Show Conditional View"].tap()
        }
        XCTAssert(buttons["Rendered Consent View (Markdown)"].waitForExistence(timeout: 2))
        buttons["Rendered Consent View (Markdown)"].tap()

        // Check if on consent export page
        XCTAssert(staticTexts["First Consent PDF rendering doesn't exist"].waitForExistence(timeout: 2))

        XCTAssert(buttons["Next"].waitForExistence(timeout: 2))
        buttons["Next"].tap()

        try consentViewOnboardingFlow(consentTitle: "Second Consent", markdownText: "This is the second markdown example")

        XCTAssert(buttons["Next"].waitForExistence(timeout: 2))
        buttons["Next"].tap()

        XCTAssert(buttons["Next"].waitForExistence(timeout: 2))
        buttons["Next"].tap()

        XCTAssert(buttons["Next"].waitForExistence(timeout: 2))
        buttons["Next"].tap()

        if showConditionalView {
            // Check if on conditional test view
            XCTAssert(staticTexts["Conditional Test View"].waitForExistence(timeout: 2))

            XCTAssert(buttons["Next"].waitForExistence(timeout: 2))
            buttons["Next"].tap()
        }

        // Check if on final page
        XCTAssert(staticTexts["Onboarding complete"].waitForExistence(timeout: 2))
    }
    
    func consentViewOnboardingFlow(consentTitle: String, markdownText: String) throws {
        XCTAssert(staticTexts[consentTitle].waitForExistence(timeout: 2))
        XCTAssert(staticTexts[markdownText].waitForExistence(timeout: 2))

        #if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
            throw XCTSkip("PKCanvas view-related tests are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
        #endif

        XCTAssert(staticTexts["First Name"].waitForExistence(timeout: 2))
        try textFields["Enter your first name ..."].enter(value: "Leland")

        XCTAssert(staticTexts["Last Name"].waitForExistence(timeout: 2))
        try textFields["Enter your last name ..."].enter(value: "Stanford")
        
        hitConsentButton()

        XCTAssert(staticTexts["Name: Leland Stanford"].waitForExistence(timeout: 2))

        #if !os(macOS)
        staticTexts["Name: Leland Stanford"].swipeRight()

        XCTAssert(buttons["Undo"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(buttons["Undo"].isEnabled)
        buttons["Undo"].tap()

        XCTAssert(scrollViews["Signature Field"].waitForExistence(timeout: 2))
        scrollViews["Signature Field"].swipeRight()
        #else
        XCTAssert(textFields["Signature Field"].waitForExistence(timeout: 2))
        try textFields["Signature Field"].enter(value: "Leland Stanford")
        #endif

        hitConsentButton()

        // Check if the first consent export was successful
        XCTAssert(staticTexts["\(consentTitle) PDF rendering exists"].waitForExistence(timeout: 2))

        XCTAssert(buttons["Next"].waitForExistence(timeout: 2))
        buttons["Next"].tap()
    }
}
