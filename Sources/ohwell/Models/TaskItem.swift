import Foundation

struct TaskItem: Identifiable, Sendable, Codable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var estimatedMinutes: Int?
    var iconSymbol: String

    init(id: UUID = UUID(), title: String, description: String = "",
         isCompleted: Bool = false, estimatedMinutes: Int? = nil,
         iconSymbol: String = "circle") {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.estimatedMinutes = estimatedMinutes
        self.iconSymbol = iconSymbol
    }
}
