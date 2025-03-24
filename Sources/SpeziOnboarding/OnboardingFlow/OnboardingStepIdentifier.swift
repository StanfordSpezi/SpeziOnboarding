//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// An `OnboardingStepIdentifier` serves as an abstraction of a step in the onboarding flow as outlined within the ``OnboardingStack``.
/// 
/// It contains both the identifier for an onboarding step (the view's type) as well as a flag that indicates if it's a custom onboarding step.
struct OnboardingStepIdentifier {
    /// The source of the `OnboardingStepIdentifier`'s identity
    enum IdentifierKind: Equatable {
        /// The `OnboardingStepIdentifier` derives its identity from a `View`'s type and source location
        case viewTypeAndSourceLoc
        /// The `OnboardingStepIdentifier` derives its identity from a `Hashable` value.
        case identifiable(any Hashable)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.viewTypeAndSourceLoc, .viewTypeAndSourceLoc):
                true
            case let (.identifiable(lhsValue), .identifiable(rhsValue)):
                lhsValue.isEqual(rhsValue)
            case (.viewTypeAndSourceLoc, .identifiable), (.identifiable, .viewTypeAndSourceLoc):
                false
            }
        }
    }
    
    let identifierKind: IdentifierKind
    let viewType: any View.Type
    let flowElementSourceLocation: _OnboardingFlowViewCollection.Element.SourceLocation?
    
    /// Whether the step is custom, i.e. not one of the steps defined via the ``OnboardingFlowBuilder`` but instead created via e.g. ``OnboardingNavigationPath/append(customView:)``.
    var isCustom: Bool {
        flowElementSourceLocation == nil
    }
    
    /// Initializes an identifier using a view. If the view conforms to `Identifiable`, its `id` is used; otherwise, the view's type is used.
    /// - Parameters:
    ///   - view: The view used to initialize the identifier.
    ///   - custom: A flag indicating whether the step is custom.
    @MainActor
    init(element: _OnboardingFlowViewCollection.Element) {
        self.viewType = type(of: element.view)
        self.flowElementSourceLocation = element.sourceLocation
        if let identifiable = element.view as? any OnboardingIdentifiable {
            let id = identifiable.id
            self.identifierKind = .identifiable(id)
        } else if let identifiable = element.view as? any Identifiable {
            let id = identifiable.id
            self.identifierKind = .identifiable(id)
        } else {
            self.identifierKind = .viewTypeAndSourceLoc
        }
    }

    /// Initializes an identifier using a view type.
    /// - Parameters:
    ///   - onboardingStepType: The class of the view used to initialize the identifier.
    ///   - custom: A flag indicating whether the step is custom.
    init(onboardingStepType viewType: (some View).Type) {
        self.viewType = viewType
        self.flowElementSourceLocation = nil
        self.identifierKind = .viewTypeAndSourceLoc
    }
}


extension OnboardingStepIdentifier: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs.identifierKind, rhs.identifierKind) {
        case (.viewTypeAndSourceLoc, .viewTypeAndSourceLoc):
            lhs.viewType == rhs.viewType && lhs.flowElementSourceLocation == rhs.flowElementSourceLocation
        case let (.identifiable(lhsValue), .identifiable(rhsValue)):
            lhsValue.isEqual(rhsValue)
        case (.viewTypeAndSourceLoc, .identifiable), (.identifiable, .viewTypeAndSourceLoc):
            false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self.identifierKind {
        case .viewTypeAndSourceLoc:
            hasher.combine(ObjectIdentifier(viewType))
            if let flowElementSourceLocation {
                hasher.combine(flowElementSourceLocation)
            }
        case .identifiable(let value):
            hasher.combine(ObjectIdentifier(type(of: value)))
            hasher.combine(value)
        }
    }
}


extension OnboardingStepIdentifier: CustomDebugStringConvertible {
    var debugDescription: String {
        var desc = "\(Self.self)(isCustom: \(isCustom), viewType: \(viewType), identifierKind: \(identifierKind)"
        if let sourceLoc = flowElementSourceLocation {
            desc += ", sourceLoc: \(sourceLoc.fileId);\(sourceLoc.line);\(sourceLoc.column)"
        }
        desc += ")"
        return desc
    }
}


extension Equatable {
    func isEqual(_ other: any Equatable) -> Bool {
        if let other = other as? Self {
            other == self
        } else {
            false
        }
    }
}
