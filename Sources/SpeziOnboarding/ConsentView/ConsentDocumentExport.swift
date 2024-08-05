import PDFKit

/// A type representing an exported `ConsentDocument`. It holds the exported `PDFDocument` and the corresponding `ConsentDocumentIdentifier`.
public actor ConsentDocumentExport {
    private var cachedPDF: PDFDocument?
    
    /// An unique identifier for the exported `ConsentDocument`.
    /// Corresponds to the identifier which was passed  when creating the `ConsentDocument` using an `OnboardingConsentView`.
    public let documentIdentifier: ConsentDocumentIdentifier
    /// The `PDFDocument` exported from a `ConsentDocument`.
    /// This property is asynchronous and accesing it potentially triggers the export of the PDF from the underlying `ConsentDocument`,
    /// if the `ConsentDocument` has not been previously exported or the `PDFDocument` was not cached.
    public var pdf: PDFDocument? {
        get async {
            if cachedPDF == nil {
                // Lazy generate PDF.
                // This would possibly require to have an instance of ConsentDocument somwhere.
                // cachedPdf = await consentDocument.export()
                // For now, return nil.
                return nil
            }
            
            return cachedPDF
        }
    }
    
    /// Creates a `ConsentDocumentExport`, which holds an exported PDF and the corresponding `ConsentDocumentIdentifier`.
    /// - Parameters:
    ///   - documentIdentfier: A unique `ConsentDocumentIdentifier` identifying the exported `ConsentDocument`.
    ///   - cachedPDF: A `PDFDocument` representing exported from a `ConsentDocument`. Optional parameter which will be stored internally and is accessible via the async property `ConsentDocumentExport.pdf`.
    public init(
        documentIdentifier: ConsentDocumentIdentifier,
        cachedPDF: PDFDocument? = nil
    ) {
        self.documentIdentifier = documentIdentifier
        self.cachedPDF = cachedPDF
    }
}
