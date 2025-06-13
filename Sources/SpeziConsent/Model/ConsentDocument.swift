//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PencilKit
import SwiftUI
import class PDFKit.PDFDocument


@Observable
@MainActor
public final class ConsentDocument: Sendable {
    public enum LoadError: Error {
        case inputNotUTF8
        case failedToParse(ConsentParseError)
        case duplicateCustomElementId(String)
    }
    
    struct InteractiveSectionsState {
        private struct SelectionState<Section: InteractiveSectionProtocol> {
            let section: Section
            var value: Section.Value
            
            init(_ section: Section) {
                self.section = section
                self.value = section.initialValue
            }
        }
        
        private var storage: [String: Any] = [:]
        
        fileprivate mutating func register(section: some InteractiveSectionProtocol) throws(LoadError) {
            guard storage[section.id] == nil else {
                throw .duplicateCustomElementId(section.id)
            }
            storage[section.id] = SelectionState(section)
        }
        
        subscript<S: InteractiveSectionProtocol>(section: S) -> S.Value {
            get {
                guard let state = storage[section.id] as? SelectionState<S> else {
                    preconditionFailure("Attempting to read value for unregistered section!")
                }
                return state.value
            }
            set {
                guard var state = storage[section.id] as? SelectionState<S> else {
                    preconditionFailure("Attempting to set value for unregistered section!")
                }
                state.value = newValue
                storage[section.id] = state
            }
        }
    }
    
    /// Storage container for the data entered into a ``ConsentSignatureForm``, as part of filling out a ``ConsentDocument``.
    public struct SignatureStorage: Equatable {
        #if !os(macOS)
        public typealias Signature = PKDrawing
        #else
        public typealias Signature = String
        #endif
        
        public var name: PersonNameComponents
        public var signature: Signature
        var size: CGSize = .zero
        
        var isSigned: Bool {
            #if !os(macOS)
            !signature.strokes.isEmpty
            #else
            !signature.isEmpty
            #endif
        }
        
        var didEnterNames: Bool {
            (name.givenName ?? "") != "" && (name.familyName ?? "") != "" // swiftlint:disable:this empty_string
        }
        
        public init(name: PersonNameComponents = .init()) {
            self.name = name
            self.signature = .init()
        }
        
        /// Resets the signature to an empty state.
        mutating func clearSignature() {
            #if !os(macOS)
            signature.strokes.removeAll(keepingCapacity: true)
            #else
            signature.removeAll(keepingCapacity: true)
            #endif
        }
    }
    
    nonisolated let frontmatter: [String: String]
    nonisolated let sections: [Section]
    
    private var interactiveSectionsState = InteractiveSectionsState()
//    private var signatureStates: [String: SignatureStorage] = [:]
    
    /// Whether the `ConsentDocument` was created with support for custom elements enabled.
    public let customElementsEnabled: Bool
    
    var signatureDate: String?
    /// Indicates whether a signature is currently being signed somewhere in the consent document.
    var isSigning = false
    private(set) var isExporting = false
    
    public init(markdown: String, initialName: PersonNameComponents? = nil, enableCustomElements: Bool = true) throws(LoadError) {
        customElementsEnabled = enableCustomElements
        if enableCustomElements {
            do {
                let parseResult = try ConsentFileParser.parse(markdown)
                self.frontmatter = parseResult.frontmatter
                self.sections = parseResult.sections
            } catch {
                throw .failedToParse(error)
            }
        } else {
            frontmatter = [:]
            sections = [
                .markdown(markdown),
                .signature(.init(id: "default-signature"))
            ]
        }
        try processConsentFileSections(defaultName: initialName)
    }
    
    public convenience init(markdown: Data, initialName: PersonNameComponents? = nil, enableCustomElements: Bool = true) throws(LoadError) {
        guard let text = String(data: markdown, encoding: .utf8) else {
            throw .inputNotUTF8
        }
        try self.init(markdown: text, initialName: initialName, enableCustomElements: enableCustomElements)
    }
    
    public convenience init(contentsOf url: URL, initialName: PersonNameComponents? = nil, enableCustomElements: Bool = false) throws {
        let data = try Data(contentsOf: url)
        guard let text = String(data: data, encoding: .utf8) else {
            throw LoadError.inputNotUTF8
        }
        try self.init(markdown: text, initialName: initialName, enableCustomElements: enableCustomElements)
    }
    
    private func processConsentFileSections(defaultName: PersonNameComponents?) throws(LoadError) {
        for section in sections {
            switch section {
            case .markdown:
                break
            case .toggle(let config):
                try interactiveSectionsState.register(section: config)
            case .select(let config):
                try interactiveSectionsState.register(section: config)
            case .signature(let config):
                try interactiveSectionsState.register(section: config)
//                signatureStates[id] = .init(name: defaultName ?? .init(), signature: .init())
            }
        }
    }
}


extension ConsentDocument {
    func binding<S: InteractiveSectionProtocol>(for section: S) -> Binding<S.Value> {
        Binding<S.Value> {
            self.interactiveSectionsState[section]
        } set: { newValue in
            self.interactiveSectionsState[section] = newValue
        }
    }
    
    func value<S: InteractiveSectionProtocol>(for section: S) -> S.Value {
        interactiveSectionsState[section]
    }
}


extension ConsentDocument {
    enum ConsentCompletionState: Hashable, Sendable {
        case incomplete(firstIncompleteId: String)
        case complete
    }
    
    var completionState: ConsentCompletionState {
        for section in sections {
            switch section {
            case .markdown:
                continue
            case .toggle(let config):
                if let expectedValue = config.expectedValue, value(for: config) != expectedValue {
                    return .incomplete(firstIncompleteId: config.id)
                }
            case .select(let config):
                if let expectedValue = config.expectedValue, value(for: config) != expectedValue {
                    return .incomplete(firstIncompleteId: config.id)
                }
            case .signature(let config):
                let storage = value(for: config)
                guard storage.didEnterNames && storage.isSigned else {
                    return .incomplete(firstIncompleteId: config.id)
                }
            }
        }
        return .complete
    }
}


extension ConsentDocument {
    func export(config: ConsentDocument.ExportConfiguration) throws -> sending PDFKit.PDFDocument {
        isExporting = true
        defer {
            isExporting = false
        }
        let renderer = PDFRenderer(consentDocument: self, config: config)
        return try renderer.render()
    }
}
