//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import SpeziOnboarding
import SwiftUI
import XCTest


final class SpeziOnboardingTests: XCTestCase {
    func testSpeziOnboardingTests() throws {
        XCTAssert(true)
    }

    @MainActor
    func testAnyViewIssue() throws {
        let view = Text("Hello World")
            .onboardingIdentifier("Custom Identifier")

        XCTAssertFalse((view as Any) is AnyView)
    }

    @MainActor
    func testOnboardingIdentifierModifier() throws {
        let stack = OnboardingStack {
            Text("Hello World")
                .onboardingIdentifier("Custom Identifier")
        }

        let identifier = try XCTUnwrap(stack.onboardingNavigationPath.firstOnboardingStepIdentifier)

        var hasher = Hasher()
        hasher.combine("Custom Identifier")
        let final = hasher.finalize()
        XCTAssertEqual(identifier.identifierHash, final)
    }
}
