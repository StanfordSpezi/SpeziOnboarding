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
@Observable
public final class ConsentDocumentExport: Equatable, Sendable {
    /// Provides default values for fields related to the `ConsentDocumentExport`.
    public enum Defaults {
        /// Default value for a document identifier.
        /// This identifier will be used as default value if no identifier is provided.
        public static let documentIdentifier = "ConsentDocument"
    }

    let asyncMarkdown: () async -> Data
    let exportConfiguration: ConsentDocument.ExportConfiguration
    var cachedPDF: PDFDocument?

    /// An unique identifier for the exported `ConsentDocument`.
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

    /// The `PDFDocument` exported from a `ConsentDocument`.
    /// This property is asynchronous and accesing it potentially triggers the export of the PDF from the underlying `ConsentDocument`,
    /// if the `ConsentDocument` has not been previously exported or the `PDFDocument` was not cached.
    /// For now, we always require a PDF to be cached to create a ConsentDocumentExport. In the future, we might change this to lazy-PDF loading.
    @MainActor public var pdf: PDFDocument {
        get async {
            if let pdf = cachedPDF {
                return pdf
            }
            
            guard let pdf = try? await export() else {
                return .init()
            }
            
            cachedPDF = pdf
            return pdf
        }
    }
    
    
    /// Creates a `ConsentDocumentExport`, which holds an exported PDF and the corresponding document identifier string.
    /// - Parameters:
    ///   - markdown: The markdown text for the document, which is shown to the user.
    ///   - documentIdentfier: A unique String identifying the exported `ConsentDocument`.
    ///   - exportConfiguration: The `ExportConfiguration` holding the properties of the document.
    ///   - cachedPDF: A `PDFDocument` exported from a `ConsentDocument`.
    init(
        markdown: @escaping () async -> Data,
        exportConfiguration: ConsentDocument.ExportConfiguration,
        documentIdentifier: String,
        cachedPDF: PDFDocument? = nil
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
}
