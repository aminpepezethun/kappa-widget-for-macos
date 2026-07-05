import SwiftUI

struct SessionRowView: View {
    @Environment(HistoryState.self) private var historyState
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let session: SessionRecord

    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
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
                                .foregroundStyle(task.isCompleted ? session.color : session.color.opacity(0.4))

                            VStack(alignment: .leading, spacing: 1) {
                                Text(task.title)
                                    .font(.callout)
                                    .foregroundStyle(task.isCompleted ? session.color.opacity(0.6) : session.color)
                                    .strikethrough(task.isCompleted, color: session.color.opacity(0.5))
                                    .lineLimit(1)
                                if !task.description.isEmpty {
                                    Text(task.description)
                                        .font(.caption2)
                                        .foregroundStyle(session.color.opacity(0.5))
                                        .lineLimit(1)
                                }
                            }

                            Spacer()

                            if let m = task.estimatedMinutes {
                                Text(formatMinutes(m))
                                    .font(.caption2)
                                    .foregroundStyle(session.color.opacity(0.5))
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(.top, 4)
            }
        } label: {
            HStack(spacing: 8) {
                // Color dot
                Circle()
                    .fill(session.color)
                    .frame(width: 9, height: 9)

                VStack(alignment: .leading, spacing: 2) {
                    Text(session.sessionName)
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
