import SwiftData
import Foundation

@Model
final class SessionRecord {
    var id: UUID
    var savedAt: Date
    var planTitle: String
    var completedCount: Int
    var totalTasks: Int
    var tasksData: Data   // JSON-encoded [TaskItem] snapshot

    init(planTitle: String, tasks: [TaskItem]) {
        self.id = UUID()
        self.savedAt = Date()
        self.planTitle = planTitle.isEmpty ? "Untitled Plan" : planTitle
        self.completedCount = tasks.filter(\.isCompleted).count
        self.totalTasks = tasks.count
        self.tasksData = (try? JSONEncoder().encode(tasks)) ?? Data()
    }

    func decodeTasks() -> [TaskItem] {
        (try? JSONDecoder().decode([TaskItem].self, from: tasksData)) ?? []
    }
}
