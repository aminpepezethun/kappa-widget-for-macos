import SwiftUI

struct TimerView: View {
    @Environment(AppState.self) private var appState
    @Environment(TimerState.self) private var timerState

    private var timeString: String {
        let minutes = timerState.secondsRemaining / 60
        let seconds = timerState.secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var phaseLabel: String {
        switch timerState.currentPhase {
        case .work:       return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak:  return "Long Break"
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Progress ring
            ZStack {
                // Track ring
                Circle()
                    .stroke(
                        appState.currentTheme.accentColor.opacity(0.2),
                        lineWidth: 8
                    )

                // Progress arc
                Circle()
                    .trim(from: 0, to: timerState.progress)
                    .stroke(
                        appState.currentTheme.accentColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timerState.progress)

                // Center content
                VStack(spacing: 4) {
                    Text(timeString)
                        .font(.system(.title, design: appState.currentTheme.fontDesign,
                                      weight: .semibold))
                        .foregroundStyle(appState.currentTheme.accentColor)
                        .monospacedDigit()

                    Text(phaseLabel)
                        .font(.system(.caption, design: appState.currentTheme.fontDesign))
                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.7))
                }
            }
            .frame(width: 140, height: 140)

            // Controls
            HStack(spacing: 24) {
                Button(action: { timerState.reset() }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18))
                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.8))
                }
                .buttonStyle(.plain)

                Button(action: {
                    if timerState.isRunning {
                        timerState.pause()
                    } else {
                        timerState.start()
                    }
                }) {
                    Image(systemName: timerState.isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(appState.currentTheme.accentColor)
                }
                .buttonStyle(.plain)

                // Spacer to balance reset button (visual symmetry)
                Color.clear
                    .frame(width: 18, height: 18)
            }
        }
        .padding(.vertical, 8)
    }
}
