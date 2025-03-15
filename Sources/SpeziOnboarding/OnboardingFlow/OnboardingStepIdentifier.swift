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
    let identifierHash: Int
    
    /// Whether the step is custom, i.e. created via e.g. ``OnboardingNavigationPath/append(customView:)``
    let isCustom: Bool
    
    let viewType: any View.Type
    let flowElementSourceLocation: _OnboardingFlowViewCollection.Element.SourceLocation?
    
    /// Initializes an identifier using a view. If the view conforms to `Identifiable`, its `id` is used; otherwise, the view's type is used.
    /// - Parameters:
    ///   - view: The view used to initialize the identifier.
    ///   - custom: A flag indicating whether the step is custom.
    @MainActor
    init(element: _OnboardingFlowViewCollection.Element, isCustom: Bool = false) {
        self.isCustom = isCustom
        self.viewType = type(of: element.view)
        self.flowElementSourceLocation = element.sourceLocation
        var hasher = Hasher()
        if let identifiable = element.view as? any OnboardingIdentifiable {
            let id = identifiable.id
            hasher.combine(id)
        } else if let identifiable = element.view as? any Identifiable {
            let id = identifiable.id
            hasher.combine(id)
        } else {
            hasher.combine(String(reflecting: type(of: element.view)))
            hasher.combine(element.sourceLocation)
        }
        self.identifierHash = hasher.finalize()
    }

    /// Initializes an identifier using a view type.
    /// - Parameters:
    ///   - onboardingStepType: The class of the view used to initialize the identifier.
    ///   - custom: A flag indicating whether the step is custom.
    init(onboardingStepType viewType: (some View).Type, isCustom: Bool = false) {
        self.isCustom = isCustom
        self.viewType = viewType
        self.flowElementSourceLocation = nil
        var hasher = Hasher()
        hasher.combine(String(reflecting: viewType))
        self.identifierHash = hasher.finalize()
    }
}


extension OnboardingStepIdentifier: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifierHash == rhs.identifierHash
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifierHash)
    }
}


extension OnboardingStepIdentifier: CustomDebugStringConvertible {
    var debugDescription: String {
        var desc = "\(Self.self)(hash: \(identifierHash), isCustom: \(isCustom), viewType: \(viewType)"
        if let sourceLoc = flowElementSourceLocation {
            desc += ", sourceLoc: \(sourceLoc.fileId);\(sourceLoc.line);\(sourceLoc.column)"
        }
        desc += ")"
        return desc
    }
}
