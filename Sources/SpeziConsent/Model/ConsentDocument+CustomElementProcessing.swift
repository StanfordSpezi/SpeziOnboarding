//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFoundation

extension ConsentDocument.Section {
    enum ConstructSectionError: Error {
        case missingAttribute(String)
        case missingField(String)
        case unexpectedElement(String)
        case other(String)
    }
    
    static func toggle(_ element: MarkdownDocument.CustomElement) throws(ConstructSectionError) -> Self {
        guard let id = element[attribute: "id"], !id.isEmpty else {
            throw .missingAttribute("id")
        }
        guard case .text(let prompt) = element.content.first else {
            throw .missingField("prompt")
        }
        let defaultValue = element[attribute: "initial-value"].flatMap { Bool($0) } ?? false
        let expectedValue = element[attribute: "expected-value"].flatMap { Bool($0) }
        return .toggle(.init(id: id, prompt: prompt, initialValue: defaultValue, expectedValue: expectedValue))
    }
    
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    static func select(_ element: MarkdownDocument.CustomElement) throws(ConstructSectionError) -> Self {
        guard let id = element[attribute: "id"], !id.isEmpty else {
            throw .missingAttribute("id")
        }
        var prompt = ""
        var options: [ConsentDocument.SelectionOption] = []
        for thing in element.content {
            switch thing {
            case .text(let text):
                if prompt.isEmpty {
                    prompt = text
                } else {
                    prompt.append(" " + text)
                }
            case .element(let element):
                guard element.name == "option" else {
                    throw .unexpectedElement(element.name)
                }
                guard let optionId = element[attribute: "id"], !id.isEmpty else {
                    throw .missingAttribute("option.id")
                }
                guard case .text(let prompt) = element.content.first else {
                    throw .missingField("option.content")
                }
                options.append(.init(id: optionId, title: prompt))
            }
        }
        let initialValue = element[attribute: "initial-value"] ?? ConsentDocument.SelectConfig.emptySelection
        guard initialValue.isEmpty || options.contains(where: { $0.id == initialValue }) else {
            throw .other("initial value references nonexisting option id '\(initialValue)'")
        }
        let expectedSelection = try { () throws (ConstructSectionError) -> ConsentDocument.SelectConfig.ExpectedSelection in
            let rawValue = element[attribute: "expected-value"]
            switch rawValue {
            case nil:
                return .anything(allowEmptySelection: true)
            case .some(""):
                throw .missingAttribute("expected-value")
            case .some("*"):
                return .anything(allowEmptySelection: false)
            case .some(let id):
                guard options.contains(where: { $0.id == id }) else {
                    throw .other("expected value references notexisting option id '\(id)'")
                }
                return .option(id: id)
            }
        }()
        return .select(.init(
            id: id,
            prompt: prompt,
            options: options,
            initialValue: initialValue,
            expectedSelection: expectedSelection
        ))
    }
    
    static func signature(_ element: MarkdownDocument.CustomElement) throws(ConstructSectionError) -> Self {
        guard let id = element[attribute: "id"], !id.isEmpty else {
            throw .missingField("id")
        }
        return .signature(.init(id: id))
    }
}
