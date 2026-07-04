import SwiftUI

struct HeaderView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: 8) {
            // App title
            Text("OhWell")
                .font(.system(.headline, design: appState.currentTheme.fontDesign, weight: .semibold))
                .foregroundStyle(appState.currentTheme.accentColor)

            Spacer()

            // Theme picker
            HStack(spacing: 6) {
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
                    .help(theme.name)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
