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


/// Represents a to-be-exported ``ConsentDocument``.
///
/// It holds all the content necessary to export the ``ConsentDocument`` as a `PDFDocument` and the corresponding identifier String in ``ConsentDocumentExportRepresentation/documentIdentifier``.
/// Using ``ConsentDocumentExportRepresentation/render()`` performs the rendering of the ``ConsentDocument`` as a PDF.
public struct ConsentDocumentExportRepresentation: Equatable {
    /// An unique identifier for the exported ``ConsentDocument``.
    ///
    /// Corresponds to the identifier which was passed  when creating the ``ConsentDocument`` using an ``OnboardingConsentView``.
    public let documentIdentifier: String

    let configuration: Configuration
    let markdown: Data
    #if !os(macOS)
    let signature: UIImage
    #else
    let signature: String
    #endif
    let name: PersonNameComponents
    let formattedSignatureDate: String?


    #if !os(macOS)
    /// Creates a ``ConsentDocumentExportRepresentation`` with all necessary content to export the ``ConsentDocument``
    ///
    /// - Parameters:
    ///   - markdown: The markdown text of the consent document.
    ///   - signature: The rendered signature image of the consent document.
    ///   - name: The name components of the signature.
    ///   - formattedSignatureDate: The performed `String`-based signature date.
    ///   - documentIdentifier: A unique `String` identifying the ``ConsentDocumentExportRepresentation`` upon export.
    ///   - exportConfiguration: Holds configuration properties of the to-be-exported document.
    init(
        markdown: Data,
        signature: UIImage,
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
    #else
    /// Creates a ``ConsentDocumentExportRepresentation`` with all necessary content to export the ``ConsentDocument``
    ///
    /// - Parameters:
    ///   - markdown: The markdown text of the consent document.
    ///   - signature: The `String`-based signature of the consent document.
    ///   - name: The name components of the signature.
    ///   - formattedSignatureDate: The performed `String`-based signature date.
    ///   - documentIdentifier: A unique `String` identifying the ``ConsentDocumentExportRepresentation`` upon export.
    ///   - exportConfiguration: Holds configuration properties of the to-be-exported document.
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
