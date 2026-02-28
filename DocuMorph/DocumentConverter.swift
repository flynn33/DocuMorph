import Foundation

protocol DocumentConverter {
    var supportedExtensions: [String] { get }
    func convert(at url: URL, to format: OutputFormat) throws -> String
}

nonisolated enum ReadableOutputFormatter {
    private struct DraftBlock {
        let type: ReadableBlockType
        let text: String
    }

    struct ReadableDocument: Codable {
        let version: String
        let source: ReadableSource
        let summary: ReadableSummary
        let content: ReadableContent
    }

    struct ReadableSource: Codable {
        let fileName: String
        let fileExtension: String
        let convertedAt: String
    }

    struct ReadableSummary: Codable {
        let blockCount: Int
        let pageCount: Int?
    }

    struct ReadableContent: Codable {
        let blocks: [ReadableBlock]?
        let pages: [ReadablePage]?
    }

    struct ReadablePage: Codable {
        let page: Int
        let blockCount: Int
        let blocks: [ReadableBlock]
    }

    enum ReadableBlockType: String, Codable {
        case heading
        case paragraph
        case listItem
    }

    struct ReadableBlock: Codable {
        let order: Int
        let type: ReadableBlockType
        let text: String
    }

    private static let markdownHeadingRegex = try! NSRegularExpression(pattern: #"^#{1,6}\s+(.+)$"#)
    private static let listItemRegex = try! NSRegularExpression(pattern: #"^([-*]|\d+[.)])\s+(.+)$"#)

    static func markdownDocument(title: String, text: String) -> String {
        let blocks = numberedBlocks(from: text)
        return renderMarkdown(title: title, blocks: blocks, headingPrefix: "##")
    }

    static func markdownDocument(title: String, pageTexts: [String]) -> String {
        var outputLines: [String] = ["# \(title)"]

        for (index, pageText) in pageTexts.enumerated() {
            let blocks = numberedBlocks(from: pageText)
            outputLines.append("")
            outputLines.append("## Page \(index + 1)")
            outputLines.append("")

            if blocks.isEmpty {
                outputLines.append("_No extractable text on this page._")
                continue
            }

            outputLines.append(contentsOf: renderMarkdownBody(blocks: blocks, headingPrefix: "###"))
        }

        return outputLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
    }

    static func jsonDocument(fileName: String, sourceExtension: String, text: String) throws -> String {
        let blocks = numberedBlocks(from: text)
        let payload = ReadableDocument(
            version: "1.0",
            source: ReadableSource(
                fileName: fileName,
                fileExtension: sourceExtension.lowercased(),
                convertedAt: iso8601Now()
            ),
            summary: ReadableSummary(
                blockCount: blocks.count,
                pageCount: nil
            ),
            content: ReadableContent(
                blocks: blocks,
                pages: nil
            )
        )

        return try encode(payload)
    }

    static func jsonDocument(fileName: String, sourceExtension: String, pageTexts: [String]) throws -> String {
        let pages = pageTexts.enumerated().map { index, pageText in
            let blocks = numberedBlocks(from: pageText)
            return ReadablePage(
                page: index + 1,
                blockCount: blocks.count,
                blocks: blocks
            )
        }

        let totalBlockCount = pages.reduce(0) { $0 + $1.blockCount }
        let payload = ReadableDocument(
            version: "1.0",
            source: ReadableSource(
                fileName: fileName,
                fileExtension: sourceExtension.lowercased(),
                convertedAt: iso8601Now()
            ),
            summary: ReadableSummary(
                blockCount: totalBlockCount,
                pageCount: pages.count
            ),
            content: ReadableContent(
                blocks: nil,
                pages: pages
            )
        )

        return try encode(payload)
    }

    static func readableTitle(from fileURL: URL) -> String {
        let stem = fileURL.deletingPathExtension().lastPathComponent
        let words = stem
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map(String.init)

        guard !words.isEmpty else {
            return stem
        }

        return words.map(capitalizeWordKeepingAcronyms).joined(separator: " ")
    }

    private static func numberedBlocks(from text: String) -> [ReadableBlock] {
        return draftBlocks(from: text).enumerated().map { offset, draft in
            ReadableBlock(order: offset + 1, type: draft.type, text: draft.text)
        }
    }

    private static func draftBlocks(from text: String) -> [DraftBlock] {
        let lines = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\u{2022}", with: "- ")
            .components(separatedBy: .newlines)

        var blocks: [DraftBlock] = []
        var paragraphBuffer: [String] = []

        func flushParagraphBuffer() {
            guard !paragraphBuffer.isEmpty else { return }
            let merged = mergeParagraphLines(paragraphBuffer)
            if !merged.isEmpty {
                blocks.append(DraftBlock(type: .paragraph, text: merged))
            }
            paragraphBuffer.removeAll(keepingCapacity: true)
        }

        for (index, rawLine) in lines.enumerated() {
            let trimmed = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            let nextTrimmed = (index + 1 < lines.count)
                ? lines[index + 1].trimmingCharacters(in: .whitespacesAndNewlines)
                : ""
            let nextLineIsBreak = nextTrimmed.isEmpty

            if trimmed.isEmpty {
                flushParagraphBuffer()
                continue
            }

            if let heading = parseMarkdownHeading(in: trimmed) {
                flushParagraphBuffer()
                blocks.append(DraftBlock(type: .heading, text: heading))
                continue
            }

            if let listItem = parseListItem(in: trimmed) {
                flushParagraphBuffer()
                blocks.append(DraftBlock(type: .listItem, text: listItem))
                continue
            }

            if looksLikeHeading(trimmed, nextLineIsBreak: nextLineIsBreak) {
                flushParagraphBuffer()
                blocks.append(DraftBlock(type: .heading, text: trimmed))
                continue
            }

            paragraphBuffer.append(trimmed)
        }

        flushParagraphBuffer()
        return blocks
    }

    private static func parseMarkdownHeading(in line: String) -> String? {
        let range = NSRange(location: 0, length: line.utf16.count)
        guard let match = markdownHeadingRegex.firstMatch(in: line, options: [], range: range),
              match.numberOfRanges > 1,
              let headingRange = Range(match.range(at: 1), in: line) else {
            return nil
        }

        return collapseWhitespace(in: String(line[headingRange]))
    }

    private static func parseListItem(in line: String) -> String? {
        let range = NSRange(location: 0, length: line.utf16.count)
        guard let match = listItemRegex.firstMatch(in: line, options: [], range: range),
              match.numberOfRanges > 2,
              let itemRange = Range(match.range(at: 2), in: line) else {
            return nil
        }

        return collapseWhitespace(in: String(line[itemRange]))
    }

    private static func looksLikeHeading(_ line: String, nextLineIsBreak: Bool) -> Bool {
        guard nextLineIsBreak else { return false }
        guard line.count <= 80 else { return false }
        guard !line.hasSuffix(".") else { return false }

        let words = line.split(whereSeparator: \.isWhitespace)
        guard (1...10).contains(words.count) else { return false }

        let letters = line.filter(\.isLetter)
        guard letters.count >= 3 else { return false }

        let uppercaseLetters = letters.filter(\.isUppercase).count
        if uppercaseLetters == letters.count {
            return true
        }

        let titleCaseWordCount = words.filter { word in
            guard let firstCharacter = word.first else { return false }
            return firstCharacter.isUppercase
        }.count

        return titleCaseWordCount >= max(1, words.count - 1)
    }

    private static func mergeParagraphLines(_ lines: [String]) -> String {
        var merged = ""

        for rawLine in lines {
            let line = collapseWhitespace(in: rawLine)
            guard !line.isEmpty else { continue }

            if merged.isEmpty {
                merged = line
                continue
            }

            if merged.hasSuffix("-"), let first = line.first, first.isLetter {
                merged.removeLast()
                merged += line
            } else {
                merged += " " + line
            }
        }

        return merged
    }

    private static func collapseWhitespace(in text: String) -> String {
        return text
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    private static func renderMarkdown(title: String, blocks: [ReadableBlock], headingPrefix: String) -> String {
        var lines: [String] = ["# \(title)", ""]
        lines.append(contentsOf: renderMarkdownBody(blocks: blocks, headingPrefix: headingPrefix))
        return lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
    }

    private static func renderMarkdownBody(blocks: [ReadableBlock], headingPrefix: String) -> [String] {
        var lines: [String] = []
        var previousBlockWasList = false

        for block in blocks {
            switch block.type {
            case .heading:
                if !lines.isEmpty && lines.last != "" {
                    lines.append("")
                }
                lines.append("\(headingPrefix) \(block.text)")
                lines.append("")
                previousBlockWasList = false

            case .paragraph:
                if !lines.isEmpty && lines.last != "" {
                    lines.append("")
                }
                lines.append(block.text)
                previousBlockWasList = false

            case .listItem:
                if !previousBlockWasList && !lines.isEmpty && lines.last != "" {
                    lines.append("")
                }
                lines.append("- \(block.text)")
                previousBlockWasList = true
            }
        }

        return lines
    }

    private static func iso8601Now() -> String {
        return ISO8601DateFormatter().string(from: Date())
    }

    private static func encode(_ document: ReadableDocument) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(document)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw ConversionError.jsonSerializationFailed
        }
        return jsonString
    }

    private static func capitalizeWordKeepingAcronyms(_ word: String) -> String {
        guard word.count > 1 else { return word.uppercased() }
        if word.allSatisfy(\.isUppercase) {
            return word
        }
        return word.prefix(1).uppercased() + word.dropFirst().lowercased()
    }
}
