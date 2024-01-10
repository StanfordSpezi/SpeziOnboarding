//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// This extension enhances SwiftUI's `NavigationPath` by introducing a property that gives access to the last element in the `NavigationPath`.
/// 
/// SwiftUI does not provide this functionality out-of-the-box. However, it can be engineered using the `Codable` nature of the `NavigationPath`.
/// This is particularly useful for the ``OnboardingNavigationPath`` to identify the topmost element on SwiftUI's `NavigationPath` which is of type `OnboardingStepIdentifier`.
extension NavigationPath {
    /// A helper type that acts as a decoder for extracting the last element in the `NavigationPath`.
    /// This struct makes use of the `Codable` nature of the `NavigationPath` to perform the decoding operation.
    private struct _LastOnboardingStepDecoder: Decodable {
        var value: OnboardingStepIdentifier
        
        
        /// Decodes the given `Decoder` instance into an `OnboardingStepIdentifier`.
        /// This involves decoding an unkeyed container, skipping the initial string, and then decoding the actual `OnboardingStepIdentifier`.
        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            
            // Type name within the navigation path that is not needed
            _ = try container.decode(String.self)
            
            let encodedValue = try container.decode(String.self)
            self.value = try NavigationPath.decoder.decode(OnboardingStepIdentifier.self, from: Data(encodedValue.utf8))
        }
    }
    
    
    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()
    
    
    /// Computed property that provides access to the last element within the `NavigationPath` as an `OnboardingStepIdentifier`.
    /// If the `NavigationPath` is empty or the elements within aren't `Codable`, it returns `nil`.
    var last: OnboardingStepIdentifier? {
        guard !isEmpty,
              let codable else {
            return nil
        }
        
        return try? Self.decoder.decode(
            _LastOnboardingStepDecoder.self,
            from: Self.encoder.encode(codable)
        ).value
    }
    
    
    /// Function that provides access to the last element on top of the `NavigationPath` that satisfies a certain predicate
    ///
    /// - Parameters:
    ///   - predicate: The predicate determining if the element of the `NavigationPath` is considered
    /// - Returns: The topmost element of the `NavigationPath` (of type `OnboardingStepIdentifier`) that satisfies the passed predicate. `nil` otherwise.
    func last(where predicate: (OnboardingStepIdentifier) -> Bool) -> OnboardingStepIdentifier? {
        /// Required to copy the `NavigationPath` instance as only access to the last element on top of the path is given
        var copyPath = self
        
        while !copyPath.isEmpty {
            guard let lastElement = copyPath.last else {
                return nil
            }
            
            if predicate(lastElement) {
                return lastElement
            }
            
            copyPath.removeLast()
        }
        
        return nil
    }
}
