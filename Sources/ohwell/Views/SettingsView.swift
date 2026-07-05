import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(HistoryState.self) private var historyState
    @Environment(AudioManager.self) private var audioManager
    @Environment(TimerState.self) private var timerState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header: tab bar + Done button
            HStack(spacing: 4) {
                tabButton(title: "History", icon: "clock.arrow.circlepath", index: 0)
                tabButton(title: "Sound",   icon: "waveform",              index: 1)
                tabButton(title: "Timer",   icon: "timer",                 index: 2)

                Spacer()

                Button("Done") { dismiss() }
                    .font(.system(.callout, weight: .medium))
                    .foregroundStyle(appState.currentTheme.accentColor)
                    .buttonStyle(.plain)
                    .padding(.trailing, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)

            Divider()

            // Content
            Group {
                switch selectedTab {
                case 0:
                    HistoryView()
                case 1:
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ambient Sound")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        SoundPickerView()
                            .padding(.horizontal, 8)
                        Spacer()
                    }
                default:
                    TimerSettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 380, height: 440)
    }

    private func tabButton(title: String, icon: String, index: Int) -> some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.15)) { selectedTab = index } }) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(.system(.callout))
            }
            .fontWeight(selectedTab == index ? .semibold : .regular)
            .foregroundStyle(selectedTab == index ? .primary : .secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                selectedTab == index
                    ? RoundedRectangle(cornerRadius: 7).fill(Color.secondary.opacity(0.12))
                    : nil
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Timer settings

private struct TimerSettingsView: View {
    @Environment(TimerState.self) private var timerState
    @Environment(AppState.self) private var appState

    // Local minute drafts (TimerState stores seconds internally)
    @State private var workMinutes: Int = 25
    @State private var shortBreakMinutes: Int = 5
    @State private var longBreakMinutes: Int = 15

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Timer Durations")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

            Divider().padding(.horizontal, 16)

            durationRow(label: "Focus", systemImage: "brain.head.profile",
                        value: $workMinutes)
            durationRow(label: "Short break", systemImage: "cup.and.saucer",
                        value: $shortBreakMinutes)
            durationRow(label: "Long break", systemImage: "figure.walk",
                        value: $longBreakMinutes)

            Spacer()

            // Apply button
            Button(action: applyChanges) {
                Text("Apply")
                    .font(.system(.callout, design: appState.currentTheme.fontDesign, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(appState.currentTheme.accentColor))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 16)
        }
        .onAppear {
            workMinutes       = timerState.workDuration / 60
            shortBreakMinutes = timerState.shortBreakDuration / 60
            longBreakMinutes  = timerState.longBreakDuration / 60
        }
    }

    private func durationRow(label: String, systemImage: String,
                              value: Binding<Int>) -> some View {
        HStack {
            Image(systemName: systemImage)
                .font(.system(size: 14))
                .foregroundStyle(appState.currentTheme.accentColor.opacity(0.7))
                .frame(width: 22)

            Text(label)
                .font(.system(.body, design: appState.currentTheme.fontDesign))
                .foregroundStyle(appState.currentTheme.accentColor)

            Spacer()

            Stepper(value: value, in: 1...60) {
                Text("\(value.wrappedValue) min")
                    .font(.system(.body, design: appState.currentTheme.fontDesign))
                    .foregroundStyle(appState.currentTheme.accentColor)
                    .monospacedDigit()
                    .frame(width: 54, alignment: .trailing)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func applyChanges() {
        timerState.workDuration       = workMinutes * 60
        timerState.shortBreakDuration = shortBreakMinutes * 60
        timerState.longBreakDuration  = longBreakMinutes * 60
        // Reset the current phase so the ring reflects the new duration immediately
        timerState.reset()
    }
}
