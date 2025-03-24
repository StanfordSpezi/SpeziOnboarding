//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// A result builder used to aggregate multiple SwiftUI `View`s within the ``OnboardingStack``.
@resultBuilder
public enum OnboardingFlowBuilder {
    /// Onboarding Flow Element
    public typealias Element = _OnboardingFlowViewCollection.Element
    
    /// If declared, provides contextual type information for statement expressions to translate them into partial results.
    public static func buildExpression(_ view: some View, fileId: StaticString = #fileID, line: UInt = #line, column: UInt = #column) -> [Element] {
        [Element(view: view, sourceLocation: .init(fileId: fileId, line: line, column: column))]
    }

    /// Required by every result builder to build combined results from statement blocks.
    public static func buildBlock(_ children: [Element]...) -> [Element] {
        children.flatMap { $0 }
    }

    /// Enables support for `if` statements that do not have an `else`.
    public static func buildOptional(_ elements: [Element]?) -> [Element] {
        // swiftlint:disable:previous discouraged_optional_collection
        // The optional collection is a requirement defined by @resultBuilder, we can not use a non-optional collection here.
        elements ?? []
    }

    /// With buildEither(second:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result.
    public static func buildEither(first: [Element]) -> [Element] {
        first
    }

    /// With buildEither(first:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result.
    public static func buildEither(second: [Element]) -> [Element] {
        second
    }
    
    /// Enables support for 'for..in' loops by combining the results of all iterations into a single result.
    public static func buildArray(_ elements: [[Element]]) -> [Element] {
        elements.flatMap { $0 }
    }
    
    /// If declared, this will be called on the partial result of an 'if #available' block to allow the result builder to erase type information.
    public static func buildLimitedAvailability(_ elements: [Element]) -> [Element] {
        elements
    }
    
    /// If declared, this will be called on the partial result from the outermost block statement to produce the final returned result.
    public static func buildFinalResult(_ elements: [Element]) -> _OnboardingFlowViewCollection {
        _OnboardingFlowViewCollection(elements: elements)
    }
}
