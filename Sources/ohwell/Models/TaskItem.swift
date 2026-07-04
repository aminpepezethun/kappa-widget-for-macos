import Foundation

struct TaskItem: Identifiable, Sendable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var estimatedMinutes: Int?
    var iconSymbol: String

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false,
         estimatedMinutes: Int? = nil, iconSymbol: String = "circle") {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.estimatedMinutes = estimatedMinutes
        self.iconSymbol = iconSymbol
    }
}
