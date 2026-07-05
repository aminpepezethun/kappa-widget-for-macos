import SwiftData

@MainActor
final class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init(inMemory: Bool = false) {
        let config = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        do {
            container = try ModelContainer(
                for: PlanRecord.self, SessionRecord.self,
                configurations: config
            )
        } catch {
            fatalError("SwiftData container failed: \(error)")
        }
    }
}
