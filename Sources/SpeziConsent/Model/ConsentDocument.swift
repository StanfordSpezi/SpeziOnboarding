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
/// Users are typically required to sign consent documents; unless explicitly instructed not to all `ConsentDocument`s include an implicit signature field at the bottom of the document.
/// For ``ConsentDocument``s created with the `enableCustomElements` flag set to `true` (the default),
/// the application is responsible to include at least one `signature` element in the document's input markdown text (see below).
/// If the `enableCustomElements` flag is set to `false`, the ``ConsentDocument`` initializers will automatically append a signature element at the end of the document.
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
/// <toggle id="data-sharing" expected-value=true>
///     I agree that the data I enter into the app may used for scientific research.
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
///     {Prompt Text}
///     <option id={*}>{Option1 Title}</option>
///     ...
///     <option id={*}>{OptionN Title}</option>
/// </select>
/// ```
/// - `id` attribute: required; used to identify the element and provide access to the user-entered data
/// - `initial-value` attribute: optional; the `id` of one of the options contained within the `select`; used as the initial selection value; defaults to an empty selection if missing
/// - `expected-value` attribute: optional; the `id` of one of the options contained within the `select`; allows controlling the consent document completion state.
///     Setting this value to `*` will result in any selected value being accepted (ie, you want to require the user to make a selection, but don't want to enforce any "correct" selection).
///     Omit the `expected-value` entirely in order to also allow empty selections.
/// - content: required; a series of markdown text blocks and `<option>` elements, each of which consists of an `id` attribute and a title in its text contents.
///     You can intersperse prompt text and options. The parser will combine all raw text found within the `select` element by joining each line with a space.
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
/// - ``init(contentsOf:initialName:enableCustomElements:)``
/// - ``LoadError``
///
/// ### Accessing Form Contents
/// - ``metadata``
/// - ``userResponses-swift.property``
/// - ``signatureDate``
/// - ``SignatureStorage``
/// - ``UserResponses-swift.struct``
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
/// - ``ExportResult``
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
        case failedToParse(MarkdownDocument.ParseError)
        /// Something went wrong trying to process the document's interactive/custom elements.
        case failedToProcessInteractiveElements(String)
        /// The input contains multiple custom elements with identical `id`s.
        case duplicateCustomElementId(String)
    }
    
    /// Storage container for the data entered into a ``ConsentSignatureForm``, as part of filling out a ``ConsentDocument``.
    public struct SignatureStorage: Hashable, Codable, @unchecked Sendable {
        // ^^ SAFETY: we should be able to safely mark this as @unchecked Sendable, since PKDrawing is likely Sendable already
        //    (it's explicitly intended as a value type alternative to PKDrawingReference), but is probably just missing the annotation.
        //    See also FB18233435 (`PKDrawing` isn't marked as Sendable; should be since it's a value type)
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
        
        public init(name: PersonNameComponents? = nil) {
            self.name = name ?? .init()
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
    
    /// Stores the user responses provided by a user for a ``ConsentDocument``.
    public struct UserResponses: Hashable, Codable, Sendable {
        /// The user's responses to the consent document's `toggle` elements.
        public internal(set) var toggles: [String: Bool] = [:]
        /// The user's responses to the consent document's `select` elements.
        public internal(set) var selects: [String: String] = [:]
        /// The user's responses to the consent document's `signature` elements.
        public internal(set) var signatures: [String: SignatureStorage] = [:]
    }
    
    /// The underlying `MarkdownDocument`, from which this `ConsentDocument` was created.
    nonisolated let markdownDocument: MarkdownDocument
    
    /// The document's metadata, parsed from the markdown frontmatter if present.
    nonisolated public var metadata: MarkdownDocument.Metadata {
        markdownDocument.metadata
    }
    /// The document's extracted content, as a series of sections.
    ///
    /// There is a 1:1 correspondence between the `sections` and `markdownDocument.blocks`.
    nonisolated let sections: [Section]
    
    /// Stores the state of the document's interactive sections.
    public private(set) var userResponses = UserResponses()
    
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
    public init(markdown: String, initialName: PersonNameComponents? = nil) throws(LoadError) {
        do {
            markdownDocument = try MarkdownDocument(
                processing: markdown,
                customElementNames: ["toggle", "select", "signature", "option"]
            )
        } catch {
            throw LoadError.failedToParse(error)
        }
        sections = try markdownDocument.blocks.map { block throws(LoadError) -> Section in
            switch block {
            case .markdown(id: _, let rawContents):
                return .markdown(rawContents)
            case .customElement(let parsedElement):
                do {
                    switch parsedElement.name {
                    case "toggle":
                        return try Section.toggle(parsedElement)
                    case "select":
                        return try Section.select(parsedElement)
                    case "signature":
                        return try Section.signature(parsedElement)
                    default:
                        throw LoadError.failedToProcessInteractiveElements("Unexpected top-level element: \(parsedElement.name)")
                    }
                } catch let error as LoadError {
                    throw error
                } catch {
                    throw LoadError.failedToProcessInteractiveElements(
                        "Unable to construct \(parsedElement.name.localizedCapitalized) element from \(parsedElement): \(error)"
                    )
                }
            }
        }
        try processConsentFileSections(defaultName: initialName)
    }
    
    /// Creates a Consent Document by parsing a Markdown Data object
    ///
    /// - parameter markdown: The Markdown input. Must be valid UTF-8.
    /// - parameter initialName: The default name that should be used for signature forms embedded in the Document
    public convenience init(markdown: Data, initialName: PersonNameComponents? = nil) throws(LoadError) {
        guard let text = String(data: markdown, encoding: .utf8) else {
            throw .inputNotUTF8
        }
        try self.init(markdown: text, initialName: initialName)
    }
    
    /// Creates a Consent Document by parsing Markdown from a URL.
    ///
    /// - parameter url: The url of the Markdown file.
    /// - parameter initialName: The default name that should be used for signature forms embedded in the Document
    public convenience init(contentsOf url: URL, initialName: PersonNameComponents? = nil) throws {
        let data = try Data(contentsOf: url)
        try self.init(markdown: data, initialName: initialName)
    }
    
    private func processConsentFileSections(defaultName: PersonNameComponents?) throws(LoadError) {
        for section in sections {
            switch section {
            case .markdown:
                break
            case .toggle(let config):
                userResponses.toggles[config.id] = config.initialValue
            case .select(let config):
                userResponses.selects[config.id] = config.initialValue
            case .signature(var config):
                config.initialName = defaultName
                userResponses.signatures[config.id] = .init(name: defaultName)
            }
        }
    }
}


extension ConsentDocument {
    func binding<S: InteractiveSectionProtocol>(for section: S) -> Binding<S.Value> {
        Binding<S.Value> {
            self.userResponses[keyPath: section.userResponsesKeyPath] ?? section.initialValue
        } set: { newValue in
            self.userResponses[keyPath: section.userResponsesKeyPath] = newValue
        }
    }
    
    func value<S: InteractiveSectionProtocol>(for section: S) -> S.Value {
        userResponses[keyPath: section.userResponsesKeyPath] ?? section.initialValue
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
        typealias ISP = InteractiveSectionProtocol
        for section in sections {
            switch section {
            case .markdown:
                continue
            case .toggle(let config as any ISP), .select(let config as any ISP), .signature(let config as any ISP):
                if !config.valueMatchesExpected(in: self) {
                    return .incomplete(firstIncompleteId: config.id)
                }
            }
        }
        return .complete
    }
}


extension ConsentDocument.InteractiveSectionProtocol {
    @MainActor
    fileprivate func valueMatchesExpected(in document: ConsentDocument) -> Bool {
        self.valueMatchesExpected(document.value(for: self))
    }
}


// MARK: Export

extension ConsentDocument {
    /// Result of an export operation. Contains the produced PDF as well as associated metadata.
    public struct ExportResult {
        /// The filled out PDF document that was created from the consent document and the user-provided responses.
        public let pdf: PDFKit.PDFDocument
        /// The consent document's metadata.
        public let metadata: MarkdownDocument.Metadata
        /// The user's provided responses for the interactive elements in the consent form.
        public let userResponses: UserResponses
    }
    
    /// Exports the consent document as a formatted PDF.
    public func export(using config: ConsentDocument.ExportConfiguration) throws -> sending ExportResult {
        isExporting = true
        defer {
            isExporting = false
        }
        let renderer = PDFRenderer(consentDocument: self, config: config)
        let pdf = try renderer.render()
        return ExportResult(
            pdf: pdf,
            metadata: metadata,
            userResponses: userResponses
        )
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
