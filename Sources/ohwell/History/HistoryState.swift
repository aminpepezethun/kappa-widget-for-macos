import SwiftData
import SwiftUI

@Observable @MainActor
final class HistoryState {
    var sessions: [SessionRecord] = []
    private var modelContext: ModelContext?

    func load(from context: ModelContext) {
        modelContext = context
        refresh()
    }

    func refresh() {
        guard let ctx = modelContext else { return }
        let descriptor = FetchDescriptor<SessionRecord>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        sessions = (try? ctx.fetch(descriptor)) ?? []
    }

    func restore(session: SessionRecord, into appState: AppState) {
        // Save progress on current session before swapping
        appState.saveCurrentSessionSnapshot()

        // Load the selected session's tasks without creating a new session record
        let tasks = session.decodeTasks()
        appState.tasks = tasks
        appState.planText = session.planTitle
        appState.activeTaskIndex = tasks.firstIndex { !$0.isCompleted }
        appState.currentSessionId = session.id

        refresh()
    }

    func delete(session: SessionRecord) {
        guard let ctx = modelContext else { return }
        ctx.delete(session)
        try? ctx.save()
        sessions.removeAll { $0.id == session.id }
    }
}
