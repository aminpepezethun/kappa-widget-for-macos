import AVFoundation

@Observable @MainActor
final class AudioManager {
    var currentSoundscape: Soundscape = .off
    var volume: Float = 0.5
    private var player: AVAudioPlayer?

    func play(_ soundscape: Soundscape) {
        guard soundscape != .off else {
            stop()
            return
        }
        currentSoundscape = soundscape
        guard let url = Bundle.module.url(forResource: soundscape.rawValue, withExtension: "mp3") else {
            // Sound file not yet present — no-op until MP3s are added to Resources/Sounds/
            return
        }
        player?.stop()
        player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1   // loop forever
        player?.volume = volume
        player?.play()
    }

    func stop() {
        player?.stop()
        player = nil
        currentSoundscape = .off
    }

    func setVolume(_ newVolume: Float) {
        volume = max(0, min(1, newVolume))
        player?.volume = volume
    }
}
