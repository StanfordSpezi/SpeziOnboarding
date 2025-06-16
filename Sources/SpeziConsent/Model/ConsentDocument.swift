//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PencilKit
import SpeziFoundation
import SwiftUI
import class PDFKit.PDFDocument


/// Represents and manages a Markdown-based (potentially interactive) Consent Document.
///
/// `ConsentDocument` instances are intended to be used as State Objects; they are Observable and provide state for various consent-related views,
/// such as e.g. the ``ConsentDocumentView`` or the ``OnboardingConsentView``.
///
/// `ConsentDocument`s are created from Markdown-formatted text, which can optionally include custom interactive elements defined by SpeziConsent,
/// in order to enable form-like data collection from users as they are going through the consent document.
///
/// Users are typically required to sign consent documents; unless explicitly instructed not to all `ConsentDocument`s include an implicit signature field at the bottom of the
///
/// ### State management
/// In addition to defining the contents of the document, the `ConsentDocument` class also keeps track of the values the user entered for the document's interactive components.
/// It also provides APIs for understanding the overall state of the documement, such as ``isExporting``, ``isSigning``, and ``completionState``.
///
/// ### Exporting
/// Use the ``ConsentDocument/export(using:)`` function to obtain a PDF representation of the formatted document, taking into account user responses for interactive components.
///
/// ### Advanced Consent Documents: Metadata
/// The ``ConsentDocument`` automatically detects and parses a frontmatter-style metadata block, if present at the beginning of the document.
/// The metadata consists of a simple key-value mapping of String data, enclosed within two `---` lines:
/// ```
/// ---
/// title: Heart Failure Study Consent
/// version: 1.0.1
/// ---
/// ```
/// The following keys are defined by SpeziConsent:
/// - `title`: used when exporting a Consent Document as a PDF; embedded into the PDF's metadata and used as its filename.
/// - `version`: a [SemVer](https://semver.org/)-encoded version string representing the version of the consent form.
/// In addition to these, applications may place arbitrary key-value pairs into a consent document's metadata.
///
/// ### Advanced Consent Documents: Interactive Elements
///
/// A ``ConsentDocument``'s input Markdown can contain several interactive custom elements,
/// which will be translated into standard SwiftUI input controls by the ``ConsentDocumentView``.
/// These elements are embedded into a Markdown file using a simple HTML-based syntax:
/// - `toggle`: a boolean Yes/No toggle;
/// - `select`: a single-choice selection from a list of options;
/// - `signature`: a form consisting of text fields for first and last name, and a signature field the user is asked to sign.
///
/// Each element must always have an `id`, which must be unique across all element types.
/// Additionally, elements can have optional initial value and expected value attributes;
/// if present the initial value will be used as the element's default selection if possible, and the expected
///
/// Attribute values in this HTML-like syntax are always parsed and interpreted as strings; if the value would also be a valid identifier it can be written as-is;
/// otherwise (e.g., if it starts with a digit) it needs to be wrapped in double quotes.
///
/// #### Input Validation
/// Some of the elements offer optional input validation, which prevents a ``ConsentDocument`` from being considered as "completed" (see ``ConsentDocument/completionState``)
/// unless the value entered by the user matches a specified expected value.
/// This mechanism can be used to only allow the user to progress in e.g. an onboarding scenario if they have entered correct values into some of the consent form's elements.
///
/// For example, the following `toggle` will prevent its ``ConsentDocument`` from being completed unless the user selects a true value:
/// ```html
/// <toggle id="data-sharing" expectedValue=true>
///     I agree that the data i enter into the app may used for scientific research
/// </toggle>
/// ```
///
/// > Note: In the examples below, `{X}` denotes a placeholder representing valid text values.
/// For example, `{*}` would represent a position where arbitrary text is valid, `{true|false}` one where either `true` or `false` is valid, and so on.
///
/// #### Toggle Element
/// The `toggle`element models a binary Yes/No selection the user is asked to make.
///
/// Specification:
/// ```html
/// <toggle id={*} initial-value={true|false} expected-value={true|false}>Prompt Text</toggle>
/// ```
/// - `id` attribute: required; used to identify the element and provide access to the user-entered data
/// - `initial-value` attribute: optional; used as the initial selection value; defaults to `false`
/// - `expected-value` attribute: optional; allows controlling the consent document completion state
/// - text content: required; used as the user-visible label when the toggle is presented as a SwiftUI control
///
/// #### Select Element
/// The `select` element models a single-choice selection the user is asked to make from a list of possible values.
///
/// Specification:
/// ```html
/// <select id={*} initial-value={option-id?} expected-value={option-id?}>
///     <option id={*}>{Option1 Title}</option>
///     ...
///     <option id={*}>{OptionN Title}</option>
/// </select>
/// ```
/// - `id` attribute: required; used to identify the element and provide access to the user-entered data
/// - `initial-value` attribute: optional; the `id` of one of the options contained within the `select`; used as the initial selection value; defaults to an empty selection if missing
/// - `expected-value` attribute: optional; the `id` of one of the options contained within the `select`; allows controlling the consent document completion state
/// - content: required; a series of `<option>` elements, each of which consists of an `id` attribute and a title in its text contents.
///
/// #### Signature Element
/// The `signature` element models a form consisting of name entry text fields and a signature drawing canvas.
///
/// Specification:
/// ```html
/// <signature id={*} />
/// ```
/// - `id` attribute: required; used to identify the element and provide access to the user-entered data
///
/// ## Topics
///
/// ### Creating Consent Documents
/// - ``init(markdown:initialName:enableCustomElements:)-(String,_,_)``
/// - ``init(markdown:initialName:enableCustomElements:)-(Data,_,_)``
/// - ``init(contentsOf:initialName:enableCustomElements:)``
/// - ``LoadError``
///
/// ### Accessing Form Contents
/// - ``frontmatter``
/// - ``signatureDate``
/// - ``SignatureStorage``
///
/// ### State Handling
/// - ``isExporting``
/// - ``isSigning``
/// - ``completionState``
/// - ``ConsentCompletionState``
///
/// ### Exporting Consent Documents
/// - ``export(using:)``
/// - ``ExportConfiguration``
/// - ``isExporting``
///
/// ### Other
/// - ``customElementsEnabled``
@Observable
@MainActor
public final class ConsentDocument: Sendable {
    /// An Error that occurred when initializing a Markdown-based ``ConsentDocument``.
    ///
    /// ## Topics
    /// ### Enumeration Cases
    /// - ``inputNotUTF8``
    /// - ``failedToParse(_:)``
    /// - ``duplicateCustomElementId(_:)``
    /// 
    /// ### Other
    /// - ``ConsentParseError``
    public enum LoadError: Error {
        /// The input was not valid UTF-8-encoded text.
        case inputNotUTF8
        /// The parser was unable to process the input.
        case failedToParse(ConsentParseError)
        /// The input contains multiple custom elements with identical `id`s.
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
    
    /// The document's frontmatter metadata.
    nonisolated public let frontmatter: [String: String]
    /// The document's extracted content, as a series of sections.
    nonisolated let sections: [Section]
    
    /// Stores the state of the document's interactive sections.
    private var interactiveSectionsState = InteractiveSectionsState()
    
    /// Whether the `ConsentDocument` was created with support for custom elements enabled.
    public let customElementsEnabled: Bool
    /// The document's signature date, if any.
    public var signatureDate: String?
    /// Indicates whether a signature is currently being signed somewhere in the consent document.
    public package(set) var isSigning = false
    /// Indicates whether the document is currently being exported.
    public private(set) var isExporting = false
    
    /// Creates a Consent Document by parsing a Markdown String
    ///
    /// - parameter markdown: The Markdown input
    /// - parameter initialName: The default name that should be used for signature forms embedded in the Document
    /// - parameter enableCustomElements: Whether the Document should enable support for parsing custom elements when processing `markdown`. Defaults to true.
    public init(markdown: String, initialName: PersonNameComponents? = nil, enableCustomElements: Bool = true) throws(LoadError) {
        customElementsEnabled = enableCustomElements
        if enableCustomElements {
            do {
                let parseResult = try ConsentDocumentParser.parse(markdown)
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
    
    /// Creates a Consent Document by parsing a Markdown Data object
    ///
    /// - parameter markdown: The Markdown input. Must be valid UTF-8.
    /// - parameter initialName: The default name that should be used for signature forms embedded in the Document
    /// - parameter enableCustomElements: Whether the Document should enable support for parsing custom elements when processing `markdown`. Defaults to true.
    public convenience init(markdown: Data, initialName: PersonNameComponents? = nil, enableCustomElements: Bool = true) throws(LoadError) {
        guard let text = String(data: markdown, encoding: .utf8) else {
            throw .inputNotUTF8
        }
        try self.init(markdown: text, initialName: initialName, enableCustomElements: enableCustomElements)
    }
    
    /// Creates a Consent Document by parsing Markdown from a URL.
    ///
    /// - parameter url: The url of the Markdown file.
    /// - parameter initialName: The default name that should be used for signature forms embedded in the Document
    /// - parameter enableCustomElements: Whether the Document should enable support for parsing custom elements when processing the markdown text. Defaults to true.
    public convenience init(contentsOf url: URL, initialName: PersonNameComponents? = nil, enableCustomElements: Bool = true) throws {
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
    /// A ``ConsentDocument``'s completion state.
    public enum ConsentCompletionState: Hashable, Sendable {
        /// The document is complete, meaning that all required interactive elements have been filled out by the user and, where applicable, have their expected values.
        case complete
        /// The document is not yet complete, meaning that there exists at least one required interactive elements which doesn't yet have a value, or whose value is different from its expected value.
        /// - parameter firstIncompleteId: the id of the first incomplete element in the document.
        case incomplete(firstIncompleteId: String)
    }
    
    /// The document's completion state
    public var completionState: ConsentCompletionState {
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


// MARK: Metadata

extension ConsentDocument {
    /// The document's title, if present in the metadata
    public var title: String? {
        frontmatter["title"]
    }
    
    /// The document's version, if present in the metadata
    public var version: Version? {
        frontmatter["version"].flatMap { Version($0) }
    }
}


// MARK: Export

extension ConsentDocument {
    /// Exports the consent document as a formatted PDF.
    public func export(using config: ConsentDocument.ExportConfiguration) throws -> sending PDFKit.PDFDocument {
        isExporting = true
        defer {
            isExporting = false
        }
        let renderer = PDFRenderer(consentDocument: self, config: config)
        return try renderer.render()
    }
}


// MARK: Other

extension ConsentDocument: Identifiable, Hashable {
    nonisolated public static func == (lhs: ConsentDocument, rhs: ConsentDocument) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
