// TextConverter.swift (For plain TXT)

import Foundation


class TextConverter: DocumentConverter {
    let supportedExtensions = ["txt"]
    
    func convert(at url: URL, to format: OutputFormat) throws -> String {
        let text = try String(contentsOf: url, encoding: .utf8)
        
        switch format {
        case .markdown:
            return text
        case .json:
            guard let jsonData = try? JSONSerialization.data(withJSONObject: ["content": text], options: .prettyPrinted),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw ConversionError.jsonSerializationFailed
            }
            return jsonString
        }
    }
}
