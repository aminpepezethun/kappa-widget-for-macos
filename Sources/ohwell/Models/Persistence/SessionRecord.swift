import SwiftData
import Foundation
import SwiftUI

@Model
final class SessionRecord {
    var id: UUID
    var savedAt: Date
    var planTitle: String       // kept for backward compat
    var sessionName: String     // user-provided name
    var colorHex: String        // assigned from palette on creation
    var completedCount: Int
    var totalTasks: Int
    var tasksData: Data         // JSON-encoded [TaskItem] snapshot

    init(sessionName: String, planTitle: String, tasks: [TaskItem], colorHex: String) {
        self.id = UUID()
        self.savedAt = Date()
        self.sessionName = sessionName.isEmpty ? (planTitle.isEmpty ? "Untitled" : planTitle) : sessionName
        self.planTitle = planTitle
        self.colorHex = colorHex
        self.completedCount = tasks.filter(\.isCompleted).count
        self.totalTasks = tasks.count
        self.tasksData = (try? JSONEncoder().encode(tasks)) ?? Data()
    }

    func decodeTasks() -> [TaskItem] {
        (try? JSONDecoder().decode([TaskItem].self, from: tasksData)) ?? []
    }

    func updateSnapshot(tasks: [TaskItem]) {
        completedCount = tasks.filter(\.isCompleted).count
        totalTasks = tasks.count
        tasksData = (try? JSONEncoder().encode(tasks)) ?? Data()
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    // Six-color palette — assigned cyclically at session creation.
    static let palette: [String] = [
        "#5B8CFF",  // blue
        "#A855F7",  // purple
        "#22C55E",  // green
        "#F97316",  // orange
        "#EC4899",  // pink
        "#14B8A6",  // teal
    ]
}

// MARK: - Color hex init

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard hex.count == 6,
              let value = UInt64(hex, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8)  & 0xFF) / 255
        let b = Double(value         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
