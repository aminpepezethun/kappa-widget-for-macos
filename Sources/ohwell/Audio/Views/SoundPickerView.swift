import SwiftUI
import AppKit

struct SoundPickerView: View {
    @Environment(AudioManager.self) private var audioManager
    @Environment(AppState.self) private var appState

    // ponytail: allCases minus .custom — shown separately via import button
    private var builtInSounds: [Soundscape] {
        Soundscape.allCases.filter { $0 != .custom }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Built-in soundscape grid
            HStack(spacing: 10) {
                ForEach(builtInSounds, id: \.rawValue) { sound in
                    soundButton(sound)
                }

                // Custom slot: import button or active custom tile
                customButton
            }

            // Error message from last import attempt
            if let err = audioManager.importError {
                Text(err)
                    .font(.system(.caption2))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 8)
                    .transition(.opacity)
            }

            if audioManager.currentSoundscape != .off {
                HStack(spacing: 8) {
                    Image(systemName: "speaker")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Slider(
                        value: Binding(
                            get: { Double(audioManager.volume) },
                            set: { audioManager.setVolume(Float($0)) }
                        ),
                        in: 0...1
                    )
                    Image(systemName: "speaker.wave.3")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.2), value: audioManager.currentSoundscape)
        .animation(.easeInOut(duration: 0.2), value: audioManager.importError)
    }

    // MARK: - Subviews

    private func soundButton(_ sound: Soundscape) -> some View {
        Button(action: {
            if audioManager.currentSoundscape == sound {
                audioManager.stop()
            } else {
                audioManager.play(sound)
            }
        }) {
            soundTile(icon: sound.icon, label: sound.label,
                      isActive: audioManager.currentSoundscape == sound)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var customButton: some View {
        let isActive = audioManager.currentSoundscape == .custom
        if audioManager.hasCustomSound {
            // Custom file loaded — show as a normal tile + tap to play/stop
            Button(action: {
                if isActive { audioManager.stop() } else { audioManager.play(.custom) }
            }) {
                soundTile(icon: Soundscape.custom.icon,
                          label: Soundscape.custom.label,
                          isActive: isActive)
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button("Replace…") { openImportPanel() }
            }
        } else {
            // No custom file yet — show an "add" button
            Button(action: { openImportPanel() }) {
                VStack(spacing: 6) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20))
                    Text("Import")
                        .font(.system(size: 10))
                }
                .frame(width: 64, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.08))
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4]))
                )
                .foregroundStyle(appState.currentTheme.accentColor.opacity(0.6))
            }
            .buttonStyle(.plain)
            .help("Import audio file (max 10 MB)")
        }
    }

    private func soundTile(icon: String, label: String, isActive: Bool) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
            Text(label)
                .font(.system(size: 10))
        }
        .frame(width: 64, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isActive
                    ? appState.currentTheme.accentColor.opacity(0.18)
                    : Color.secondary.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isActive ? appState.currentTheme.accentColor : Color.clear,
                        lineWidth: 1.5)
        )
        .foregroundStyle(isActive ? appState.currentTheme.accentColor : .secondary)
    }

    // MARK: - Import

    private func openImportPanel() {
        let panel = NSOpenPanel()
        panel.title = "Choose Audio File"
        panel.message = "Select an MP3, M4A, AAC, or WAV file (max 10 MB)"
        panel.allowedContentTypes = [.mp3, .mpeg4Audio, .aiff, .wav]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        guard panel.runModal() == .OK, let url = panel.url else { return }
        audioManager.importCustomAudio(from: url)
    }
}
