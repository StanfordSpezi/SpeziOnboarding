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

        app.buttons["Welcome View"].tap()
        app.buttons["Learn More"].tap()
        app.buttons["Next"].tap()
        app.buttons["Next"].tap()
        app.buttons["Next"].tap()
        app.buttons["Continue"].tap()
        
        XCTAssert(app.staticTexts["Leland"].waitForExistence(timeout: 1))
        app.buttons["Next"].tap()
        XCTAssert(app.staticTexts["Stanford"].waitForExistence(timeout: 1))
        app.buttons["Next"].tap()
        
//        app.buttons["Next"].tap()
        app.buttons["Show Conditional View"].tap()
        app.buttons["Next"].tap()
        XCTAssert(app.staticTexts["Conditional Test View"].waitForExistence(timeout: 1))
        app.buttons["Back"].tap()
        app.buttons["Show Conditional View"].tap()
        app.buttons["Next"].tap()
        
        XCTAssert(app.staticTexts["Onboarding complete"].waitForExistence(timeout: 2))
    }
}
