// DocumentConverter.swift (Protocol for converters, OOP interface)
import Foundation
import PDFKit
import AppKit

// Protocol for modular converters
protocol DocumentConverter {
    var supportedExtensions: [String] { get }
    func convert(at url: URL, to format: OutputFormat) throws -> String
}
