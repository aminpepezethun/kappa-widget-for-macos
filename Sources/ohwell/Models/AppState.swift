import SwiftUI

@Observable @MainActor
final class AppState {
    var tasks: [TaskItem] = []
    var currentTheme: any Theme = ForestTheme()
    var completionTriggers: [UUID] = []   // grows each time a task is completed; ConfettiView observes count
    var activeTaskIndex: Int? = nil

    var availableThemes: [any Theme] {
        [ForestTheme(), SpaceTheme(), MinimalTheme()]
    }

    var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }

    func setTasks(_ newTasks: [TaskItem]) {
        tasks = newTasks
        activeTaskIndex = newTasks.firstIndex { !$0.isCompleted }
    }

    func complete(task id: UUID) {
        guard let idx = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[idx].isCompleted = true
        completionTriggers.append(id)
        // Auto-advance to next incomplete task
        activeTaskIndex = tasks.firstIndex { !$0.isCompleted }
    }

    func resetAll() {
        for idx in tasks.indices {
            tasks[idx].isCompleted = false
        }
        completionTriggers.removeAll()
        activeTaskIndex = tasks.firstIndex { !$0.isCompleted }
    }
}
