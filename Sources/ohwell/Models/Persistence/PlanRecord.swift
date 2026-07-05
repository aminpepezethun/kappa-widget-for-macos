import SwiftData
import Foundation

@Model
final class PlanRecord {
    var id: UUID
    var createdAt: Date
    var updatedAt: Date
    var planText: String
    var tasksData: Data   // JSON-encoded [TaskItem]

    init(planText: String, tasks: [TaskItem]) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.planText = planText
        self.tasksData = (try? JSONEncoder().encode(tasks)) ?? Data()
    }

    func update(planText: String, tasks: [TaskItem]) {
        self.planText = planText
        self.updatedAt = Date()
        self.tasksData = (try? JSONEncoder().encode(tasks)) ?? Data()
    }

    func toTaskItems() -> [TaskItem] {
        (try? JSONDecoder().decode([TaskItem].self, from: tasksData)) ?? []
    }
}
