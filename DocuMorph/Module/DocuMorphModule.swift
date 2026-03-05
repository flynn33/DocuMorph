import Foundation
import ForsettiCore

final class DocuMorphModule: ForsettiAppModule {
    nonisolated let descriptor = ModuleDescriptor(
        moduleID: "com.daley.jim.documorph",
        displayName: "DocuMorph",
        moduleVersion: SemVer(major: 2, minor: 0, patch: 0),
        moduleType: .app
    )

    nonisolated let manifest = ModuleManifest(
        schemaVersion: ModuleManifest.supportedSchemaVersion,
        moduleID: "com.daley.jim.documorph",
        displayName: "DocuMorph",
        moduleVersion: SemVer(major: 2, minor: 0, patch: 0),
        moduleType: .app,
        supportedPlatforms: [.macOS],
        minForsettiVersion: SemVer(major: 0, minor: 1, patch: 0),
        capabilitiesRequested: [.fileExport, .storage],
        entryPoint: "DocuMorphModule"
    )

    nonisolated let uiContributions = UIContributions(
        viewInjections: [
            ViewInjectionDescriptor(
                injectionID: "documorph-main-workspace",
                slot: "module.workspace",
                viewID: "documorph-workspace",
                priority: 100
            )
        ]
    )

    private nonisolated(unsafe) var isStarted = false

    nonisolated init() {}

    nonisolated func start(context: ForsettiContext) throws {
        guard !isStarted else { return }

        isStarted = true
        let logger = context.moduleLogger(moduleID: descriptor.moduleID)
        context.publishFrameworkEvent(
            type: "documorph.module.started",
            payload: ["moduleID": descriptor.moduleID],
            sourceModuleID: descriptor.moduleID
        )
        logger.info("DocuMorphModule started")
    }

    nonisolated func stop(context: ForsettiContext) {
        guard isStarted else { return }

        isStarted = false
        let logger = context.moduleLogger(moduleID: descriptor.moduleID)
        context.publishFrameworkEvent(
            type: "documorph.module.stopped",
            payload: ["moduleID": descriptor.moduleID],
            sourceModuleID: descriptor.moduleID
        )
        logger.info("DocuMorphModule stopped")
    }
}
