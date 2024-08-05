//
//  File.swift
//  
//
//  Created by Patrick Langer on 03.08.2024.
//

import Foundation

/// A type representing an unique identifier for a `ConsentDocument`. Allows to distinguish multiple documents during `ConsentConstraint.store`.
public struct ConsentDocumentIdentifier: Identifiable, Sendable, Equatable {
    private let identifier: String
    
    // String representation of the identifier.
    public var id: String {
        identifier
    }
    
    /// Creates a `ConsentDocumentIdentifier` from a String.
    /// - Parameters:
    ///   - identifier: A string which acts as unique identifier for a document and should be unique among different instances of `ConsentDocumentIdentifier`.
    public init(_ identifier: String) {
        self.identifier = identifier
    }
}
