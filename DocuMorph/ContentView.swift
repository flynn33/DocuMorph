// ContentView.swift (UI layer, now uses ConversionManager for business logic)
// This separates UI from conversion logic for better modularity.

import SwiftUI
import AppKit  // For NSOpenPanel and NSAttributedString

struct ContentView: View {
    @State private var sourceFolderURL: URL? = nil
    @State private var targetFolderURL: URL? = nil
    @State private var outputFormat: OutputFormat = .markdown
    @State private var statusMessage: String = ""
    
    // Inject the manager (could use dependency injection for testing)
    private let conversionManager = ConversionManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Document Converter")
                .font(.title)
            
            HStack {
                Text("Source Folder:")
                Button("Select") {
                    selectSourceFolder()
                }
                Text(sourceFolderURL?.path ?? "Not selected")
            }
            
            HStack {
                Text("Target Folder:")
                Button("Select") {
                    selectTargetFolder()
                }
                Text(targetFolderURL?.path ?? "Not selected")
            }
            
            Picker("Output Format", selection: $outputFormat) {
                Text("Markdown").tag(OutputFormat.markdown)
                Text("JSON").tag(OutputFormat.json)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Button("Convert Files") {
                convertFiles()
            }
            .disabled(sourceFolderURL == nil || targetFolderURL == nil)
            
            Text(statusMessage)
                .foregroundColor(.red)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 200)
    }
    
    private func selectSourceFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let url = panel.url {
            sourceFolderURL = url
        }
    }
    
    private func selectTargetFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let url = panel.url {
            targetFolderURL = url
        }
    }
    
    private func convertFiles() {
        guard let sourceURL = sourceFolderURL, let targetURL = targetFolderURL else { return }
        
        statusMessage = "Converting..."
        
        DispatchQueue.global().async {
            do {
                try conversionManager.convertFiles(in: sourceURL, to: targetURL, format: outputFormat)
                
                DispatchQueue.main.async {
                    statusMessage = "Conversion complete!"
                }
            } catch {
                DispatchQueue.main.async {
                    statusMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
