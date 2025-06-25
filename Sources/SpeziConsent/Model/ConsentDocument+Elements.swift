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
        
        var isMarkdown: Bool {
            switch self {
            case .markdown:
                true
            case .toggle, .select, .signature:
                false
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
        typealias StorageKeyPath = WritableKeyPath<UserResponses, [String: Value]>
        
        static var userResponsesKeyPath: StorageKeyPath { get }
        
        var id: String { get }
        var initialValue: Value { get }
        
        func valueMatchesExpected(_ value: Value) -> Bool
    }
    
    
    struct ToggleConfig: InteractiveSectionProtocol {
        typealias Value = Bool
        static var userResponsesKeyPath: StorageKeyPath { \.toggles }
        
        let id: String
        let prompt: String
        let initialValue: Bool
        let expectedValue: Bool? // swiftlint:disable:this discouraged_optional_boolean
        
        func valueMatchesExpected(_ value: Bool) -> Bool {
            if let expectedValue {
                value == expectedValue
            } else {
                true
            }
        }
    }
    
    
    struct SelectConfig: InteractiveSectionProtocol {
        typealias Value = String
        
        enum ExpectedSelection: Hashable {
            /// The option identified by `id` is expected as the sole valid selection.
            ///
            /// Use this option if you want to treat one of the options as being the only "valid" one.
            case option(id: String)
            
            /// Anything is considered as a valid selection.
            ///
            /// Use this option with `allowEmptySelection` set to `false` if you just want the user to select one of the options, but don't care about the specific option they've chosen.
            ///
            /// Use this option with `allowEmptySelection` set to `true` to also treat the empty selection as a valid value, i.e., to allow the user to leave the selection empty.
            case anything(allowEmptySelection: Bool)
        }
        
        static var userResponsesKeyPath: StorageKeyPath { \.selects }
        
        static let emptySelection: String = ""
        
        let id: String
        let prompt: String
        let options: [SelectionOption]
        let initialValue: Value
        let expectedSelection: ExpectedSelection
        
        func valueMatchesExpected(_ value: String) -> Bool {
            switch expectedSelection {
            case .anything(allowEmptySelection: true):
                true
            case .anything(allowEmptySelection: false):
                value != Self.emptySelection
            case .option(let id):
                value == id && value != Self.emptySelection
            }
        }
    }
    
    struct SignatureConfig: InteractiveSectionProtocol {
        typealias Value = ConsentDocument.SignatureStorage
        
        static var userResponsesKeyPath: StorageKeyPath { \.signatures }
        
        let id: String
        var initialValue: Value { .init(name: initialName) }
        var initialName: PersonNameComponents?
        
        func valueMatchesExpected(_ value: ConsentDocument.SignatureStorage) -> Bool {
            value.didEnterNames && value.isSigned
        }
    }
}


extension ConsentDocument.InteractiveSectionProtocol {
    var userResponsesKeyPath: WritableKeyPath<ConsentDocument.UserResponses, Value?> {
        Self.userResponsesKeyPath.appending(path: \.[id])
    }
}

extension ConsentDocument.SelectConfig {
    static var emptySelectionDefaultTitle: String {
        String(localized: "CONSENT_NO_SELECTION_DEFAULT_TITLE", bundle: .module)
    }
}
