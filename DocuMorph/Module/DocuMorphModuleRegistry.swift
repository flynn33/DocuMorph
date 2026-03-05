import ForsettiCore

enum DocuMorphModuleRegistry {
    static func registerAll(into registry: ModuleRegistry) {
        registry.register(entryPoint: "DocuMorphModule") {
            DocuMorphModule()
        }
    }
}
