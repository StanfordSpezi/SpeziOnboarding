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
public class ConsentDocumentExport {
    /// Provides default values for fields related to the `ConsentDocumentExport`.
    public enum Defaults {
        /// Default value for a document identifier.
        /// 
        /// This identifier will be used as default value if no identifier is provided.
        public static let documentIdentifier = "ConsentDocument"
    }

    let asyncMarkdown: () async -> Data
    let exportConfiguration: ConsentDocument.ExportConfiguration
    var cachedPDF: PDFDocument

    /// An unique identifier for the exported `ConsentDocument`.
    ///
    /// Corresponds to the identifier which was passed  when creating the `ConsentDocument` using an `OnboardingConsentView`.
    public let documentIdentifier: String

    /// The name of the person which signed the document.
    public var name = PersonNameComponents()
    #if !os(macOS)
    /// The signature of the signee as drawing.
    public var signature = PKDrawing()
    /// The image generated from the signature drawing.
    public var signatureImage = UIImage()
    #else
    /// The signature of the signee as string.
    public var signature = String()
    #endif


    /// Creates a `ConsentDocumentExport`, which holds an exported PDF and the corresponding document identifier string.
    /// - Parameters:
    ///   - documentIdentifier: A unique String identifying the exported `ConsentDocument`.
    ///   - cachedPDF: A `PDFDocument` exported from a `ConsentDocument`.
    init(
        markdown: @escaping () async -> Data,
        exportConfiguration: ConsentDocument.ExportConfiguration,
        documentIdentifier: String,
        cachedPDF: sending PDFDocument = .init()
    ) {
        self.asyncMarkdown = markdown
        self.exportConfiguration = exportConfiguration
        self.documentIdentifier = documentIdentifier
        self.cachedPDF = cachedPDF
    }

    /// Consume the exported `PDFDocument` from a `ConsentDocument`.
    ///
    /// This method consumes the `ConsentDocumentExport` by retrieving the exported `PDFDocument`.
    ///
    /// This property is asynchronous and accessing it potentially triggers the export of the PDF from the underlying `ConsentDocument`,
    /// if the `ConsentDocument` has not been previously exported or the `PDFDocument` was not cached.
    ///
    /// - Note: For now, we always require a PDF to be cached to create a ConsentDocumentExport. In the future, we might change this to lazy-PDF loading.
    public consuming func consumePDF() async -> sending PDFDocument {
        // Something the compiler doesn't realize here is that we can send the `PDFDocument` because it is located in a non-Sendable, non-Copyable
        // type and accessing it will consume the enclosing type. Therefore, the PDFDocument instance can only be accessed once (even in async method)
        // and that is fully checked at compile time by the compiler :rocket:
        // See similar discussion: https://forums.swift.org/t/swift-6-consume-optional-noncopyable-property-and-transfer-sending-it-out/72414/3
        nonisolated(unsafe) let cachedPDF = cachedPDF
        return cachedPDF
    }
}
