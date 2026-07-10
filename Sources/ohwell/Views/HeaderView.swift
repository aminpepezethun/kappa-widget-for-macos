import SwiftUI

struct HeaderView: View {
    @Environment(AppState.self) private var appState
    @Environment(HistoryState.self) private var historyState

    var body: some View {
        HStack(spacing: 8) {
            Text("OhWell")
                .font(.system(.headline, design: appState.currentTheme.fontDesign, weight: .semibold))
                .foregroundStyle(appState.currentTheme.accentColor)

            Spacer()

            // Session disk button
            Button(action: {
                historyState.refresh()
                appState.showSessionDisk = true
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "opticaldisc")
                        .font(.system(size: 14))
                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.7))

                    if !historyState.sessions.isEmpty {
                        Text("\(min(historyState.sessions.count, 99))")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 3)
                            .padding(.vertical, 1.5)
                            .background(Capsule().fill(appState.currentTheme.accentColor))
                            .offset(x: 7, y: -5)
                    }
                }
            }
            .buttonStyle(.plain)
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
            .help("Sessions")

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
            Button(action: { appState.showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 14))
                    .foregroundStyle(appState.currentTheme.accentColor.opacity(0.7))
            }
            .buttonStyle(.plain)
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
            .help("Settings")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Session disk popover

struct SessionDiskView: View {
    @Environment(AppState.self) private var appState
    @Environment(HistoryState.self) private var historyState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Sessions")
                    .font(.system(.callout, design: appState.currentTheme.fontDesign, weight: .semibold))
                    .foregroundStyle(appState.currentTheme.accentColor)
                Spacer()
                Button("New Plan") {
                    appState.setTasks([], planText: "")
                    appState.showSessionDisk = false
                }
                .font(.system(.caption, design: appState.currentTheme.fontDesign, weight: .medium))
                .foregroundStyle(appState.currentTheme.accentColor)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider()

            if historyState.sessions.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "opticaldisc")
                        .font(.system(size: 24))
                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.3))
                    Text("No saved sessions yet")
                        .font(.system(.caption, design: appState.currentTheme.fontDesign))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                // ponytail: plain VStack — no NSScrollView in popover (crashes FirstResponderObserver)
                VStack(spacing: 0) {
                    ForEach(historyState.sessions.prefix(5)) { session in
                        Button(action: {
                            historyState.restore(session: session, into: appState)
                            appState.showSessionDisk = false
                        }) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(session.color)
                                    .frame(width: 8, height: 8)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(session.sessionName)
                                        .font(.system(.callout, design: appState.currentTheme.fontDesign))
                                        .foregroundStyle(appState.currentTheme.accentColor)
                                        .lineLimit(1)
                                    Text(session.savedAt, format: .dateTime.month().day().hour().minute())
                                        .font(.system(.caption2, design: appState.currentTheme.fontDesign))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(session.completedCount)/\(session.totalTasks)")
                                    .font(.system(.caption2, design: appState.currentTheme.fontDesign))
                                    .foregroundStyle(session.color.opacity(0.8))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(session.color.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .padding(.leading, 14)
                    }
                }
            }
        }
        .onAppear { historyState.refresh() }
    }
}
