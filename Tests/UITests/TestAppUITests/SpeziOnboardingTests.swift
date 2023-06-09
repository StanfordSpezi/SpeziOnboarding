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
    func testOnboardingConsent() throws {
        let app = XCUIApplication()
        app.launch()

        // First test that the consent can render HTML
        app.collectionViews.buttons["Consent View (HTML)"].tap()
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for HTML to load.")], timeout: 10.0)

        XCTAssert(app.staticTexts["Consent"].exists)
        XCTAssert(app.staticTexts["Version 1.0"].exists)
        XCTAssert(app.webViews.staticTexts["This is an example of a study consent written in HTML."].exists)
        
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // Now test that the consent view can render markdown
        app.collectionViews.buttons["Consent View (Markdown)"].tap()
        
        XCTAssert(app.staticTexts["Consent"].exists)
        XCTAssert(app.staticTexts["Version 1.0"].exists)
        XCTAssert(app.staticTexts["This is a markdown example"].exists)
        
        XCTAssertFalse(app.staticTexts["Leland Stanford"].exists)
        XCTAssertFalse(app.staticTexts["X"].exists)
        
        hitConsentButton(app)
        
        #if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
            throw XCTSkip("PKCanvas view-related tests are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
        #endif
        
        try app.textFields["Enter your first name ..."].enter(value: "Leland")
        try app.textFields["Enter your surname ..."].enter(value: "Stanford")
        
        hitConsentButton(app)
        
        app.staticTexts["Leland Stanford"].swipeRight()
        app.buttons["Undo"].tap()
        
        hitConsentButton(app)
        
        app.staticTexts["X"].swipeRight()
        
        hitConsentButton(app)
        
        XCTAssert(app.staticTexts["Welcome"].exists)
        XCTAssert(app.staticTexts["Spezi UI Tests"].exists)
    }
    
    private func hitConsentButton(_ app: XCUIApplication) {
        if app.staticTexts["This is a markdown example"].isHittable {
            app.staticTexts["This is a markdown example"].swipeUp()
        } else {
            print("Can not scroll down.")
        }
        app.buttons["I Consent"].tap()
    }
    
    func testOnboardingView() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.collectionViews.buttons["Onboarding View"].tap()
        
        XCTAssert(app.staticTexts["Welcome"].exists)
        XCTAssert(app.staticTexts["Spezi UI Tests"].exists)
        
        XCTAssert(app.images["Decrease Speed"].exists)
        XCTAssert(app.staticTexts["Tortoise"].exists)
        XCTAssert(app.staticTexts["A Tortoise!"].exists)
        
        XCTAssert(app.images["lizard.fill"].exists)
        XCTAssert(app.staticTexts["Lizard"].exists)
        XCTAssert(app.staticTexts["A Lizard!"].exists)
        
        XCTAssert(app.images["tree.fill"].exists)
        XCTAssert(app.staticTexts["Tree"].exists)
        XCTAssert(app.staticTexts["A Tree!"].exists)
        
        app.buttons["Learn More"].tap()
        
        XCTAssert(app.staticTexts["Things to know"].exists)
        XCTAssert(app.staticTexts["And you should pay close attention ..."].exists)
    }
    
    func testSequentialOnboarding() throws {
        let app = XCUIApplication()
        app.launch()
        
        app.collectionViews.buttons["Sequential Onboarding"].tap()
        
        XCTAssert(app.staticTexts["Things to know"].exists)
        XCTAssert(app.staticTexts["And you should pay close attention ..."].exists)
        
        XCTAssert(app.staticTexts["1"].exists)
        XCTAssert(app.staticTexts["A thing to know"].exists)
        XCTAssertFalse(app.staticTexts["2"].exists)
        XCTAssertFalse(app.staticTexts["A second thing to know"].exists)
        XCTAssertFalse(app.staticTexts["3"].exists)
        XCTAssertFalse(app.staticTexts["Third thing to know"].exists)
        
        app.buttons["Next"].tap()
        XCTAssert(app.staticTexts["2"].exists)
        XCTAssert(app.staticTexts["Second thing to know"].exists)
        
        app.buttons["Next"].tap()
        XCTAssert(app.staticTexts["3"].exists)
        XCTAssert(app.staticTexts["Third thing to know"].exists)

        app.buttons["Next"].tap()
        XCTAssert(app.staticTexts["Now you should know all the things!"].exists)
        
        XCTAssert(app.staticTexts["1"].exists)
        XCTAssert(app.staticTexts["A thing to know"].exists)
        XCTAssert(app.staticTexts["2"].exists)
        XCTAssert(app.staticTexts["Second thing to know"].exists)
        XCTAssert(app.staticTexts["3"].exists)
        XCTAssert(app.staticTexts["Third thing to know"].exists)
        app.buttons["Continue"].tap()
        
        XCTAssert(app.staticTexts["Consent"].exists)
        XCTAssert(app.staticTexts["Version 1.0"].exists)
    }
}
