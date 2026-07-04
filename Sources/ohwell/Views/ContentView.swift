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
                // Timer section
                TimerView()
                    .padding(.top, 20)

                Spacer()
            }
        }
        .frame(width: 320, height: 480)
    }
}
