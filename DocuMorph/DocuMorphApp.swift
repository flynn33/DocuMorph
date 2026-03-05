import SwiftUI
import ForsettiHostTemplate

@main
struct DocuMorphApp: App {
    @StateObject private var container = DocuMorphContainer()

    var body: some Scene {
        WindowGroup {
            ForsettiHostRootView(
                controller: container.controller,
                injectionRegistry: container.injectionRegistry,
                showDeveloperControls: false
            )
        }
    }
}
