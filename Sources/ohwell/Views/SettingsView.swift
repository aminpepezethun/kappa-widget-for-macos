import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(HistoryState.self) private var historyState
    @Environment(AudioManager.self) private var audioManager
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            HStack(spacing: 4) {
                tabButton(title: "History", icon: "clock.arrow.circlepath", index: 0)
                tabButton(title: "Sound", icon: "waveform", index: 1)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)

            Divider()

            // Content
            Group {
                if selectedTab == 0 {
                    HistoryView()
                } else {
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
