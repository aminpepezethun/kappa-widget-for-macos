import SwiftUI

struct SoundPickerView: View {
    @Environment(AudioManager.self) private var audioManager
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                ForEach(Soundscape.allCases, id: \.rawValue) { sound in
                    Button(action: {
                        if audioManager.currentSoundscape == sound {
                            audioManager.stop()
                        } else {
                            audioManager.play(sound)
                        }
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: sound.icon)
                                .font(.system(size: 20))
                            Text(sound.label)
                                .font(.system(size: 10))
                        }
                        .frame(width: 64, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(audioManager.currentSoundscape == sound
                                    ? appState.currentTheme.accentColor.opacity(0.18)
                                    : Color.secondary.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(audioManager.currentSoundscape == sound
                                    ? appState.currentTheme.accentColor
                                    : Color.clear, lineWidth: 1.5)
                        )
                        .foregroundStyle(audioManager.currentSoundscape == sound
                            ? appState.currentTheme.accentColor
                            : .secondary)
                    }
                    .buttonStyle(.plain)
                }
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
    }
}
