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

            // Main content
            VStack(spacing: 0) {
                TimerView()
                    .padding(.top, 20)

                Divider()
                    .background(appState.currentTheme.accentColor.opacity(0.2))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if appState.tasks.isEmpty {
                    PlanInputView()
                    Spacer()
                } else {
                    PlanInputView()
                    TaskListView()
                }
            }

            // Confetti overlay (non-interactive)
            ConfettiView()
        }
        .frame(width: 320, height: 480)
    }
}
