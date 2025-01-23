//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import PDFKit
import PencilKit
import SwiftUI


/// A type representing an exported `ConsentDocument`. It holds the exported `PDFDocument` and the corresponding document identifier String.
public struct ConsentDocumentExportRepresentation: Equatable {
    /// Provides default values for fields related to the `ConsentDocumentExportRepresentation`.
    public enum Defaults {
        /// Default value for a document identifier.
        /// 
        /// This identifier will be used as default value if no identifier is provided.
        public static let documentIdentifier = "ConsentDocument"
    }


    /// An unique identifier for the exported `ConsentDocument`.
    ///
    /// Corresponds to the identifier which was passed  when creating the `ConsentDocument` using an `OnboardingConsentView`.
    public let documentIdentifier: String
    /// Export configuration of the document.
    let configuration: Configuration

    let markdown: Data
    #if !os(macOS)
    let signature: PKDrawing
    let signatureImage: UIImage
    #else
    let signature: String
    #endif
    let name: PersonNameComponents
    let formattedSignatureDate: String?


    #if !os(macOS)
    // TODO: Docs
    /// Creates a `ConsentDocumentExportRepresentation`, which holds an exported PDF and the corresponding document identifier string.
    /// - Parameters:
    ///   - markdown: The markdown text for the document, which is shown to the user.
    ///   - exportConfiguration: The `ExportConfiguration` holding the properties of the document.
    ///   - documentIdentifier: A unique String identifying the exported `ConsentDocument`.
    init(
        markdown: Data,
        signature: PKDrawing,
        signatureImage: UIImage,
        name: PersonNameComponents,
        formattedSignatureDate: String?,
        documentIdentifier: String,
        configuration: Configuration
    ) {
        self.markdown = markdown
        self.name = name
        self.signature = signature
        self.signatureImage = signatureImage
        self.formattedSignatureDate = formattedSignatureDate
        self.documentIdentifier = documentIdentifier
        self.configuration = configuration
    }
    #else
    /// Creates a `ConsentDocumentExportRepresentation`, which holds an exported PDF and the corresponding document identifier string.
    /// - Parameters:
    ///   - markdown: The markdown text for the document, which is shown to the user.
    ///   - exportConfiguration: The `ExportConfiguration` holding the properties of the document.
    ///   - documentIdentifier: A unique String identifying the exported `ConsentDocument`.
    init(
        markdown: Data,
        signature: String,
        name: PersonNameComponents,
        formattedSignatureDate: String?,
        documentIdentifier: String,
        configuration: Configuration
    ) {
        self.markdown = markdown
        self.name = name
        self.signature = signature
        self.formattedSignatureDate = formattedSignatureDate
        self.documentIdentifier = documentIdentifier
        self.configuration = configuration
    }
    #endif
}
