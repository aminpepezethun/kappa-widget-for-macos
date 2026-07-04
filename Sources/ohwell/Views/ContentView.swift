import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(TimerState.self) private var timerState

    private var allDone: Bool {
        !appState.tasks.isEmpty && appState.completedCount == appState.tasks.count
    }

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

            // All-done celebration overlay
            if allDone {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(appState.currentTheme.completionColor)
                        .scaleEffect(1.0)

                    Text("All done!")
                        .font(.system(.title2, design: appState.currentTheme.fontDesign, weight: .bold))
                        .foregroundStyle(appState.currentTheme.accentColor)

                    Text("Great work 🎉")
                        .font(.system(.callout, design: appState.currentTheme.fontDesign))
                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.8))

                    Button(action: { appState.resetAll() }) {
                        Text("Start Over")
                            .font(.system(.callout, design: appState.currentTheme.fontDesign, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(appState.currentTheme.accentColor))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    appState.currentTheme.backgroundGradient.first?
                        .opacity(0.95) ?? Color.black.opacity(0.95)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.spring(duration: 0.4), value: allDone)
        .frame(width: 320, height: 480)
    }
}
