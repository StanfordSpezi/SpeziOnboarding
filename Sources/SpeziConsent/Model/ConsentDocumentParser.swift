//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_length

import Foundation


public struct ConsentParseError: Error, Hashable {
    /// The parse error's kind
    public enum Kind: Hashable, Sendable {
        /// The parse input wasn't encoded as valid UTF-8 text.
        case nonUTF8Input
        /// The parser reached the end of the input file, even though it may have been expecting further content.
        @_documentation(visibility: internal)
        case eof
        /// The parser ran into an unexpected character
        case unexpectedCharacter
        /// Some other issue.
        case other(String)
    }
    
    /// A location within a markdown document, expressed as a line and column number.
    public struct SourceLocation: Hashable, Comparable, Sendable {
        fileprivate static let zero = Self(line: 0, column: 0)
        
        /// The location's line number, starting at 0.
        public let line: UInt
        /// The location's column number, i.e., its offset within its line, starting at 0.
        public let column: UInt
        
        fileprivate init(line: UInt, column: UInt) {
            self.line = line
            self.column = column
        }
        
        public static func < (lhs: Self, rhs: Self) -> Bool {
            if lhs.line < rhs.line {
                true
            } else if lhs.line == rhs.line {
                lhs.column < rhs.column
            } else {
                false
            }
        }
    }
    
    /// The specific kind of error
    public let kind: Kind
    /// The source location at which the error occurred
    public let sourceLoc: SourceLocation
}


struct ConsentDocumentParser: ~Copyable {
    fileprivate struct ParsedCustomElement {
        indirect enum Content {
            case text(String)
            case element(ParsedCustomElement)
        }
        
        var name: String
        var attributes: [(String, String)] = []
        var content: [Content] = []
        
        subscript(attribute key: String) -> String? {
            attributes.first { $0.0 == key }?.1
        }
    }
    
    private let input: String
    private var position: String.Index
    
    fileprivate init(input: String) {
        self.input = input
        self.position = input.startIndex
    }
    
    
    fileprivate mutating func parse() throws(ConsentParseError) -> ParseResult {
        typealias Section = ConsentDocument.Section
        let frontmatter = try parseFrontmatter()
        var sections: [Section] = []
        var currentSectionText = ""
        do {
            while let currentChar {
                if currentChar == "<", isAtBeginningOfLine,
                   let element = try parseCustomElement() {
                    sections.append(.markdown(currentSectionText))
                    currentSectionText.removeAll(keepingCapacity: true)
                    let elementsMapping: [String: (ParsedCustomElement) throws(Section.ConstructSectionError) -> Section] = [
                        "toggle": Section.toggle,
                        "select": Section.select,
                        "signature": Section.signature
                    ]
                    if let ctor = elementsMapping[element.name] {
                        do {
                            let section = try ctor(element)
                            sections.append(section)
                        } catch {
                            try emitError(.other("Unable to construct \(element.name.localizedCapitalized) element from \(element): \(error)"))
                        }
                    } else {
                        try emitError(.other("Unexpected top-level custom element: \(element)"))
                    }
                } else {
                    currentSectionText.append(currentChar)
                    consume()
                }
            }
        } catch {
            switch error.kind {
            case .eof:
                break
            default:
                throw error
            }
        }
        sections.append(.markdown(currentSectionText))
        sections.removeAll { section in
            switch section {
            case .markdown(let text):
                text.trimmingWhitespace().isEmpty
            case .toggle, .select, .signature:
                false
            }
        }
        return .init(frontmatter: frontmatter, sections: sections)
    }
    
    
    private mutating func parseFrontmatter() throws(ConsentParseError) -> [String: String] {
        guard currentLine == "---" else {
            return [:]
        }
        var frontmatter: [String: String] = [:]
        consumeLine()
        while let key = try? parseIdentifier() {
            try expectAndConsume(":")
            try expectAndConsume(" ")
            let value = currentLine ?? ""
            consumeLine()
            frontmatter[key] = String(value)
        }
        guard currentLine == "---" else {
            try emitError(.other("Unable to find end of frontmatter"))
        }
        consumeLine()
        return frontmatter
    }
    
    
    private mutating func parseIdentifier() throws(ConsentParseError) -> String {
        var identifier = ""
        if let currentChar, currentChar.isValidIdentStart {
            identifier.append(currentChar)
            consume()
        } else {
            try emitError(.unexpectedCharacter)
        }
        while let currentChar, currentChar.isValidIdent {
            identifier.append(currentChar)
            consume()
        }
        return identifier
    }
    
    private mutating func parseInteger() -> Int? {
        let initialPos = position
        var value = 0
        let negative: Bool
        if let currentChar, currentChar == "-" {
            negative = true
            consume()
        } else {
            negative = false
        }
        let posFirstPotentialDigit = position
        while let currentChar, currentChar.isASCII, let digit = currentChar.wholeNumberValue {
            value *= 10
            value += digit
            consume()
        }
        if position == posFirstPotentialDigit {
            // if we weren't able to read any digits, we restore the initial position and return nil
            position = initialPos
            return nil
        } else {
            // otherwise, we were able to parse a value, and will return that.
            return value * (negative ? -1 : 1)
        }
    }
    
    
    private mutating func parseAttrValue() throws(ConsentParseError) -> String {
        if currentChar == "\"" {
            try parseStringLiteral()
        } else if let ident = try? parseIdentifier() {
            ident
        } else if let value = parseInteger() {
            String(value)
        } else {
            ""
        }
    }
    
    
    private mutating func parseStringLiteral() throws(ConsentParseError) -> String {
        try expectAndConsume("\"")
        var text = ""
        while true {
            guard let currentChar else {
                try emitError(.eof)
            }
            let isEscaped = !text.suffix { $0 == #"\"# }.count.isMultiple(of: 2)
            if currentChar == "\"" && !isEscaped {
                break
            }
            consume()
            text.append(currentChar)
        }
        try expectAndConsume("\"")
        return text
    }
    
    
    private mutating func parseCustomElement() throws(ConsentParseError) -> ParsedCustomElement? {
        // swiftlint:disable:previous function_body_length cyclomatic_complexity
        guard currentChar == "<", let next = peek(), next.isValidIdentStart else {
            return nil
        }
        try expectAndConsume("<")
        let name = try parseIdentifier()
        var parsedElement = ParsedCustomElement(name: name)
        loop: while true {
            switch currentChar {
            case .none:
                break loop
            case ">":
                // end of opening tag
                consume()
                break loop
            case "/":
                // upcoming end of opening tag
                consume()
            case .some(let char) where char.isWhitespace:
                // whitespace/newlines between things
                consume()
            case .some:
                let attrName = try parseIdentifier()
                let attrValue: String
                if currentChar == "=" {
                    consume()
                    attrValue = try parseAttrValue()
                } else {
                    // attr w/out a value
                    attrValue = ""
                }
                parsedElement.attributes.append((attrName, attrValue))
            }
        }
        if let element = _attemptToCloseCustomElement(parsedElement) {
            return element
        } else {
            while true {
                if let element = try parseCustomElement() {
                    parsedElement.content.append(.element(element))
                } else {
                    let text = parseElementTextContents()
                    if !text.isEmpty {
                        parsedElement.content.append(.text(text))
                    } else {
                        // unable to parse an element, but also no text-only content in there...
                        if let element = _attemptToCloseCustomElement(parsedElement) {
                            consume(while: \.isWhitespace)
                            return element
                        } else {
                            try emitError(.other("unable to close \(name)"))
                        }
                    }
                }
            }
        }
        try emitError(.other("Unable to find closing tag for \(parsedElement)"))
    }
    
    
    private mutating func _attemptToCloseCustomElement(_ element: ParsedCustomElement) -> ParsedCustomElement? {
        let possibleClosingTags = ["</>", "</\(element.name)>"]
        for tag in possibleClosingTags {
            if remainingInput.starts(with: tag) { // swiftlint:disable:this for_where
                consume(tag.count)
                return element
            }
        }
        return nil
    }
    
    
    /// Parses the `{X}` part in `<element>{X}</element>`.
    private mutating func parseElementTextContents() -> String {
        var text = ""
        while let currentChar, currentChar != "<" {
            text.append(currentChar)
            consume()
        }
        return String(text.trimmingWhitespace())
    }
    
    private func emitError(_ kind: ConsentParseError.Kind) throws(ConsentParseError) -> Never {
        throw .init(kind: kind, sourceLoc: currentSourceLoc)
    }
}


extension ConsentDocumentParser {
    private var currentChar: Character? {
        input[safe: position]
    }
    
    private var remainingInput: Substring {
        input[position...]
    }
    
    private var currentLine: Substring? {
        remainingInput.isEmpty ? nil : remainingInput.prefix { !$0.isNewline }
    }
    
    private var isAtEnd: Bool {
        position >= input.endIndex
    }
    
    private var isAtBeginningOfLine: Bool {
        position == input.startIndex && position < input.endIndex || input[input.index(before: position)].isNewline
    }
    
    private func peek(_ offset: Int = 1) -> Character? {
        input[safe: input.index(position, offsetBy: offset)]
    }
    
    private mutating func consume(_ count: Int = 1) {
        guard count > 0 else { // swiftlint:disable:this empty_count
            return
        }
        let newIndex = input.index(position, offsetBy: count)
        position = min(input.endIndex, newIndex)
    }
    
    private mutating func consume(while predicate: (Character) -> Bool) {
        while let currentChar, predicate(currentChar) {
            consume()
        }
    }
    
    private mutating func expectAndConsume(_ char: Character) throws(ConsentParseError) {
        guard currentChar == char else {
            try emitError(.unexpectedCharacter)
        }
        consume()
    }
    
    /// Consumes all upcoming characters up to (and including) the next newline character.
    private mutating func consumeLine() {
        while let currentChar, !currentChar.isNewline {
            consume()
        }
        if currentChar?.isNewline == true {
            consume()
        }
    }
}


extension ConsentDocumentParser {
    private var currentSourceLoc: ConsentParseError.SourceLocation {
        let lineNumber = input[..<position].count(where: \.isNewline)
        let wholeCurrentLine = { () -> Substring in
            let startIdx = input[..<position].lastIndex(where: \.isNewline).map { input.index(after: $0) }
            let endIdx = remainingInput.firstIndex(where: \.isNewline)
            return switch (startIdx, endIdx) {
            case (nil, nil):
                input[...]
            case let (.some(startIdx), .none):
                input[startIdx...]
            case let (.none, .some(endIdx)):
                input[...endIdx]
            case let (.some(startIdx), .some(endIdx)):
                input[startIdx...endIdx]
            }
        }()
        return .init(
            line: UInt(lineNumber),
            column: UInt(wholeCurrentLine.distance(from: wholeCurrentLine.startIndex, to: position))
        )
    }
}


extension Character {
    fileprivate var isValidIdentStart: Bool {
        (self >= "a" && self <= "z") || (self >= "A" && self <= "Z") || self == "_"
    }
    
    fileprivate var isValidIdent: Bool {
        isValidIdentStart || (self >= "0" && self <= "9")
    }
}


extension ConsentDocumentParser {
    struct ParseResult: Sendable {
        let frontmatter: ConsentDocument.Frontmatter
        let sections: [ConsentDocument.Section]
    }
    
    static func parse(_ text: String) throws(ConsentParseError) -> ParseResult {
        var parser = ConsentDocumentParser(input: text)
        return try parser.parse()
    }
    
    static func parse(_ data: Data) throws(ConsentParseError) -> ParseResult {
        guard let text = String(data: data, encoding: .utf8) else {
            throw ConsentParseError(kind: .nonUTF8Input, sourceLoc: .zero)
        }
        return try parse(text)
    }
    
    static func parse(contentsOf url: URL) throws -> ParseResult {
        try parse(Data(contentsOf: url))
    }
}


extension ConsentDocument.Section {
    fileprivate enum ConstructSectionError: Error {
        case missingAttribute(String)
        case missingField(String)
        case unexpectedElement(String) // ewww assoc type
    }
    
    fileprivate static func toggle(_ element: ConsentDocumentParser.ParsedCustomElement) throws(ConstructSectionError) -> Self {
        guard let id = element[attribute: "id"], !id.isEmpty else {
            throw .missingAttribute("id")
        }
        guard case .text(let prompt) = element.content.first else {
            throw .missingField("prompt")
        }
        let defaultValue = element[attribute: "initialValue"].flatMap { Bool($0) } ?? false
        let expectedValue = element[attribute: "expectedValue"].flatMap { Bool($0) }
        return .toggle(.init(id: id, prompt: prompt, initialValue: defaultValue, expectedValue: expectedValue))
    }
    
    fileprivate static func select(_ element: ConsentDocumentParser.ParsedCustomElement) throws(ConstructSectionError) -> Self {
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
                    prompt.append("\n\n")
                    prompt.append(text)
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
        let findOption = { id in options.first { $0.id == id } }
        let initialSelection = element[attribute: "initialValue"].flatMap(findOption)
        let expectedSelection = element[attribute: "expectedValue"].flatMap(findOption)
        return .select(.init(
            id: id,
            prompt: prompt,
            options: options,
            initialValue: initialSelection,
            expectedValue: expectedSelection
        ))
    }
    
    fileprivate static func signature(_ element: ConsentDocumentParser.ParsedCustomElement) throws(ConstructSectionError) -> Self {
        guard let id = element[attribute: "id"], !id.isEmpty else {
            throw .missingField("id")
        }
        return .signature(.init(id: id))
    }
}


extension Collection {
    subscript(safe index: Index) -> Element? {
        index >= startIndex && index < endIndex ? self[index] : nil
    }
}


extension StringProtocol {
    func trimmingWhitespace() -> SubSequence {
        trimming(while: \.isWhitespace)
    }
}
