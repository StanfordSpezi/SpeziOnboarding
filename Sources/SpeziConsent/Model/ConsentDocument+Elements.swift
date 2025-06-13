//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import struct PencilKit.PKDrawing


extension ConsentDocument {
    typealias Frontmatter = [String: String]
    
    
    enum Section: Hashable, Sendable {
        case markdown(String)
        case toggle(ToggleConfig)
        case select(SelectConfig)
        case signature(SignatureConfig)
        
        var id: String? {
            switch self {
            case .markdown:
                nil
            case .toggle(let config):
                config.id
            case .select(let config):
                config.id
            case .signature(let config):
                config.id
            }
        }
        
        var isSignature: Bool {
            switch self {
            case .signature:
                true
            case .markdown, .toggle, .select:
                false
            }
        }
    }
    
    
    struct SelectionOption: Hashable, Sendable {
        let id: String
        let title: String
    }
    
    protocol InteractiveSectionProtocol: Hashable {
        associatedtype Value
        var id: String { get }
        var initialValue: Value { get }
        var expectedValue: Value? { get }
    }
    
    struct ToggleConfig: InteractiveSectionProtocol {
        let id: String
        let prompt: String
        let initialValue: Bool
        let expectedValue: Bool? // swiftlint:disable:this discouraged_optional_boolean
    }
    
    
    struct SelectConfig: InteractiveSectionProtocol {
        let id: String
        let prompt: String
        let options: [SelectionOption]
        let initialValue: SelectionOption
        let expectedValue: SelectionOption?
    }
    
    struct SignatureConfig: InteractiveSectionProtocol {
        typealias Value = ConsentDocument.SignatureStorage
        let id: String
        var initialValue: Value { .init() }
        var expectedValue: Value? { nil }
    }
}
