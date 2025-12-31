// Updated ConversionManager.swift (replace the entire file with this)
// Add import Foundation for FileManager, URL, utf8.

import Foundation

class ConversionManager {
    private let fileManager: FileManager
    private let converters: [DocumentConverter]
    
    // Dependency injection for testing/debugging
    init(fileManager: FileManager = .default,
         converters: [DocumentConverter] = [PDFConverter(), AttributedDocumentConverter(), TextConverter()]) {
        self.fileManager = fileManager
        self.converters = converters
    }
    
    func convertFiles(in sourceURL: URL, to targetURL: URL, format: OutputFormat) throws {
        let files = try fileManager.contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: nil)
        
        for fileURL in files {
            let ext = fileURL.pathExtension.lowercased()
            if let converter = converters.first(where: { $0.supportedExtensions.contains(ext) }) {
                let output = try converter.convert(at: fileURL, to: format)
                
                let fileName = fileURL.lastPathComponent
                let outputExt = format == .markdown ? "md" : "json"
                let outputURL = targetURL.appendingPathComponent(fileName.replacingOccurrences(of: ".\(ext)", with: ".\(outputExt)"))
                
                try output.write(to: outputURL, atomically: true, encoding: .utf8)
            }
            // Skip unsupported files silently; log for debugging if needed
        }
    }
}
