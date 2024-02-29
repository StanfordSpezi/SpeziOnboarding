//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class OnboardingTests: XCTestCase { // swiftlint:disable:this type_body_length
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
        XCTAssert(app.staticTexts["This is a markdown example"].waitForExistence(timeout: 2))
        
        #if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
            throw XCTSkip("PKCanvas view-related tests are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
        #endif
        
        XCTAssert(app.staticTexts["First Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your first name ..."].enter(value: "Leland")
        
        XCTAssert(app.staticTexts["Last Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your last name ..."].enter(value: "Stanford")
        
        XCTAssert(app.staticTexts["Name: Leland Stanford"].waitForExistence(timeout: 2))
        
        #if !os(macOS)
        XCTAssert(app.scrollViews["Signature Field"].waitForExistence(timeout: 2))
        app.scrollViews["Signature Field"].swipeRight()
        #else
        XCTAssert(app.textFields["Signature Field"].waitForExistence(timeout: 2))
        try app.textFields["Signature Field"].enter(value: "Leland Stanford")
        #endif
        
        hitConsentButton(app)
        
        // Check if the consent export was successful
        XCTAssert(app.staticTexts["Consent PDF rendering exists"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()
        
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

        XCTAssert(app.staticTexts["Tree"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["A Tree!"].waitForExistence(timeout: 2))

        XCTAssert(app.staticTexts["Letter"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["A letter!"].waitForExistence(timeout: 2))

        XCTAssert(app.staticTexts["Circle"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["A circle!"].waitForExistence(timeout: 2))

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
    }
    
    func testOnboardingConsentMarkdown() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Test that the consent view can render markdown
        XCTAssert(app.buttons["Consent View (Markdown)"].waitForExistence(timeout: 2))
        app.buttons["Consent View (Markdown)"].tap()
        
        XCTAssert(app.staticTexts["Consent"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["This is a markdown example"].waitForExistence(timeout: 2))
        
        XCTAssertFalse(app.staticTexts["Leland Stanford"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["X"].waitForExistence(timeout: 2))
        
        hitConsentButton(app)
        
        #if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
            throw XCTSkip("PKCanvas view-related tests are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
        #endif
        
        XCTAssert(app.staticTexts["First Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your first name ..."].enter(value: "Leland")
        
        XCTAssert(app.staticTexts["Last Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your last name ..."].enter(value: "Stanford")
        
        hitConsentButton(app)
        
        XCTAssert(app.staticTexts["Name: Leland Stanford"].waitForExistence(timeout: 2))
        
        #if !os(macOS)
        app.staticTexts["Name: Leland Stanford"].swipeRight()
        
        XCTAssert(app.buttons["Undo"].waitForExistence(timeout: 2))
        app.buttons["Undo"].tap()
        
        XCTAssert(app.scrollViews["Signature Field"].waitForExistence(timeout: 2))
        app.scrollViews["Signature Field"].swipeRight()
        #else
        XCTAssert(app.textFields["Signature Field"].waitForExistence(timeout: 2))
        try app.textFields["Signature Field"].enter(value: "Leland Stanford")
        #endif
        
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
        XCTAssert(app.staticTexts["This is a markdown example"].waitForExistence(timeout: 2))
        
        XCTAssertFalse(app.staticTexts["Leland Stanford"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.staticTexts["X"].waitForExistence(timeout: 2))
        
        hitConsentButton(app)
        
        #if targetEnvironment(simulator) && (arch(i386) || arch(x86_64))
            throw XCTSkip("PKCanvas view-related tests are currently skipped on Intel-based iOS simulators due to a metal bug on the simulator.")
        #endif
        
        XCTAssert(app.staticTexts["First Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your first name ..."].enter(value: "Leland")
        
        XCTAssert(app.staticTexts["Last Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your last name ..."].enter(value: "Stanford")
        
        hitConsentButton(app)
        
        XCTAssert(app.staticTexts["Name: Leland Stanford"].waitForExistence(timeout: 2))
        
        #if !os(macOS)
        XCTAssert(app.scrollViews["Signature Field"].waitForExistence(timeout: 2))
        app.scrollViews["Signature Field"].swipeRight()
        #else
        XCTAssert(app.textFields["Signature Field"].waitForExistence(timeout: 2))
        try app.textFields["Signature Field"].enter(value: "Leland Stanford")
        #endif
        
        hitConsentButton(app)
        
        XCTAssert(app.staticTexts["Consent PDF rendering exists"].waitForExistence(timeout: 2))
    }
    
    #if !os(macOS)  // Only test export on non macOS platforms
    func testOnboardingConsentPDFExport() throws {  // swiftlint:disable:this function_body_length
        let app = XCUIApplication()
        let filesApp = XCUIApplication(bundleIdentifier: "com.apple.DocumentsApp")
        let maxRetries = 10
        
        app.launch()
        
        XCTAssert(app.buttons["Consent View (Markdown)"].waitForExistence(timeout: 2))
        app.buttons["Consent View (Markdown)"].tap()
        
        XCTAssert(app.staticTexts["Consent"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["This is a markdown example"].waitForExistence(timeout: 2))
        
        XCTAssert(app.staticTexts["First Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your first name ..."].enter(value: "Leland")
        
        XCTAssert(app.staticTexts["Last Name"].waitForExistence(timeout: 2))
        try app.textFields["Enter your last name ..."].enter(value: "Stanford")
        
        XCTAssert(app.staticTexts["Name: Leland Stanford"].waitForExistence(timeout: 2))
        
        XCTAssert(app.scrollViews["Signature Field"].waitForExistence(timeout: 2))
        app.scrollViews["Signature Field"].swipeRight()
        
        sleep(1)
                
        for _ in 0...maxRetries {
            // Export consent form via share sheet button
            XCTAssert(app.buttons["Share consent form"].waitForExistence(timeout: 2))
            app.buttons["Share consent form"].tap()

            // Store exported consent form in Files
            #if os(visionOS)
            // on visionOS the save to files button has no label
            XCTAssert(app.cells["XCElementSnapshotPrivilegedValuePlaceholder"].waitForExistence(timeout: 10))
            app.cells["XCElementSnapshotPrivilegedValuePlaceholder"].tap()
            #else
            XCTAssert(app.staticTexts["Save to Files"].waitForExistence(timeout: 10))
            app.staticTexts["Save to Files"].tap()
            #endif
            sleep(3)
            XCTAssert(app.buttons["Save"].waitForExistence(timeout: 2))
            app.buttons["Save"].tap()
            sleep(10)    // Wait until file is saved
            
            if app.staticTexts["Replace Existing Items?"].waitForExistence(timeout: 5) {
                XCTAssert(app.buttons["Replace"].waitForExistence(timeout: 2))
                app.buttons["Replace"].tap()
                sleep(3)    // Wait until file is saved
            }
            
            // Wait until share sheet closed and back on the consent form screen
            XCTAssert(app.staticTexts["Consent"].waitForExistence(timeout: 10))
            
            XCUIDevice.shared.press(.home)
            
            // Launch the Files app
            filesApp.launch()
            
            // Handle already open files
            if filesApp.buttons["Done"].waitForExistence(timeout: 2) {
                filesApp.buttons["Done"].tap()
            }
            
            // Check if file exists - If not, try the export procedure again
            // Saving to files is very flakey on the runners, needs multiple attempts to succeed
            if filesApp.staticTexts["Signed Consent Form"].waitForExistence(timeout: 2) {
                break
            }
            
            // Launch test app and try another export
            app.launch()
        }
        
        // Open File
        XCTAssert(filesApp.staticTexts["Signed Consent Form"].waitForExistence(timeout: 2))
        XCTAssert(filesApp.collectionViews["File View"].cells["Signed Consent Form, pdf"].waitForExistence(timeout: 2))
        
        XCTAssert(filesApp.collectionViews["File View"].cells["Signed Consent Form, pdf"].images.firstMatch.waitForExistence(timeout: 2))
        filesApp.collectionViews["File View"].cells["Signed Consent Form, pdf"].images.firstMatch.tap()
        
        sleep(3)    // Wait until file is opened
        

        #if os(visionOS)
        let fileView = XCUIApplication(bundleIdentifier: "com.apple.MRQuickLook")
        #else
        let fileView = filesApp
        #endif

        // Check if PDF contains consent title, name, and markdown message
        for searchString in ["Spezi Consent", "This is a markdown example", "Leland Stanford"] {
            let predicate = NSPredicate(format: "label CONTAINS[c] %@", searchString)
            XCTAssert(fileView.otherElements.containing(predicate).firstMatch.waitForExistence(timeout: 2))
        }

        #if os(iOS)
        // Close File
        XCTAssert(fileView.buttons["Done"].waitForExistence(timeout: 2))
        fileView.buttons["Done"].tap()
        #endif
    }
    #endif
    
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
        
        XCTAssert(app.buttons["Rendered Consent View (Markdown)"].waitForExistence(timeout: 2))
        app.buttons["Rendered Consent View (Markdown)"].tap()
        
        // Check if on consent export page
        XCTAssert(app.staticTexts["Consent PDF rendering doesn't exist"].waitForExistence(timeout: 2))
        
        XCTAssert(app.buttons["Next"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()
        
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
