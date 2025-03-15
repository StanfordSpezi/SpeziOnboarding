//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// Defines a collection of SwiftUI `View`s that are defined with an ``OnboardingStack``.
///
/// You can not create a ``_OnboardingFlowViewCollection`` yourself. Please use the ``OnboardingStack`` that internally creates a ``_OnboardingFlowViewCollection`` with the passed views.
public class _OnboardingFlowViewCollection {  // swiftlint:disable:this type_name
    public struct Element {
        public struct SourceLocation: Hashable, Sendable {
            let fileId: StaticString
            let line: UInt
            let column: UInt
        }
        
        let view: any View
        let sourceLocation: SourceLocation
    }
    
    let elements: [Element]
    
    init(elements: [Element]) {
        self.elements = elements
    }
}


extension StaticString: @retroactive Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs.hasPointerRepresentation, rhs.hasPointerRepresentation) {
        case (true, true):
            // the two strings are either truly identical (if they point to the same address),
            // or they point to different memory locations which then contain identical contents
            lhs.utf8Start == rhs.utf8Start || strcmp(lhs.utf8Start, rhs.utf8Start) == 0
        case (false, false):
            lhs.unicodeScalar == rhs.unicodeScalar
        case (true, false), (false, true):
            false
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        if self.hasPointerRepresentation {
            hasher.combine(self.utf8Start)
        } else {
            hasher.combine(self.unicodeScalar)
        }
    }
}
