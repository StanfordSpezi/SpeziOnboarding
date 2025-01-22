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
public final class ConsentDocumentExport: Equatable {
    /// Provides default values for fields related to the `ConsentDocumentExport`.
    public enum Defaults {
        /// Default value for a document identifier.
        /// 
        /// This identifier will be used as default value if no identifier is provided.
        public static let documentIdentifier = "ConsentDocument"
    }

    let asyncMarkdown: () async -> Data
    let exportConfiguration: ConsentDocument.ExportConfiguration
    var cachedPDF: PDFDocument?

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
    ///   - markdown: The markdown text for the document, which is shown to the user.
    ///   - exportConfiguration: The `ExportConfiguration` holding the properties of the document.
    ///   - documentIdentifier: A unique String identifying the exported `ConsentDocument`.
    ///   - cachedPDF: A `PDFDocument` exported from a `ConsentDocument`.
    init(
        markdown: @escaping () async -> Data,
        exportConfiguration: ConsentDocument.ExportConfiguration,
        documentIdentifier: String,
        cachedPDF: sending PDFDocument? = nil
    ) {
        self.asyncMarkdown = markdown
        self.exportConfiguration = exportConfiguration
        self.documentIdentifier = documentIdentifier
        self.cachedPDF = cachedPDF
    }


    public static func == (lhs: ConsentDocumentExport, rhs: ConsentDocumentExport) -> Bool {
        lhs.documentIdentifier == rhs.documentIdentifier &&
        lhs.name == rhs.name &&
        lhs.signature == rhs.signature &&
        lhs.cachedPDF == rhs.cachedPDF
    }


    /// Consume the exported `PDFDocument` from a `ConsentDocument`.
    ///
    /// This method consumes the `ConsentDocumentExport/cachedPDF` by retrieving the exported `PDFDocument`.
    ///
    /// - Note: For now, we always require a PDF to be cached to create a `ConsentDocumentExport`. In the future, we might change this to lazy-PDF loading.
    public consuming func consumePDF() -> sending PDFDocument {
        // Accessing `cachedPDF` via `take()` ensures single consumption of the `PDFDocument` by transferring ownership
        // from the enclosing class and leaving `nil` behind after the access. Though `ConsentDocumentExport` is a reference
        // type, this manual ownership model guarantees the PDF is only used once, enabling safe cross-concurrency transfer.
        // The explicit `sending` return type reinforces transfer semantics, while `take()` enforces single-access at runtime.
        // This pattern provides compiler-verifiable safety for the `PDFDocument` transfer despite the class's reference semantics.
        //
        // See similar discussion: https://forums.swift.org/t/swift-6-consume-optional-noncopyable-property-and-transfer-sending-it-out/72414/3
        nonisolated(unsafe) let cachedPDF = cachedPDF.take() ?? .init()
        return cachedPDF
    }
}
