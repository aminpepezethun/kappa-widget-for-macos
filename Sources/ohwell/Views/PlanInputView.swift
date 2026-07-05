import SwiftUI

struct PlanInputView: View {
    @Environment(AppState.self) private var appState
    @State private var planText: String = ""
    @State private var showingInput: Bool = false

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
            .background(
                Capsule()
                    .fill(appState.currentTheme.accentColor.opacity(0.12))
            )
        }
        .buttonStyle(.plain)
        .padding(.vertical, 8)
    }

    // MARK: - Input Panel

    private var inputPanel: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Text("Paste your plan")
                    .font(.system(.callout, design: appState.currentTheme.fontDesign, weight: .medium))
                    .foregroundStyle(appState.currentTheme.accentColor)
                Spacer()
                Button(action: { showingInput = false; planText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(appState.currentTheme.accentColor.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)

            // TextEditor
            TextEditor(text: $planText)
                .font(.system(.body, design: appState.currentTheme.fontDesign))
                .foregroundStyle(appState.currentTheme.accentColor)
                .scrollContentBackground(.hidden)
                .background(appState.currentTheme.accentColor.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(height: 100)
                .padding(.horizontal, 12)

            // Split button
            Button(action: splitIntoTasks) {
                HStack(spacing: 6) {
                    Image(systemName: "list.bullet")
                    Text("Split into Tasks")
                        .font(.system(.callout, design: appState.currentTheme.fontDesign, weight: .medium))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(planText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                              ? appState.currentTheme.accentColor.opacity(0.3)
                              : appState.currentTheme.accentColor)
                )
            }
            .buttonStyle(.plain)
            .disabled(planText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.bottom, 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(appState.currentTheme.accentColor.opacity(0.05))
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    // MARK: - Action

    private func splitIntoTasks() {
        let icons = appState.currentTheme.taskIcons
        let tasks = PlanParser.parse(text: planText, icons: icons)
        guard !tasks.isEmpty else { return }
        appState.setTasks(tasks, planText: planText)
        showingInput = false
        planText = ""
    }
}
