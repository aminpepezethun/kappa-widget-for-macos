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

            // Placeholder — future phases fill this in
            VStack(spacing: 16) {
                Text("OhWell")
                    .font(.system(.title2, design: appState.currentTheme.fontDesign, weight: .semibold))
                    .foregroundStyle(appState.currentTheme.accentColor)

                Text("Theme: \(appState.currentTheme.name)")
                    .font(.system(.caption, design: appState.currentTheme.fontDesign))
                    .foregroundStyle(appState.currentTheme.accentColor.opacity(0.7))
            }
        }
        .frame(width: 320, height: 480)
    }
}
