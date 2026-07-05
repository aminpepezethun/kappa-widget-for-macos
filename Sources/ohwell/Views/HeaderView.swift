import SwiftUI

struct HeaderView: View {
    @Environment(AppState.self) private var appState
    @State private var showSettings = false

    var body: some View {
        HStack(spacing: 8) {
            Text("OhWell")
                .font(.system(.headline, design: appState.currentTheme.fontDesign, weight: .semibold))
                .foregroundStyle(appState.currentTheme.accentColor)

            Spacer()

            // Theme picker
            HStack(spacing: 10) {
                ForEach(Array(appState.availableThemes.enumerated()), id: \.offset) { index, theme in
                    Button(action: {
                        appState.currentTheme = appState.availableThemes[index]
                    }) {
                        Circle()
                            .fill(theme.accentColor)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(appState.currentTheme.accentColor,
                                            lineWidth: theme.name == appState.currentTheme.name ? 2 : 0)
                                    .padding(-3)
                            )
                            .scaleEffect(theme.name == appState.currentTheme.name ? 1.2 : 1.0)
                            .animation(.spring(duration: 0.2), value: appState.currentTheme.name)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
                    .help(theme.name)
                }
            }

            // Settings
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 14))
                    .foregroundStyle(appState.currentTheme.accentColor.opacity(0.7))
            }
            .buttonStyle(.plain)
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
            .help("Settings")
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
