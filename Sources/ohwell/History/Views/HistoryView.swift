import SwiftUI

struct HistoryView: View {
    @Environment(HistoryState.self) private var historyState
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if historyState.sessions.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(historyState.sessions) { session in
                        SessionRowView(session: session)
                    }
                    .onDelete { offsets in
                        let toDelete = offsets.map { historyState.sessions[$0] }
                        toDelete.forEach { historyState.delete(session: $0) }
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear { historyState.refresh() }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
            Text("No sessions yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Complete a full plan to save a session.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
