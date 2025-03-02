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
public typealias UINSFont = UIFont
public typealias UINSColor = UIFont
#elseif canImport(AppKit)
import class AppKit.NSFont
import class AppKit.NSColor
public typealias UINSFont = NSFont
public typealias UINSColor = NSColor
#endif
