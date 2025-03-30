//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import SpeziViews

/// Managed, sequential presentation of consecutive ``OnboardingView``s
public typealias OnboardingStack = ManagedNavigationStack

/// Manages the navigation within an ``OnboardingStack``
@available(*, deprecated, renamed: "OnboardingStack.Path")
public typealias OnboardingNavigationPath = OnboardingStack.Path
