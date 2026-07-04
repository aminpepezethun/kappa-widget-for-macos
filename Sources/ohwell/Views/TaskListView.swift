import SwiftUI

struct TaskListView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable task list
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(appState.tasks) { task in
                        TaskRowView(
                            task: task,
                            isActive: appState.activeTaskIndex.map {
                                appState.tasks[$0].id == task.id
                            } ?? false
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .animation(.spring(duration: 0.3), value: appState.tasks.count)

            // Progress footer
            if !appState.tasks.isEmpty {
                Divider()
                    .background(appState.currentTheme.accentColor.opacity(0.2))

                HStack {
                    Text("\(appState.completedCount) of \(appState.tasks.count) done")
                        .font(.system(.caption, design: appState.currentTheme.fontDesign))
                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.7))

                    Spacer()

                    // Thin progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(appState.currentTheme.accentColor.opacity(0.15))
                            Capsule()
                                .fill(appState.currentTheme.accentColor)
                                .frame(width: geo.size.width * completionRatio)
                                .animation(.easeInOut(duration: 0.3), value: completionRatio)
                        }
                    }
                    .frame(width: 80, height: 4)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }

    private var completionRatio: Double {
        guard !appState.tasks.isEmpty else { return 0 }
        return Double(appState.completedCount) / Double(appState.tasks.count)
    }
}
