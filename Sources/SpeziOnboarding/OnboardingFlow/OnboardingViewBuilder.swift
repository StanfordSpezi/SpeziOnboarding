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
public enum OnboardingViewBuilder {
    /// If declared, provides contextual type information for statement expressions to translate them into partial results.
    public static func buildExpression(_ expression: any View) -> [any View] {
        [expression]
    }

    /// Required by every result builder to build combined results from statement blocks.
    public static func buildBlock(_ children: [any View]...) -> [any View] {
        children.flatMap { $0 }
    }

    /// Enables support for `if` statements that do not have an `else`.
    public static func buildOptional(_ component: [any View]?) -> [any View] {
        // swiftlint:disable:previous discouraged_optional_collection
        // The optional collection is a requirement defined by @resultBuilder, we can not use a non-optional collection here.
        component ?? []
    }

    /// With buildEither(second:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result.
    public static func buildEither(first: [any View]) -> [any View] {
        first
    }

    /// With buildEither(first:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result.
    public static func buildEither(second: [any View]) -> [any View] {
        second
    }
    
    /// Enables support for 'for..in' loops by combining the results of all iterations into a single result.
    public static func buildArray(_ components: [[any View]]) -> [any View] {
        components.flatMap { $0 }
    }
    
    /// If declared, this will be called on the partial result of an 'if #available' block to allow the result builder to erase type information.
    public static func buildLimitedAvailability(_ component: [any View]) -> [any View] {
        component
    }
    
    /// If declared, this will be called on the partial result from the outermost block statement to produce the final returned result.
    public static func buildFinalResult(_ component: [any View]) -> _OnboardingFlowViewCollection {
        _OnboardingFlowViewCollection(views: component)
    }
}
