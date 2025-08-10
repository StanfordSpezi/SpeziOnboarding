//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest


extension XCUIApplication {
    func dynamicOnboardingFlow(showConditionalView: Bool) throws {
        if showConditionalView {
            XCTAssert(buttons["Show Conditional View"].waitForExistence(timeout: 2))
            buttons["Show Conditional View"].tap()
        }
        
        buttons["Welcome View"].tap()
        buttons["Learn More"].tap()
        buttons["Next"].tap()
        buttons["Next"].tap()
        buttons["Next"].tap()
        buttons["Continue"].tap()
        
        XCTAssert(staticTexts["Leland"].waitForExistence(timeout: 1))
        buttons["Next"].tap()
        XCTAssert(staticTexts["Stanford"].waitForExistence(timeout: 1))
        buttons["Next"].tap()
        
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
}
