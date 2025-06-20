//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import struct SpeziFoundation.Version


extension ConsentDocument {
    /// A key-value mapping containing the metadata parsed from a consent form.
    public struct Metadata: Hashable, Sendable {
        public typealias Storage = [String: String]
        
        private let storage: Storage
        
        init() {
            storage = .init()
        }
        
        init(_ storage: Storage) {
            self.storage = storage
        }
        
        /// Fetches the metadata value associated with the specified key.
        public subscript(key: String) -> String? {
            storage[key]
        }
    }
}


extension ConsentDocument.Metadata {
    /// The document's title, if present in the metadata
    public var title: String? {
        self["title"]
    }
    
    /// The document's version, if present in the metadata
    public var version: Version? {
        self["version"].flatMap { Version($0) }
    }
}


extension ConsentDocument.Metadata: Collection {
    public var startIndex: Storage.Index {
        storage.startIndex
    }
    
    public var endIndex: Storage.Index {
        storage.endIndex
    }
    
    public func index(after idx: Storage.Index) -> Storage.Index {
        storage.index(after: idx)
    }
    
    public subscript(position: Storage.Index) -> Storage.Element  {
        storage[position]
    }
}


extension ConsentDocument.Metadata: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        self.init(Dictionary(uniqueKeysWithValues: elements))
    }
}


extension ConsentDocument.Metadata: Codable {
    public init(from decoder: any Decoder) throws {
        storage = try Storage(from: decoder)
//        let container = try decoder.singleValueContainer()
//        storage = try container.decode(Storage.self)
    }
    
    public func encode(to encoder: any Encoder) throws {
        try storage.encode(to: encoder)
    }
}
