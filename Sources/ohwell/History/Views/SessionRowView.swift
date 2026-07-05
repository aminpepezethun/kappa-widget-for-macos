import SwiftUI

struct SessionRowView: View {
    @Environment(HistoryState.self) private var historyState
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let session: SessionRecord

    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            // Inner task list — loaded from JSON snapshot in SessionRecord
            let tasks = session.decodeTasks()
            if tasks.isEmpty {
                Text("No tasks recorded.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(tasks) { task in
                        HStack(spacing: 8) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 12))
                                .foregroundStyle(task.isCompleted ? .green : .secondary)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(task.title)
                                    .font(.callout)
                                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                                    .strikethrough(task.isCompleted)
                                    .lineLimit(1)
                                if !task.description.isEmpty {
                                    Text(task.description)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()

                            if let m = task.estimatedMinutes {
                                Text(formatMinutes(m))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(.top, 4)
            }
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(session.planTitle)
                        .font(.callout)
                        .fontWeight(.medium)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Text(session.savedAt.formatted(date: .abbreviated, time: .shortened))
                        Text("·")
                        Text("\(session.completedCount)/\(session.totalTasks) done")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Restore") {
                    historyState.restore(session: session, into: appState)
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.vertical, 2)
        }
    }

    private func formatMinutes(_ minutes: Int) -> String {
        minutes < 60 ? "\(minutes)m" : "\(minutes / 60)h\(minutes % 60 == 0 ? "" : "\(minutes % 60)m")"
    }
}
