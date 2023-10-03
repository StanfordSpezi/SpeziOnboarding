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
    func testOverallOnboardingFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.buttons["Welcome View"].waitForExistence(timeout: 2))
        app.buttons["Welcome View"].tap()
        
        // Check if on welcome page
        XCTAssert(app.staticTexts["Welcome"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Spezi UI Tests"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Learn More"].waitForExistence(timeout: 2))
        app.buttons["Learn More"].tap()
        
        // Check if on sequential onboarding view
        XCTAssert(app.staticTexts["Things to know"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["And you should pay close attention ..."].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()
        
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()
        
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()
        
        XCTAssert(app.buttons["Continue"].waitForExistence(timeout: 2))
        app.buttons["Continue"].tap()
        
        // Check if on consent (markdown) view
        XCTAssert(app.staticTexts["Consent"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Version 1.0"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["This is a markdown example"].waitForExistence(timeout: 2))
        
        #if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
            throw XCTSkip("PKCanvas view-related tests are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
        #endif
        
        XCTAssert(app.staticTexts["First Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your first name ..."].enter(value: "Leland")
        
        XCTAssert(app.staticTexts["Surname"].waitForExistence(timeout: 2))
        try app.textFields["Enter your surname ..."].enter(value: "Stanford")
        
        XCTAssert(app.staticTexts["Name: Leland Stanford"].waitForExistence(timeout: 2))
        app.staticTexts["Name: Leland Stanford"].firstMatch.swipeUp()
        
        XCTAssert(app.buttons["I Consent"].waitForExistence(timeout: 2))
        app.buttons["I Consent"].tap()
        
        // Check if the consent export was successful
        XCTAssert(app.staticTexts["Consent PDF rendering exists"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()
        
        // Check if on consent (HTML) view
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for HTML to load.")], timeout: 10.0)

        XCTAssert(app.staticTexts["Consent"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Version 1.0"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["This is an example of a study consent written in HTML."].waitForExistence(timeout: 2))
        
        XCTAssert(app.staticTexts["First Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your first name ..."].enter(value: "Leland")
        
        XCTAssert(app.staticTexts["Last Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your last name ..."].enter(value: "Stanford")
        
        XCTAssert(app.staticTexts["Name: Leland Stanford"].waitForExistence(timeout: 2))
        app.staticTexts["Name: Leland Stanford"].firstMatch.swipeUp()
        
        XCTAssert(app.buttons["I Consent"].waitForExistence(timeout: 2))
        app.buttons["I Consent"].tap()
        
        // Check if on final page
        XCTAssert(app.staticTexts["Onboarding complete"].waitForExistence(timeout: 2))
    }
    
    func testOnboardingWelcomeView() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.buttons["Welcome View"].waitForExistence(timeout: 2))
        app.buttons["Welcome View"].tap()
        
        XCTAssert(app.staticTexts["Welcome"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Spezi UI Tests"].waitForExistence(timeout: 2))

        XCTAssert(app.staticTexts["Tortoise"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["A Tortoise!"].waitForExistence(timeout: 2))

        XCTAssert(app.staticTexts["Lizard"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["A Lizard!"].waitForExistence(timeout: 2))

        XCTAssert(app.staticTexts["Tree"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["A Tree!"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Learn More"].waitForExistence(timeout: 2))
        app.buttons["Learn More"].tap()
        
        XCTAssert(app.staticTexts["Things to know"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["And you should pay close attention ..."].waitForExistence(timeout: 2))
    }
    
    func testSequentialOnboarding() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.buttons["Sequential Onboarding"].waitForExistence(timeout: 2))
        app.buttons["Sequential Onboarding"].tap()
        
        XCTAssert(app.staticTexts["Things to know"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["And you should pay close attention ..."].waitForExistence(timeout: 2))

        XCTAssert(app.staticTexts["1. A thing to know"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["2. A second thing to know"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["3. Third thing to know"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()
        XCTAssert(app.staticTexts["2. Second thing to know"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()
        XCTAssert(app.staticTexts["3. Third thing to know"].waitForExistence(timeout: 2))

        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()
        XCTAssert(app.staticTexts["Now you should know all the things!"].waitForExistence(timeout: 2))

        XCTAssert(app.staticTexts["1. A thing to know"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["2. Second thing to know"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["3. Third thing to know"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["4."].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Continue"].waitForExistence(timeout: 2))
        app.buttons["Continue"].tap()
        
        XCTAssert(app.staticTexts["Consent"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Version 1.0"].waitForExistence(timeout: 2))
    }
    
    func testOnboardingConsentMarkdown() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test that the consent view can render markdown
        XCTAssert(app.buttons["Consent View (Markdown)"].waitForExistence(timeout: 2))
        app.buttons["Consent View (Markdown)"].tap()
        
        XCTAssert(app.staticTexts["Consent"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Version 1.0"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["This is a markdown example"].waitForExistence(timeout: 2))
        
        XCTAssertFalse(app.staticTexts["Leland Stanford"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["X"].waitForExistence(timeout: 2))
        
        hitConsentButton(app)
        
        #if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
            throw XCTSkip("PKCanvas view-related tests are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
        #endif
        
        XCTAssert(app.staticTexts["First Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your first name ..."].enter(value: "Leland")
        
        XCTAssert(app.staticTexts["Surname"].waitForExistence(timeout: 2))
        try app.textFields["Enter your surname ..."].enter(value: "Stanford")
        
        hitConsentButton(app)
        
        XCTAssert(app.staticTexts["Name: Leland Stanford"].waitForExistence(timeout: 2))
        app.staticTexts["Name: Leland Stanford"].swipeRight()
        XCTAssert(app.buttons["Undo"].waitForExistence(timeout: 2))
        app.buttons["Undo"].tap()
        
        hitConsentButton(app)

        XCTAssert(app.scrollViews["Signature Field"].waitForExistence(timeout: 2))
        app.scrollViews["Signature Field"].swipeRight()
        
        hitConsentButton(app)
        
        XCTAssert(app.staticTexts["Consent PDF rendering exists"].waitForExistence(timeout: 2))
    }
    
    func testOnboardingConsentMarkdownRendering() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test that the consent view is not exported
        XCTAssert(app.buttons["Rendered Consent View (Markdown)"].waitForExistence(timeout: 2))
        app.buttons["Rendered Consent View (Markdown)"].tap()
        
        XCTAssert(app.staticTexts["Consent PDF rendering doesn't exist"].waitForExistence(timeout: 2))
        
        // Navigate back to start screen
        XCTAssert(app.buttons["Back"].waitForExistence(timeout: 2))
        app.buttons["Back"].tap()
        
        // Go through markdown consent form and check rendering
        XCTAssert(app.buttons["Consent View (Markdown)"].waitForExistence(timeout: 2))
        app.buttons["Consent View (Markdown)"].tap()
        
        XCTAssert(app.staticTexts["Consent"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Version 1.0"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["This is a markdown example"].waitForExistence(timeout: 2))
        
        XCTAssertFalse(app.staticTexts["Leland Stanford"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["X"].waitForExistence(timeout: 2))
        
        hitConsentButton(app)
        
        #if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
            throw XCTSkip("PKCanvas view-related tests are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
        #endif
        
        XCTAssert(app.staticTexts["First Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your first name ..."].enter(value: "Leland")
        
        XCTAssert(app.staticTexts["Surname"].waitForExistence(timeout: 2))
        try app.textFields["Enter your surname ..."].enter(value: "Stanford")
        
        hitConsentButton(app)
        
        XCTAssert(app.staticTexts["Name: Leland Stanford"].waitForExistence(timeout: 2))
        app.staticTexts["Name: Leland Stanford"].swipeRight()
        XCTAssert(app.buttons["Undo"].waitForExistence(timeout: 2))
        app.buttons["Undo"].tap()
        
        hitConsentButton(app)

        XCTAssert(app.scrollViews["Signature Field"].waitForExistence(timeout: 2))
        app.scrollViews["Signature Field"].swipeRight()
        
        hitConsentButton(app)
        
        XCTAssert(app.staticTexts["Consent PDF rendering exists"].waitForExistence(timeout: 2))
    }
    
    func testOnboardingConsentHTML() throws {
        let app = XCUIApplication()
        app.launch()

        // Test that the consent view can render HTML
        XCTAssert(app.buttons["Consent View (HTML)"].waitForExistence(timeout: 2))
        app.buttons["Consent View (HTML)"].tap()
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for HTML to load.")], timeout: 10.0)

        XCTAssert(app.staticTexts["Consent"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Version 1.0"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["This is an example of a study consent written in HTML."].waitForExistence(timeout: 2))
    }
    
    func testOnboardingCustomViews() throws {
        let app = XCUIApplication()
        app.launch()
        
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
        XCTAssert(app.staticTexts["Spezi UI Tests"].waitForExistence(timeout: 2))
    }
    
    func testDynamicOnboardingFlow1() throws {
        let app = XCUIApplication()
        app.launch()
        
        try dynamicOnboardingFlow(app: app, showConditionalView: false)
    }
    
    func testDynamicOnboardingFlow2() throws {
        let app = XCUIApplication()
        app.launch()
        
        try dynamicOnboardingFlow(app: app, showConditionalView: true)
    }
    
    private func hitConsentButton(_ app: XCUIApplication) {
        if app.staticTexts["This is a markdown example"].isHittable {
            app.staticTexts["This is a markdown example"].swipeUp()
        } else {
            print("Can not scroll down.")
        }
        XCTAssert(app.buttons["I Consent"].waitForExistence(timeout: 2))
        app.buttons["I Consent"].tap()
    }
    
    private func dynamicOnboardingFlow(app: XCUIApplication, showConditionalView: Bool) throws {
        // Dynamically show onboarding views
        if showConditionalView {
            XCTAssert(app.buttons["Show Conditional View"].waitForExistence(timeout: 2))
            app.buttons["Show Conditional View"].tap()
        }
        
        XCTAssert(app.buttons["Consent View (HTML)"].waitForExistence(timeout: 2))
        app.buttons["Consent View (HTML)"].tap()
        
        // Check if on consent (HTML) view
        XCTAssert(app.staticTexts["First Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your first name ..."].enter(value: "Leland")
        
        XCTAssert(app.staticTexts["Last Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your last name ..."].enter(value: "Stanford")
        
        XCTAssert(app.staticTexts["Name: Leland Stanford"].waitForExistence(timeout: 2))
        app.staticTexts["Name: Leland Stanford"].firstMatch.swipeUp()
        
        XCTAssert(app.buttons["I Consent"].waitForExistence(timeout: 2))
        app.buttons["I Consent"].tap()
        
        if showConditionalView {
            // Check if on conditional test view
            XCTAssert(app.staticTexts["Conditional Test View"].waitForExistence(timeout: 2))
            
            XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
            app.buttons["Next"].tap()
        }
        
        // Check if on final page
        XCTAssert(app.staticTexts["Onboarding complete"].waitForExistence(timeout: 2))
    }
}
