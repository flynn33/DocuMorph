import Foundation
import AppKit

final class AttributedDocumentConverter: DocumentConverter {
    let supportedExtensions = ["docx", "doc", "rtf", "odt", "html", "htm"]
    
    private func documentType(for ext: String) -> NSAttributedString.DocumentType? {
        switch ext.lowercased() {
        case "doc": return .docFormat
        case "docx": return .officeOpenXML
        case "rtf": return .rtf
        case "odt": return .openDocument
        case "html", "htm": return .html
        default: return nil
        }
    }
    
    func convert(at url: URL, to format: OutputFormat) throws -> String {
        let sourceExtension = url.pathExtension.lowercased()
        guard let docType = documentType(for: sourceExtension) else {
            throw ConversionError.unsupportedFormat
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: docType]
        let attrString = try NSAttributedString(url: url, options: options, documentAttributes: nil)
        let text = attrString.string
        
        switch format {
        case .markdown:
            return ReadableOutputFormatter.markdownDocument(
                title: ReadableOutputFormatter.readableTitle(from: url),
                text: text
            )
        case .json:
            do {
                return try ReadableOutputFormatter.jsonDocument(
                    fileName: url.lastPathComponent,
                    sourceExtension: sourceExtension,
                    text: text
                )
            } catch {
                throw ConversionError.jsonSerializationFailed
            }
        }
    }
}
