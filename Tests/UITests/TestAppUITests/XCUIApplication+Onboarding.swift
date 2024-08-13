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
        if staticTexts["This is a markdown example"].isHittable {
            staticTexts["This is a markdown example"].swipeUp()
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
        XCTAssert(staticTexts["Consent PDF rendering doesn't exist"].waitForExistence(timeout: 2))

        XCTAssert(buttons["Next"].exists)
        buttons["Next"].tap()

        XCTAssert(buttons["Next"].waitForExistence(timeout: 2))
        buttons["Next"].tap()

        XCTAssert(buttons["Next"].waitForExistence(timeout: 2))
        buttons["Next"].tap()

        XCTAssert(buttons["Next"].waitForExistence(timeout: 2))
        buttons["Next"].tap()

        if showConditionalView {
            // Check if on conditional test view
            XCTAssert(staticTexts["Conditional Test View"].waitForExistence(timeout: 2))

            XCTAssert(buttons["Next"].exists)
            buttons["Next"].tap()
        }

        // Check if on final page
        XCTAssert(staticTexts["Onboarding complete"].waitForExistence(timeout: 2))
    }
}
