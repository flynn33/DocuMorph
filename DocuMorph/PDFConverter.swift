// PDFConverter.swift (Concrete class for PDF, implements protocol)


import PDFKit
import Foundation

class PDFConverter: DocumentConverter {
    let supportedExtensions = ["pdf"]
    
    func convert(at url: URL, to format: OutputFormat) throws -> String {
        guard let pdfDocument = PDFDocument(url: url) else {
            throw ConversionError.invalidDocument
        }
        
        var output = ""
        
        switch format {
        case .markdown:
            output += "# Converted PDF\n\n"
            for pageIndex in 0..<pdfDocument.pageCount {
                guard let page = pdfDocument.page(at: pageIndex) else { continue }
                let pageText = page.string ?? ""
                
                let lines = pageText.components(separatedBy: .newlines)
                if let firstLine = lines.first, !firstLine.isEmpty {
                    output += "## Page \(pageIndex + 1): \(firstLine)\n\n"
                }
                output += lines.dropFirst().joined(separator: "\n") + "\n\n"
            }
            
        case .json:
            var pages: [[String: String]] = []
            for pageIndex in 0..<pdfDocument.pageCount {
                guard let page = pdfDocument.page(at: pageIndex) else { continue }
                pages.append(["page": String(pageIndex + 1), "text": page.string ?? ""])
            }
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: ["pages": pages], options: .prettyPrinted),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw ConversionError.jsonSerializationFailed
            }
            output = jsonString
        }
        
        return output
    }
}
