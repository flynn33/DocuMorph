import Foundation

final class TextConverter: DocumentConverter {
    let supportedExtensions = ["txt"]
    
    func convert(at url: URL, to format: OutputFormat) throws -> String {
        let text = try String(contentsOf: url, encoding: .utf8)
        
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
                    sourceExtension: url.pathExtension,
                    text: text
                )
            } catch {
                throw ConversionError.jsonSerializationFailed
            }
        }
    }
}
