import SwiftUI

struct TaskRowView: View {
    @Environment(AppState.self) private var appState
    let task: TaskItem
    let isActive: Bool
    @State private var isHovered = false
    @State private var editingTime = false
    @State private var draftMinutes: Int = 25

    var body: some View {
        HStack(spacing: 10) {
            // Active-task accent bar
            RoundedRectangle(cornerRadius: 2)
                .fill(isActive && !task.isCompleted
                    ? appState.currentTheme.accentColor
                    : Color.clear)
                .frame(width: 3)
                .animation(.easeInOut(duration: 0.2), value: isActive)

            // Animated icon
            Image(systemName: task.iconSymbol)
                .font(.system(size: 16))
                .foregroundStyle(task.isCompleted
                    ? appState.currentTheme.completionColor
                    : appState.currentTheme.accentColor)
                .frame(width: 24, height: 24)
                .iconBouncer(style: appState.currentTheme.iconAnimationStyle, isActive: isActive && !task.isCompleted)

            // Task title
            Text(task.title)
                .font(.system(.body, design: appState.currentTheme.fontDesign))
                .foregroundStyle(task.isCompleted
                    ? appState.currentTheme.accentColor.opacity(0.5)
                    : appState.currentTheme.accentColor)
                .strikethrough(task.isCompleted, color: appState.currentTheme.accentColor.opacity(0.5))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Time badge — tap to edit estimatedMinutes
            Group {
                if let minutes = task.estimatedMinutes {
                    Button(action: {
                        draftMinutes = minutes
                        editingTime = true
                    }) {
                        Text(formatMinutes(minutes))
                            .font(.system(.caption2, design: appState.currentTheme.fontDesign))
                            .foregroundStyle(appState.currentTheme.accentColor.opacity(0.6))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(appState.currentTheme.accentColor.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: {
                        draftMinutes = 25
                        editingTime = true
                    }) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                            .foregroundStyle(appState.currentTheme.accentColor.opacity(0.3))
                    }
                    .buttonStyle(.plain)
                }
            }
            .popover(isPresented: $editingTime, arrowEdge: .bottom) {
                TimeEditorView(
                    draftMinutes: $draftMinutes,
                    accentColor: appState.currentTheme.accentColor,
                    fontDesign: appState.currentTheme.fontDesign
                )
            }
            .onChange(of: editingTime) { _, isOpen in
                // Commit when popover closes; nil clears the badge
                if !isOpen {
                    appState.updateTime(taskId: task.id, minutes: draftMinutes == 0 ? nil : draftMinutes)
                }
            }

            // Checkbox (tap to toggle)
            Button(action: {
                if task.isCompleted {
                    appState.uncomplete(task: task.id)
                } else {
                    appState.complete(task: task.id)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(task.isCompleted
                        ? appState.currentTheme.completionColor
                        : appState.currentTheme.accentColor.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isActive
                    ? appState.currentTheme.accentColor.opacity(0.12)
                    : isHovered
                        ? appState.currentTheme.accentColor.opacity(0.06)
                        : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isActive
                            ? appState.currentTheme.accentColor.opacity(0.4)
                            : Color.clear, lineWidth: 1)
                )
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let h = minutes / 60
            let m = minutes % 60
            return m == 0 ? "\(h)h" : "\(h)h\(m)m"
        }
    }
}

// MARK: - Time editor popover

private struct TimeEditorView: View {
    @Binding var draftMinutes: Int
    let accentColor: Color
    let fontDesign: Font.Design

    var body: some View {
        VStack(spacing: 10) {
            Text(draftMinutes == 0 ? "No estimate" : formatMinutes(draftMinutes))
                .font(.system(.headline, design: fontDesign, weight: .semibold))
                .foregroundStyle(accentColor)
                .monospacedDigit()

            Stepper(value: $draftMinutes, in: 0...480, step: 5) {
                EmptyView()
            }
            .labelsHidden()

            Button("Clear") {
                draftMinutes = 0
            }
            .font(.system(.caption, design: fontDesign))
            .foregroundStyle(accentColor.opacity(0.6))
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(width: 140)
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let h = minutes / 60
            let m = minutes % 60
            return m == 0 ? "\(h)h" : "\(h)h\(m)m"
        }
    }
}
