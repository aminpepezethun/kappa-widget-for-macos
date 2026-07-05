import SwiftUI

struct TaskRowView: View {
    @Environment(AppState.self) private var appState
    let task: TaskItem
    let isActive: Bool

    @State private var isHovered = false
    @State private var editingTime = false
    @State private var editingTask = false
    @State private var draftMinutes: Int = 25

    // Hold-to-complete
    @GestureState private var isLongPressing = false
    @State private var holdProgress: CGFloat = 0
    @State private var longPressHandled = false

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
                .iconBouncer(style: appState.currentTheme.iconAnimationStyle,
                             isActive: isActive && !task.isCompleted)

            // Title + optional description
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(.body, design: appState.currentTheme.fontDesign))
                    .foregroundStyle(task.isCompleted
                        ? appState.currentTheme.accentColor.opacity(0.5)
                        : appState.currentTheme.accentColor)
                    .strikethrough(task.isCompleted,
                                   color: appState.currentTheme.accentColor.opacity(0.5))
                    .lineLimit(2)

                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.system(.caption2, design: appState.currentTheme.fontDesign))
                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.5))
                        .lineLimit(2)
                }
            }
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
                if !isOpen {
                    appState.updateTime(taskId: task.id,
                                        minutes: draftMinutes == 0 ? nil : draftMinutes)
                }
            }

            // Edit button — visible on hover OR while the popover is open
            // (Fix: editingTask keeps it pinned while the user is editing)
            if !task.isCompleted && (isHovered || editingTask) {
                Button(action: { editingTask = true }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.5))
                }
                .buttonStyle(.plain)
                .frame(width: 20, height: 20)
                .popover(isPresented: $editingTask, arrowEdge: .trailing) {
                    TaskEditorView(
                        task: task,
                        accentColor: appState.currentTheme.accentColor,
                        fontDesign: appState.currentTheme.fontDesign,
                        onSave: { newTitle, newDesc in
                            appState.updateTask(id: task.id,
                                                title: newTitle,
                                                description: newDesc)
                        }
                    )
                }
            }

            // Checkbox — one-click OR hold to fill the ring
            checkboxView
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
            withAnimation(.easeInOut(duration: 0.15)) { isHovered = hovering }
        }
        .animation(.easeInOut(duration: 0.2), value: isActive)
        .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
        // Animate the ring fill while long-pressing
        .onChange(of: isLongPressing) { _, pressing in
            if pressing && !task.isCompleted {
                withAnimation(.linear(duration: 1.5)) { holdProgress = 1.0 }
            } else {
                withAnimation(.easeOut(duration: 0.25)) { holdProgress = 0 }
            }
        }
    }

    // MARK: - Checkbox + hold ring

    private var checkboxView: some View {
        let longPress = LongPressGesture(minimumDuration: 1.5)
            .updating($isLongPressing) { value, state, _ in state = value }
            .onEnded { _ in
                longPressHandled = true
                if !task.isCompleted { appState.complete(task: task.id) }
                holdProgress = 0
            }

        return ZStack {
            // Ring track (only visible while pressing)
            if holdProgress > 0 && !task.isCompleted {
                Circle()
                    .stroke(appState.currentTheme.accentColor.opacity(0.2), lineWidth: 2.5)
                    .frame(width: 24, height: 24)
                Circle()
                    .trim(from: 0, to: holdProgress)
                    .stroke(appState.currentTheme.accentColor,
                            style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 24, height: 24)
            }

            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20))
                .foregroundStyle(task.isCompleted
                    ? appState.currentTheme.completionColor
                    : appState.currentTheme.accentColor.opacity(0.5))
        }
        .frame(width: 24, height: 24)
        .contentShape(Circle())
        // One-click: tap to complete/uncomplete immediately
        .onTapGesture {
            guard !longPressHandled else { longPressHandled = false; return }
            if task.isCompleted {
                appState.uncomplete(task: task.id)
            } else {
                appState.complete(task: task.id)
            }
        }
        // Hold 1.5s: ring fills up, then auto-completes
        .simultaneousGesture(longPress)
    }

    // MARK: - Helpers

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

// MARK: - Task editor popover

private struct TaskEditorView: View {
    let task: TaskItem
    let accentColor: Color
    let fontDesign: Font.Design
    let onSave: (String, String) -> Void

    @State private var draftTitle: String
    @State private var draftDescription: String
    @Environment(\.dismiss) private var dismiss

    init(task: TaskItem, accentColor: Color, fontDesign: Font.Design,
         onSave: @escaping (String, String) -> Void) {
        self.task = task
        self.accentColor = accentColor
        self.fontDesign = fontDesign
        self.onSave = onSave
        _draftTitle = State(initialValue: task.title)
        _draftDescription = State(initialValue: task.description)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Edit Task")
                .font(.system(.callout, design: fontDesign, weight: .semibold))
                .foregroundStyle(accentColor)

            TextField("Title", text: $draftTitle)
                .font(.system(.body, design: fontDesign))
                .textFieldStyle(.roundedBorder)

            TextField("Description (optional)", text: $draftDescription)
                .font(.system(.callout, design: fontDesign))
                .textFieldStyle(.roundedBorder)

            HStack {
                Button("Cancel") { dismiss() }
                    .font(.system(.callout, design: fontDesign))
                    .foregroundStyle(accentColor.opacity(0.6))
                    .buttonStyle(.plain)

                Spacer()

                Button("Save") {
                    let t = draftTitle.trimmingCharacters(in: .whitespaces)
                    guard !t.isEmpty else { return }
                    onSave(t, draftDescription.trimmingCharacters(in: .whitespaces))
                    dismiss()
                }
                .font(.system(.callout, design: fontDesign, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(draftTitle.trimmingCharacters(in: .whitespaces).isEmpty
                        ? accentColor.opacity(0.3)
                        : accentColor)
                )
                .buttonStyle(.plain)
                .disabled(draftTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(14)
        .frame(width: 260)
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

            Button("Clear") { draftMinutes = 0 }
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
