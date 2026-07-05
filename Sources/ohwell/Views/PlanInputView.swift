import SwiftUI

struct PlanInputView: View {
    @Environment(AppState.self) private var appState
    @State private var sessionName: String = ""
    @State private var taskName: String = ""
    @State private var taskDescription: String = ""
    @State private var taskMinutes: Int = 25
    @State private var draftTasks: [TaskItem] = []
    @State private var showingInput: Bool = false

    private var canAdd: Bool {
        !taskName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            if showingInput {
                inputPanel
            } else {
                addPlanButton
            }
        }
    }

    // MARK: - Add Plan Button

    private var addPlanButton: some View {
        Button(action: { showingInput = true }) {
            HStack(spacing: 6) {
                Image(systemName: "text.badge.plus")
                    .font(.system(size: 14))
                Text("Add Plan")
                    .font(.system(.callout, design: appState.currentTheme.fontDesign))
            }
            .foregroundStyle(appState.currentTheme.accentColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Capsule().fill(appState.currentTheme.accentColor.opacity(0.12)))
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
    }

    // MARK: - Input Panel

    private var inputPanel: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Text("New Session")
                    .font(.system(.callout, design: appState.currentTheme.fontDesign, weight: .medium))
                    .foregroundStyle(appState.currentTheme.accentColor)
                Spacer()
                Button(action: dismissPanel) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            // Session name
            TextField("Session name (optional)", text: $sessionName)
                .font(.system(.callout, design: appState.currentTheme.fontDesign))
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 12)

            // Task name + time stepper on the same row
            HStack(spacing: 6) {
                TextField("Task name", text: $taskName)
                    .font(.system(.body, design: appState.currentTheme.fontDesign))
                    .textFieldStyle(.roundedBorder)

                Stepper(value: $taskMinutes, in: 1...480, step: 5) {
                    Text("\(taskMinutes)m")
                        .font(.system(.caption, design: appState.currentTheme.fontDesign))
                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.7))
                        .frame(width: 34, alignment: .trailing)
                        .monospacedDigit()
                }
            }
            .padding(.horizontal, 12)

            // \ separator — visual divider between name and description
            HStack(spacing: 6) {
                Rectangle()
                    .fill(appState.currentTheme.accentColor.opacity(0.12))
                    .frame(height: 1)
                Text("\\")
                    .font(.system(.caption2, design: appState.currentTheme.fontDesign, weight: .medium))
                    .foregroundStyle(appState.currentTheme.accentColor.opacity(0.35))
                Rectangle()
                    .fill(appState.currentTheme.accentColor.opacity(0.12))
                    .frame(height: 1)
            }
            .padding(.horizontal, 12)

            // Description field
            TextField("Description (optional)", text: $taskDescription)
                .font(.system(.callout, design: appState.currentTheme.fontDesign))
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 12)

            // Add Task button
            Button(action: addDraftTask) {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 13))
                    Text("Add Task")
                        .font(.system(.callout, design: appState.currentTheme.fontDesign, weight: .medium))
                }
                .foregroundStyle(canAdd
                    ? appState.currentTheme.accentColor
                    : appState.currentTheme.accentColor.opacity(0.3))
            }
            .buttonStyle(.plain)
            .disabled(!canAdd)
            .padding(.bottom, draftTasks.isEmpty ? 8 : 4)

            // Draft list — shows tasks queued before committing
            if !draftTasks.isEmpty {
                Divider()
                    .background(appState.currentTheme.accentColor.opacity(0.15))
                    .padding(.horizontal, 12)

                VStack(spacing: 3) {
                    ForEach(draftTasks) { task in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(appState.currentTheme.accentColor.opacity(0.4))
                                .frame(width: 5, height: 5)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(task.title)
                                    .font(.system(.caption, design: appState.currentTheme.fontDesign))
                                    .foregroundStyle(appState.currentTheme.accentColor)
                                if !task.description.isEmpty {
                                    Text(task.description)
                                        .font(.system(.caption2, design: appState.currentTheme.fontDesign))
                                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.5))
                                }
                            }
                            Spacer()
                            if let m = task.estimatedMinutes {
                                Text("\(m)m")
                                    .font(.system(.caption2, design: appState.currentTheme.fontDesign))
                                    .foregroundStyle(appState.currentTheme.accentColor.opacity(0.45))
                            }
                            Button(action: { draftTasks.removeAll { $0.id == task.id } }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 9))
                                    .foregroundStyle(appState.currentTheme.accentColor.opacity(0.35))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 3)
                    }
                }

                // Commit buttons
                HStack(spacing: 8) {
                    if !appState.tasks.isEmpty {
                        Button(action: { commitDrafts(replacing: false) }) {
                            Text("Add to list")
                                .font(.system(.caption, design: appState.currentTheme.fontDesign, weight: .medium))
                                .foregroundStyle(appState.currentTheme.accentColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(appState.currentTheme.accentColor.opacity(0.12)))
                        }
                        .buttonStyle(.plain)
                    }

                    Button(action: { commitDrafts(replacing: true) }) {
                        Text(appState.tasks.isEmpty ? "Save Tasks" : "Replace")
                            .font(.system(.caption, design: appState.currentTheme.fontDesign, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(appState.currentTheme.accentColor))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 8)
            }
        }
        .background(RoundedRectangle(cornerRadius: 12).fill(appState.currentTheme.accentColor.opacity(0.05)))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    // MARK: - Actions

    private func addDraftTask() {
        let name = taskName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        let icons = appState.currentTheme.taskIcons
        let icon = icons.isEmpty ? "circle" : icons[draftTasks.count % icons.count]
        draftTasks.append(TaskItem(
            title: name,
            description: taskDescription.trimmingCharacters(in: .whitespaces),
            estimatedMinutes: taskMinutes,
            iconSymbol: icon
        ))
        taskName = ""
        taskDescription = ""
        taskMinutes = 25
    }

    private func commitDrafts(replacing: Bool) {
        guard !draftTasks.isEmpty else { return }
        let name = sessionName.trimmingCharacters(in: .whitespaces)
        if replacing {
            appState.setTasks(draftTasks,
                              planText: draftTasks.first?.title ?? "",
                              sessionName: name)
        } else {
            appState.appendTasks(draftTasks)
        }
        dismissPanel()
    }

    private func dismissPanel() {
        showingInput = false
        sessionName = ""
        taskName = ""
        taskDescription = ""
        taskMinutes = 25
        draftTasks = []
    }
}
