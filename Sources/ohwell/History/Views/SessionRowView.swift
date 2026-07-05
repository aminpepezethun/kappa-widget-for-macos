import SwiftUI

struct SessionRowView: View {
    @Environment(HistoryState.self) private var historyState
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let session: SessionRecord

    var body: some View {
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
