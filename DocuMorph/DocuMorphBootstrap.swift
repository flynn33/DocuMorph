import Combine
import SwiftUI
import ForsettiCore
import ForsettiHostTemplate
import ForsettiPlatform

@MainActor
final class DocuMorphContainer: ObservableObject {
    let controller: ForsettiHostController
    let injectionRegistry: ForsettiViewInjectionRegistry

    init() {
        let registry = ModuleRegistry()
        DocuMorphModuleRegistry.registerAll(into: registry)

        controller = ForsettiHostTemplateBootstrap.makeController(
            manifestsBundle: Bundle.main,
            moduleRegistry: registry,
            entitlementProvider: ForsettiEntitlementProviderFactory.makeDefault()
        )

        injectionRegistry = ForsettiViewInjectionRegistry()
        registerViewInjections()
    }

    private func registerViewInjections() {
        injectionRegistry.register(viewID: "documorph-workspace") {
            ContentView()
        }
    }
}
