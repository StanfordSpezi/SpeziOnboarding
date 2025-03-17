//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

final class OnboardingCustomViewTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
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
}
