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
        VStack(spacing: 10) {
            // Progress ring
            ZStack {
                // Track ring
                Circle()
                    .stroke(
                        appState.currentTheme.accentColor.opacity(0.2),
                        lineWidth: 10
                    )

                // Progress arc
                Circle()
                    .trim(from: 0, to: timerState.progress)
                    .stroke(
                        appState.currentTheme.accentColor,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: timerState.progress)

                // Center content
                VStack(spacing: 4) {
                    Text(timeString)
                        .font(.system(size: 36, weight: .bold,
                                      design: appState.currentTheme.fontDesign))
                        .foregroundStyle(appState.currentTheme.accentColor)
                        .monospacedDigit()

                    Text(phaseLabel)
                        .font(.system(.footnote, design: appState.currentTheme.fontDesign))
                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.85))
                }
            }
            .frame(width: 160, height: 160)

            // Controls — play/pause centered, reset left, skip right
            ZStack {
                HStack {
                    Button(action: { timerState.reset() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18))
                            .foregroundStyle(appState.currentTheme.accentColor.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Reset timer")

                    Spacer()

                    Button(action: { timerState.skipPhase() }) {
                        Image(systemName: "forward.end.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(appState.currentTheme.accentColor.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Skip phase")
                }

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
                .accessibilityLabel(timerState.isRunning ? "Pause timer" : "Start timer")
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 8)
    }
}
