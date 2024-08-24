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

    #if !os(macOS)  // Only test export on non macOS platforms
    @MainActor
    func testOnboardingConsentPDFExport() throws {  // swiftlint:disable:this function_body_length
        let app = XCUIApplication()
        let filesApp = XCUIApplication(bundleIdentifier: "com.apple.DocumentsApp")

        app.launch()

        XCTAssert(app.buttons["Consent View (Markdown)"].waitForExistence(timeout: 2))
        app.buttons["Consent View (Markdown)"].tap()

        XCTAssert(app.staticTexts["First Consent"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["This is the first markdown example"].waitForExistence(timeout: 2))

        XCTAssert(app.staticTexts["First Name"].exists)
        try app.textFields["Enter your first name ..."].enter(value: "Leland")

        XCTAssert(app.staticTexts["Last Name"].exists)
        try app.textFields["Enter your last name ..."].enter(value: "Stanford")

        XCTAssert(app.staticTexts["Name: Leland Stanford"].waitForExistence(timeout: 2))

        XCTAssert(app.scrollViews["Signature Field"].exists)
        app.scrollViews["Signature Field"].swipeRight()

        // Export consent form via share sheet button
        XCTAssert(app.buttons["Share consent form"].waitForExistence(timeout: 4))
        app.buttons["Share consent form"].tap()

        // Store exported consent form in Files
#if os(visionOS)
        // on visionOS the save to files button has no label
        if #available(visionOS 2.0, *) {
            XCTAssert(app.cells["Save to Files"].waitForExistence(timeout: 10))
            app.cells["Save to Files"].tap()
        } else {
            XCTAssert(app.cells["XCElementSnapshotPrivilegedValuePlaceholder"].waitForExistence(timeout: 10))
            app.cells["XCElementSnapshotPrivilegedValuePlaceholder"].tap()
        }
#else
        XCTAssert(app.staticTexts["Save to Files"].waitForExistence(timeout: 10))
        app.staticTexts["Save to Files"].tap()
#endif

        XCTAssert(app.navigationBars.buttons["Save"].waitForExistence(timeout: 5))
        if !app.navigationBars.buttons["Save"].isEnabled {
            throw XCTSkip("You currently cannot save anything in the files app in Xcode 16-based simulator.")
        }
        app.navigationBars.buttons["Save"].tap()

        if app.staticTexts["Replace Existing Items?"].waitForExistence(timeout: 2.0) {
            XCTAssert(app.buttons["Replace"].exists)
            app.buttons["Replace"].tap()
        }

        // Wait until share sheet closed and back on the consent form screen
        XCTAssertTrue(app.staticTexts["Name: Leland Stanford"].waitForExistence(timeout: 10))

        XCUIDevice.shared.press(.home)

        // Launch the Files app
        filesApp.launch()
        XCTAssertTrue(filesApp.wait(for: .runningForeground, timeout: 2.0))

        // Handle already open files on iOS
        if filesApp.navigationBars.buttons["Done"].waitForExistence(timeout: 2) {
            filesApp.navigationBars.buttons["Done"].tap()
        }

        // If the file already shows up in the Recents view, we are good.
        // Otherwise navigate to "On My iPhone"/"On My iPad"/"On My Apple Vision Pro" view
        if !filesApp.staticTexts["Signed Consent Form"].waitForExistence(timeout: 2) {
#if os(visionOS)
            XCTAssertTrue(filesApp.staticTexts["On My Apple Vision Pro"].waitForExistence(timeout: 2.0))
            filesApp.staticTexts["On My Apple Vision Pro"].tap()
            XCTAssertTrue(filesApp.navigationBars.staticTexts["On My Apple Vision Pro"].waitForExistence(timeout: 2.0))
#else
            if filesApp.navigationBars.buttons["Show Sidebar"].exists && !filesApp.buttons["Browse"].exists {
                // we are running on iPad which is not iOS 18!
                filesApp.navigationBars.buttons["Show Sidebar"].tap()
                XCTAssertTrue(filesApp.staticTexts["On My iPad"].waitForExistence(timeout: 2.0))
                filesApp.staticTexts["On My iPad"].tap()
                XCTAssertTrue(filesApp.navigationBars.staticTexts["On My iPad"].waitForExistence(timeout: 2.0))
            }

            if filesApp.tabBars.buttons["Browse"].exists { // iPhone
                filesApp.tabBars.buttons["Browse"].tap()
                XCTAssertTrue(filesApp.navigationBars.staticTexts["On My iPhone"].waitForExistence(timeout: 2.0))
            } else { // iPad
                if !filesApp.navigationBars.staticTexts["On My iPad"].exists { // we aren't already in browse
                    XCTAssertTrue(filesApp.buttons["Browse"].exists)
                    filesApp.buttons["Browse"].tap()
                    XCTAssertTrue(filesApp.navigationBars.staticTexts["On My iPad"].waitForExistence(timeout: 2.0))
                }
            }
#endif

            XCTAssert(filesApp.staticTexts["Signed Consent Form"].waitForExistence(timeout: 2.0))
        }
        XCTAssert(filesApp.collectionViews["File View"].cells["Signed Consent Form, pdf"].exists)

        XCTAssert(filesApp.collectionViews["File View"].cells["Signed Consent Form, pdf"].images.firstMatch.exists)
        filesApp.collectionViews["File View"].cells["Signed Consent Form, pdf"].images.firstMatch.tap()

        #if os(visionOS)
        let fileView = XCUIApplication(bundleIdentifier: "com.apple.MRQuickLook")
        XCTAssertTrue(fileView.wait(for: .runningForeground, timeout: 5.0))
        #else
        let fileView = filesApp

        // Wait until file is opened
        XCTAssertTrue(fileView.navigationBars["Signed Consent Form"].waitForExistence(timeout: 5.0))
        #endif

        // Check if PDF contains consent title, name, and markdown message
        for searchString in ["Spezi Consent", "This is the first markdown example", "Leland Stanford"] {
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

    @MainActor
    func testOnboardingCustomViews() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))

        XCTAssert(app.buttons["Custom Onboarding View 1"].waitForExistence(timeout: 2))
        app.buttons["Custom Onboarding View 1"].tap()

        // Check if on custom test view 1
        XCTAssert(app.staticTexts["Custom Test View 1: Hello Spezi!"].waitForExistence(timeout: 2))

        XCTAssert(app.buttons["Next"].exists)
        app.buttons["Next"].tap()

        // Check if on custom test view 2
        XCTAssert(app.staticTexts["Custom Test View 2"].waitForExistence(timeout: 2))

        XCTAssert(app.buttons["Next"].exists)
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

        XCTAssert(app.buttons["Next"].exists)
        app.buttons["Next"].tap()

        // Check if on conditional test view
        XCTAssert(app.staticTexts["Conditional Test View"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Next"].exists)
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
        app.buttons["Next"].tap()

        XCTAssert(app.staticTexts["ID: 2"].waitForExistence(timeout: 2))
        app.buttons["Next"].tap()

        XCTAssert(app.staticTexts["Welcome"].waitForExistence(timeout: 2))
    }
}
