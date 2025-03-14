//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(UIKit)
import class UIKit.UIFont
import class UIKit.UIColor
/// :nodoc:
public typealias UINSFont = UIFont
/// :nodoc:
public typealias UINSColor = UIFont
#elseif canImport(AppKit)
import class AppKit.NSFont
import class AppKit.NSColor
/// :nodoc:
public typealias UINSFont = NSFont
/// :nodoc:
public typealias UINSColor = NSColor
#endif
