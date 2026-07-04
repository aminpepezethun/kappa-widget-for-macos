import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(TimerState.self) private var timerState

    var body: some View {
        ZStack {
            // Gradient background from active theme
            LinearGradient(
                colors: appState.currentTheme.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TimerView()
                    .padding(.top, 20)

                Divider()
                    .background(appState.currentTheme.accentColor.opacity(0.2))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if appState.tasks.isEmpty {
                    // Show input panel when no tasks
                    PlanInputView()
                    Spacer()
                } else {
                    // Show add-plan button + task list when tasks exist
                    PlanInputView()
                    TaskListView()
                }
            }
        }
        .frame(width: 320, height: 480)
    }
}
