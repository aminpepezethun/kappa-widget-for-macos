import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(TimerState.self) private var timerState

    var body: some View {
        ZStack {
            LinearGradient(
                colors: appState.currentTheme.backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderView()

                Divider()
                    .background(appState.currentTheme.accentColor.opacity(0.2))
                    .padding(.horizontal, 16)

                TimerView()
                    .padding(.top, 12)

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

            ConfettiView()
        }
        .frame(width: 320, height: 480)
    }
}
