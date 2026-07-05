@preconcurrency import AVFoundation

/// Plays ambient soundscapes with fade-in on start, crossfade between loops,
/// and fade-out on stop. Uses two AVAudioPlayer instances that overlap at loop
/// boundaries so there is never a silent gap.
///
/// Loop lifecycle:
///   Player A  ████████████████░░░   ← fades out last `fadeDuration` seconds
///   Player B              ░░░████████████████   ← fades in, then schedules its own crossfade
@Observable @MainActor
final class AudioManager {
    var currentSoundscape: Soundscape = .off
    var volume: Float = 0.5

    /// Duration of each fade-in / fade-out ramp in seconds.
    var fadeDuration: TimeInterval = 2.5

    private var activePlayer: AVAudioPlayer?
    private var incomingPlayer: AVAudioPlayer?
    private var crossfadeTimer: Timer?
    private var currentURL: URL?

    // MARK: - Public

    func play(_ soundscape: Soundscape) {
        guard soundscape != .off else { stop(); return }
        currentSoundscape = soundscape

        guard let url = Bundle.module.url(forResource: soundscape.rawValue, withExtension: "mp3") else {
            // File not yet present — no-op until MP3 is dropped into Resources/Sounds/
            return
        }
        currentURL = url
        tearDown(fade: false)
        startFresh(url: url)
    }

    func stop() {
        crossfadeTimer?.invalidate()
        crossfadeTimer = nil
        currentSoundscape = .off
        currentURL = nil

        // Fade both players out before stopping
        let fade = fadeDuration
        activePlayer?.setVolume(0, fadeDuration: fade)
        incomingPlayer?.setVolume(0, fadeDuration: fade)

        let a = activePlayer
        let b = incomingPlayer
        activePlayer = nil
        incomingPlayer = nil

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(fade + 0.1))
            a?.stop()
            b?.stop()
        }
    }

    func setVolume(_ newVolume: Float) {
        volume = max(0, min(1, newVolume))
        activePlayer?.volume = volume
        incomingPlayer?.volume = volume
    }

    // MARK: - Private

    /// Immediately halt all playback (no fade) and cancel any pending crossfade.
    private func tearDown(fade: Bool) {
        crossfadeTimer?.invalidate()
        crossfadeTimer = nil
        if fade {
            activePlayer?.setVolume(0, fadeDuration: fadeDuration)
            incomingPlayer?.setVolume(0, fadeDuration: fadeDuration)
        } else {
            activePlayer?.stop()
            incomingPlayer?.stop()
        }
        activePlayer = nil
        incomingPlayer = nil
    }

    /// Start the first player for a new sound, fading in from silence.
    private func startFresh(url: URL) {
        guard let player = makePlayer(url: url) else { return }
        player.volume = 0
        player.setVolume(volume, fadeDuration: fadeDuration)
        activePlayer = player
        scheduleCrossfade(for: player, url: url)
    }

    /// Schedule the crossfade timer so it fires `fadeDuration` seconds before
    /// the active player reaches the end of its file.
    private func scheduleCrossfade(for player: AVAudioPlayer, url: URL) {
        let delay = player.duration - fadeDuration
        guard delay > 0 else { return }

        crossfadeTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in self?.performCrossfade(outgoing: player, url: url) }
        }
    }

    /// Overlap two players: fade the outgoing one out, start the incoming one
    /// fading in, then promote incoming → active once the fade completes.
    private func performCrossfade(outgoing: AVAudioPlayer, url: URL) {
        // Fade out the current player over its last `fadeDuration` seconds
        outgoing.setVolume(0, fadeDuration: fadeDuration)

        // Start the replacement player from silence
        guard let incoming = makePlayer(url: url) else { return }
        incoming.volume = 0
        incoming.setVolume(volume, fadeDuration: fadeDuration)
        incomingPlayer = incoming

        // After the fade window, promote incoming → active and schedule its crossfade
        Timer.scheduledTimer(withTimeInterval: fadeDuration + 0.1, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                outgoing.stop()
                self.activePlayer = self.incomingPlayer
                self.incomingPlayer = nil
                if let url = self.currentURL, let active = self.activePlayer {
                    self.scheduleCrossfade(for: active, url: url)
                }
            }
        }
    }

    /// Create a player, prepare it, and begin playback immediately.
    private func makePlayer(url: URL) -> AVAudioPlayer? {
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        player.numberOfLoops = 0    // crossfade handles looping manually
        player.prepareToPlay()
        player.play()
        return player
    }
}
