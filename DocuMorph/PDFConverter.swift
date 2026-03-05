import PDFKit
import Foundation

final class PDFConverter: DocumentConverter {
    let supportedExtensions = ["pdf"]
    
    func convert(at url: URL, to format: OutputFormat) throws -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw ConversionError.invalidDocument
        }

        let pageTexts = (0..<pdfDocument.pageCount).map { pageIndex in
            pdfDocument.page(at: pageIndex)?.string ?? ""
        }
        
        switch format {
        case .markdown:
            return ReadableOutputFormatter.markdownDocument(
                title: ReadableOutputFormatter.readableTitle(from: url),
                pageTexts: pageTexts
            )

        case .json:
            do {
                return try ReadableOutputFormatter.jsonDocument(
                    fileName: url.lastPathComponent,
                    sourceExtension: url.pathExtension,
                    pageTexts: pageTexts
                )
            } catch {
                throw ConversionError.jsonSerializationFailed
            }
        }
    }
}
