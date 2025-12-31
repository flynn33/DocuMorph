// Updated AttributedDocumentConverter.swift (replace the entire file with this)
// Ensure imports are at the top: Foundation for URL, JSONSerialization, CharacterSet; AppKit for NSAttributedString.

import Foundation
import AppKit

class AttributedDocumentConverter: DocumentConverter {
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
        let ext = url.pathExtension.lowercased()
        guard let docType = documentType(for: ext) else {
            throw ConversionError.unsupportedFormat
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: docType]
        let attrString = try NSAttributedString(url: url, options: options, documentAttributes: nil)
        let text = attrString.string
        
        switch format {
        case .markdown:
            // Basic paragraph separation
            return text.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
                .joined(separator: "\n\n")
        case .json:
            guard let jsonData = try? JSONSerialization.data(withJSONObject: ["content": text], options: .prettyPrinted),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw ConversionError.jsonSerializationFailed
            }
            return jsonString
        }
    }
}
