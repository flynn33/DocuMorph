# DocuMorph Wiki

## Overview

DocuMorph is a macOS document conversion utility built on the Forsetti Framework. It batch-converts documents from a source folder into human-readable Markdown or structured JSON output.

This wiki covers the application architecture, Forsetti Framework integration, and development guidelines.

## Forsetti Framework Integration

DocuMorph uses the [Forsetti Framework v0.1.0](https://github.com/jdaley/Forsetti-Framework), a proprietary modular Swift runtime framework for native Apple applications created by James Daley. The framework provides modular architecture, runtime lifecycle management, and protocol-based service abstraction.

### Deployment Pattern

DocuMorph uses **Forsetti Deployment Pattern A (Single-Module App)**:

- The entire application (UI and business logic) is encapsulated in a single `ForsettiAppModule`.
- The Forsetti Framework runs silently in the background.
- End users interact only with the DocuMorph conversion interface.
- Framework developer controls are hidden (`showDeveloperControls: false`).

### Module Architecture

```
DocuMorphApp (Entry Point)
  └── DocuMorphContainer (Forsetti Bootstrap)
        ├── ModuleRegistry
        │     └── DocuMorphModule (ForsettiAppModule)
        ├── ForsettiHostController
        │     └── ForsettiRuntime
        └── ForsettiViewInjectionRegistry
              └── "documorph-workspace" → ContentView
```

### Module Manifest

The module is discovered at runtime via its JSON manifest at `Resources/ForsettiManifests/DocuMorphModule.json`:

- **Module ID**: `com.daley.jim.documorph`
- **Type**: `app` (ForsettiAppModule)
- **Platform**: macOS
- **Capabilities**: `file_export`, `storage`
- **Entry Point**: `DocuMorphModule`

### Bootstrap Flow

1. `DocuMorphApp` creates a `DocuMorphContainer` (ObservableObject).
2. The container registers the `DocuMorphModule` factory in a `ModuleRegistry`.
3. `ForsettiHostTemplateBootstrap.makeController()` assembles the runtime with platform services, entitlement provider, and the module registry.
4. View injections are registered — the `ContentView` is mapped to the `"documorph-workspace"` view ID.
5. `ForsettiHostRootView` renders the host with developer controls hidden.
6. On boot, the runtime discovers the module manifest from `Bundle.main`, validates compatibility, and activates the module.
7. The module's view injection renders the `ContentView` in the `module.workspace` slot.

## Conversion Pipeline

### Supported Input Formats

| Format | Converter | Method |
|--------|-----------|--------|
| PDF | `PDFConverter` | PDFKit page-by-page text extraction |
| DOCX | `AttributedDocumentConverter` | NSAttributedString officeOpenXML |
| DOC | `AttributedDocumentConverter` | NSAttributedString docFormat |
| RTF | `AttributedDocumentConverter` | NSAttributedString rtf |
| ODT | `AttributedDocumentConverter` | NSAttributedString openDocument |
| HTML/HTM | `AttributedDocumentConverter` | NSAttributedString html |
| TXT | `TextConverter` | UTF-8 plain text |

### Output Formats

- **Markdown**: Structural headings, list items, and normalized paragraphs with page segmentation for PDFs.
- **JSON**: Version-tagged document model with source metadata, summary statistics, and content blocks/pages.

### Processing Pipeline

1. `ConversionManager` enumerates files in the source directory.
2. Each file is matched to a converter by extension.
3. The converter extracts text and delegates to `ReadableOutputFormatter`.
4. The formatter applies heuristic-based structure detection (headings, lists, paragraphs).
5. Output is written to the target directory with the appropriate extension.

## Development Guidelines

### Forsetti Rules

- Forsetti is a **sealed dependency** — do not modify files in `Packages/ForsettiFramework/`.
- All classes must be marked `final` unless extension is intentional and documented.
- Use constructor dependency injection; avoid hidden globals.
- Use native Apple technologies only (Swift, SwiftUI, Apple frameworks).
- Dependencies must flow one-way; no circular dependencies.

### Adding New Converters

1. Create a `final class` conforming to `DocumentConverter`.
2. Declare `supportedExtensions`.
3. Implement `convert(at:to:)` using `ReadableOutputFormatter` for consistent output.
4. Register in `ConversionManager`'s default converter list.

## About

- **Developer**: Jim Daley
- **Framework**: Built with the Forsetti Framework v0.1.0 by James Daley
- **License**: Proprietary (see LICENSE.md)
- **Version**: 2.0.0 <!-- x-release-please-version -->
