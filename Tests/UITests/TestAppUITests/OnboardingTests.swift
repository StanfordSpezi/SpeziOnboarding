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

        XCTAssert(app.staticTexts["Leland"].waitForExistence(timeout: 2))
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
    
    
    @MainActor
    func testScreenshotsFlow() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.buttons["Screenshots"].tap()
        
        XCTAssert(app.staticTexts["Spezi Template Application"].waitForExistence(timeout: 2))
        app.buttons["Learn More"].tap()
        
        XCTAssert(app.staticTexts["Interesting Modules"].waitForExistence(timeout: 2))
        for (idx, step) in [
            "The Onboarding module allows you to",
            "SpeziAccount enabled user log in and sign up",
            "Work with Health data collected by",
            "Via Spezi's Scheduler module, users can be prompted"
        ].enumerated() {
            let predicate = NSPredicate(format: "label BEGINSWITH %@", step)
            if idx > 0 {
                XCTAssert(app.staticTexts.matching(predicate).element.waitForNonExistence(timeout: 1))
                app.buttons["Next"].tap()
            }
            XCTAssert(app.staticTexts.matching(predicate).element.waitForExistence(timeout: 1))
        }
        XCTAssert(app.buttons["Next"].waitForNonExistence(timeout: 1))
        XCTAssert(app.buttons["Continue"].waitForExistence(timeout: 1))
        app.buttons["Continue"].tap()
        
        XCTAssert(app.staticTexts["Health Access"].waitForExistence(timeout: 1))
    }
}
