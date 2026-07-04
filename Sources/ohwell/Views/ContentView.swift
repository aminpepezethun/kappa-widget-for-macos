import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(TimerState.self) private var timerState
    @State private var dismissedAllDone = false

    private var allDone: Bool {
        !appState.tasks.isEmpty && appState.completedCount == appState.tasks.count
    }

    private var showAllDoneOverlay: Bool {
        allDone && !dismissedAllDone
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
                    .padding(.top, 8)

                Divider()
                    .background(appState.currentTheme.accentColor.opacity(0.2))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if appState.tasks.isEmpty {
                    PlanInputView()
                    EmptyTaskStateView()
                } else {
                    PlanInputView()
                    TaskListView()
                }
            }

            ConfettiView()

            // All-done celebration overlay
            if showAllDoneOverlay {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(appState.currentTheme.completionColor)

                    Text("All done!")
                        .font(.system(.title2, design: appState.currentTheme.fontDesign, weight: .bold))
                        .foregroundStyle(appState.currentTheme.accentColor)

                    Text("Great work 🎉")
                        .font(.system(.callout, design: appState.currentTheme.fontDesign))
                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.8))

                    Button(action: {
                        appState.resetAll()
                        dismissedAllDone = false
                    }) {
                        Text("Start Over")
                            .font(.system(.callout, design: appState.currentTheme.fontDesign, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(appState.currentTheme.accentColor))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)

                    Button(action: { dismissedAllDone = true }) {
                        Text("Dismiss")
                            .font(.system(.callout, design: appState.currentTheme.fontDesign))
                            .foregroundStyle(appState.currentTheme.accentColor.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    appState.currentTheme.backgroundGradient.first?
                        .opacity(0.95) ?? Color.black.opacity(0.95)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.spring(duration: 0.4), value: showAllDoneOverlay)
        .onChange(of: allDone) { _, newValue in
            if newValue { dismissedAllDone = false }
        }
        .frame(width: 320, height: 480)
    }
}

private struct EmptyTaskStateView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 40))
                .foregroundStyle(appState.currentTheme.accentColor.opacity(0.3))

            Text("Paste your plan to get started")
                .font(.system(.callout, design: appState.currentTheme.fontDesign, weight: .medium))
                .foregroundStyle(appState.currentTheme.accentColor.opacity(0.4))
                .multilineTextAlignment(.center)

            Text("Each line becomes a task.")
                .font(.system(.caption, design: appState.currentTheme.fontDesign))
                .foregroundStyle(appState.currentTheme.accentColor.opacity(0.3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
}
