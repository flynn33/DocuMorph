# DocuMorph

DocuMorph is a simple SwiftUI application that converts document files (such as PDF, DOCX, DOC, RTF, ODT, HTML, HTM, and TXT) from a source folder to JSON or Markdown (.md) formats in a target folder, making them more computer-readable. It is developed primarily for macOS using Xcode, with potential for Windows compatibility via Swift toolchains.

## Features
- Supports conversion of various document formats to Markdown or JSON.
- User-friendly interface for selecting source and target folders.
- Modular design with protocol-based converters for easy extension.
- Uses CoreData for persistence (e.g., preview data).
- Handles security-scoped resources for folder access.

## Installation
1. Clone the repository:
2. Open the project in Xcode (version 15 or later) on macOS.
3. Build and run the app.

For Windows development:
- Use the Swift for Windows toolchain (experimental).
- Note: SwiftUI and some dependencies like PDFKit/AppKit are macOS-native; adaptations may be needed.

## Usage
1. Launch the app.
2. Select a **Source Folder** containing documents to convert.
3. Select a **Target Folder** for output files.
4. Choose output format: **Markdown** or **JSON**.
5. Click **Convert Files**.
6. Converted files will appear in the target folder with appropriate extensions (.md or .json).

Supported input extensions: pdf, docx, doc, rtf, odt, html, htm, txt.

## Dependencies
- SwiftUI
- PDFKit
- AppKit
- CoreData
- Foundation

No external packages; all are Apple frameworks.

## Project Structure
- `DocuMorphApp.swift`: App entry point.
- `ContentView.swift`: Main UI view.
- `ConversionManager.swift`: Handles file conversion logic.
- Converter classes: `PDFConverter.swift`, `AttributedDocumentConverter.swift`, `TextConverter.swift` (Note: TextConverter.swift is referenced but may need implementation if missing).
- `Persistence.swift`: CoreData setup.
- Other: Enums, protocols, errors, and Info.plist.

## Building and Running
- Requires macOS for full functionality.
- For testing: Use the preview mode in PersistenceController.

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License
See [LICENSE](LICENSE) for details.

## Author
Created by independent consultant, developer, and engineer Jim Daley for internal use by Camping World.  See license for further. 

*Last updated: December 31, 2025*