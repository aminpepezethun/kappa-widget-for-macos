import SwiftUI
import SwiftData

@Observable @MainActor
final class AppState {
    var tasks: [TaskItem] = []
    var planText: String = ""
    var currentTheme: any Theme = ForestTheme()
    var completionTriggers: [UUID] = []
    var activeTaskIndex: Int? = nil

    // Injected by AppDelegate after init — nil in tests, persistence is skipped
    var modelContext: ModelContext?
    private var sessionSaved = false

    var availableThemes: [any Theme] {
        // Add more themes here
        [ForestTheme(), SpaceTheme(), MinimalTheme()]
    }

    var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }

    // MARK: - Public API

    func setTasks(_ newTasks: [TaskItem], planText: String = "") {
        tasks = newTasks
        self.planText = planText
        activeTaskIndex = newTasks.firstIndex { !$0.isCompleted }
        sessionSaved = false
        savePlan()
    }

    // Appends new tasks to the existing list without discarding completed work.
    // The merged list is re-encoded as JSON in PlanRecord so the full set survives restart.
    func appendTasks(_ newTasks: [TaskItem]) {
        tasks.append(contentsOf: newTasks)
        activeTaskIndex = tasks.firstIndex { !$0.isCompleted }
        savePlan()
    }

    func updateTime(taskId: UUID, minutes: Int?) {
        guard let idx = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        tasks[idx].estimatedMinutes = minutes
        savePlan()
    }

    func updateTask(id: UUID, title: String, description: String) {
        guard let idx = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[idx].title = title
        tasks[idx].description = description
        savePlan()
    }

    func archiveCompleted() {
        let completed = tasks.filter(\.isCompleted)
        guard !completed.isEmpty else { return }
        if tasks.allSatisfy(\.isCompleted), !sessionSaved {
            saveSession()
            sessionSaved = true
        }
        tasks.removeAll(where: \.isCompleted)
        activeTaskIndex = tasks.firstIndex { !$0.isCompleted }
        completionTriggers.removeAll()
        savePlan()
    }

    func complete(task id: UUID) {
        guard let idx = tasks.firstIndex(where: { $0.id == id }),
              !tasks[idx].isCompleted else { return }
        tasks[idx].isCompleted = true
        completionTriggers.append(id)
        activeTaskIndex = tasks.firstIndex { !$0.isCompleted }
        savePlan()
        if !sessionSaved && tasks.allSatisfy(\.isCompleted) {
            saveSession()
            sessionSaved = true
        }
    }

    func uncomplete(task id: UUID) {
        guard let idx = tasks.firstIndex(where: { $0.id == id }),
              tasks[idx].isCompleted else { return }
        tasks[idx].isCompleted = false
        activeTaskIndex = tasks.firstIndex { !$0.isCompleted }
        sessionSaved = false
        savePlan()
    }

    func resetAll() {
        for idx in tasks.indices {
            tasks[idx].isCompleted = false
        }
        completionTriggers.removeAll()
        activeTaskIndex = tasks.firstIndex { !$0.isCompleted }
        sessionSaved = false
        savePlan()
    }

    // Loads persisted plan on startup — called by AppDelegate
    func loadSavedPlan() {
        guard let ctx = modelContext else { return }
        let descriptor = FetchDescriptor<PlanRecord>()
        guard let record = try? ctx.fetch(descriptor).first else { return }
        let loaded = record.toTaskItems()
        guard !loaded.isEmpty else { return }
        planText = record.planText
        tasks = loaded
        activeTaskIndex = loaded.firstIndex { !$0.isCompleted }
    }

    // MARK: - Private persistence

    private func savePlan() {
        guard let ctx = modelContext else { return }
        let descriptor = FetchDescriptor<PlanRecord>()
        if let existing = try? ctx.fetch(descriptor).first {
            existing.update(planText: planText, tasks: tasks)
        } else {
            ctx.insert(PlanRecord(planText: planText, tasks: tasks))
        }
        try? ctx.save()
    }

    private func saveSession() {
        guard let ctx = modelContext, !tasks.isEmpty else { return }
        let title = planText
            .split(separator: "\n", omittingEmptySubsequences: true)
            .first
            .map(String.init) ?? "Untitled Plan"
        ctx.insert(SessionRecord(planTitle: title, tasks: tasks))
        try? ctx.save()
    }

}
