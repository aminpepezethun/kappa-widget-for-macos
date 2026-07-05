import SwiftUI

struct TimerView: View {
    @Environment(AppState.self) private var appState
    @Environment(TimerState.self) private var timerState

    private var timeString: String {
        let minutes = timerState.secondsRemaining / 60
        let seconds = timerState.secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var zenElapsedString: String {
        let minutes = timerState.zenElapsedSeconds / 60
        let seconds = timerState.zenElapsedSeconds % 60
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
        VStack(spacing: 6) {
            // Zen toggle button above the ring
            Button(action: {
                if timerState.isZenMode {
                    timerState.zenDone()
                } else {
                    timerState.zenStart()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: timerState.isZenMode ? "infinity.circle.fill" : "infinity.circle")
                        .font(.system(size: 13))
                    Text(timerState.isZenMode ? "Zen" : "Zen")
                        .font(.system(.caption2, design: appState.currentTheme.fontDesign))
                }
                .foregroundStyle(timerState.isZenMode
                    ? appState.currentTheme.accentColor
                    : appState.currentTheme.accentColor.opacity(0.45))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(timerState.isZenMode ? "Exit zen mode" : "Enter zen mode")

            // Progress ring
            ZStack {
                // Track ring
                Circle()
                    .stroke(
                        appState.currentTheme.accentColor.opacity(0.2),
                        lineWidth: 10
                    )

                if timerState.isZenMode {
                    // Zen: pulsing full-circle arc
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(
                            appState.currentTheme.accentColor.opacity(timerState.isRunning ? 0.8 : 0.4),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: timerState.zenElapsedSeconds
                        )
                } else {
                    // Normal: progress arc
                    Circle()
                        .trim(from: 0, to: timerState.progress)
                        .stroke(
                            appState.currentTheme.accentColor,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: timerState.progress)
                }

                // Center content
                VStack(spacing: 4) {
                    if timerState.isZenMode {
                        Text("∞")
                            .font(.system(size: 44, weight: .bold,
                                          design: appState.currentTheme.fontDesign))
                            .foregroundStyle(appState.currentTheme.accentColor)

                        Text(zenElapsedString)
                            .font(.system(.footnote, design: appState.currentTheme.fontDesign))
                            .foregroundStyle(appState.currentTheme.accentColor.opacity(0.85))
                            .monospacedDigit()
                    } else {
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
            }
            .frame(width: 160, height: 160)

            if timerState.isZenMode {
                // Zen controls — just a Done button
                Button(action: { timerState.zenDone() }) {
                    Text("Done")
                        .font(.system(.callout, design: appState.currentTheme.fontDesign, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(appState.currentTheme.accentColor)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("End zen session")
            } else {
                // Normal controls — play/pause centered, reset left, skip right
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
        }
        .padding(.vertical, 8)
    }
}
