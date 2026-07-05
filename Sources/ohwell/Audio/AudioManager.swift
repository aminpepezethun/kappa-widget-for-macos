@preconcurrency import AVFoundation
import Foundation

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
    var importError: String? = nil

    /// Maximum allowed size for a user-imported audio file (10 MB).
    static let maxImportBytes: Int = 10 * 1024 * 1024

    /// Duration of each fade-in / fade-out ramp in seconds.
    var fadeDuration: TimeInterval = 2.5

    private var activePlayer: AVAudioPlayer?
    private var incomingPlayer: AVAudioPlayer?
    private var crossfadeTimer: Timer?
    private var currentURL: URL?

    // Destination for user-imported custom audio in Application Support.
    private static var customSoundURL: URL? {
        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask).first
        else { return nil }
        let dir = appSupport.appendingPathComponent("OhWell/Sounds", isDirectory: true)
        return dir.appendingPathComponent("custom.mp3")
    }

    // MARK: - Public

    func play(_ soundscape: Soundscape) {
        guard soundscape != .off else { stop(); return }
        currentSoundscape = soundscape

        let url: URL?
        if soundscape == .custom {
            url = Self.customSoundURL.flatMap { FileManager.default.fileExists(atPath: $0.path) ? $0 : nil }
        } else {
            url = Bundle.module.url(forResource: soundscape.rawValue, withExtension: "mp3")
        }

        guard let url else { return }
        currentURL = url
        tearDown(fade: false)
        startFresh(url: url)
    }

    func stop() {
        crossfadeTimer?.invalidate()
        crossfadeTimer = nil
        currentSoundscape = .off
        currentURL = nil

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

    /// Import a user-picked audio file. Validates size ≤ 10 MB, then copies
    /// to Application Support so it survives app restarts.
    /// Returns true on success; sets importError on failure.
    @discardableResult
    func importCustomAudio(from sourceURL: URL) -> Bool {
        importError = nil
        let fm = FileManager.default

        // Size check
        let attrs = try? fm.attributesOfItem(atPath: sourceURL.path)
        let bytes = (attrs?[.size] as? Int) ?? 0
        guard bytes > 0, bytes <= Self.maxImportBytes else {
            importError = bytes == 0
                ? "Could not read file."
                : "File exceeds 10 MB limit (\(bytes / 1024 / 1024) MB)."
            return false
        }

        guard let dest = Self.customSoundURL else {
            importError = "Cannot access Application Support."
            return false
        }

        do {
            try fm.createDirectory(at: dest.deletingLastPathComponent(),
                                   withIntermediateDirectories: true)
            if fm.fileExists(atPath: dest.path) {
                try fm.removeItem(at: dest)
            }
            try fm.copyItem(at: sourceURL, to: dest)
        } catch {
            importError = "Import failed: \(error.localizedDescription)"
            return false
        }

        play(.custom)
        return true
    }

    var hasCustomSound: Bool {
        guard let url = Self.customSoundURL else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }

    // MARK: - Private

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

    private func startFresh(url: URL) {
        guard let player = makePlayer(url: url) else { return }
        player.volume = 0
        player.setVolume(volume, fadeDuration: fadeDuration)
        activePlayer = player
        scheduleCrossfade(for: player, url: url)
    }

    private func scheduleCrossfade(for player: AVAudioPlayer, url: URL) {
        let delay = player.duration - fadeDuration
        guard delay > 0 else { return }

        crossfadeTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in self?.performCrossfade(outgoing: player, url: url) }
        }
    }

    private func performCrossfade(outgoing: AVAudioPlayer, url: URL) {
        outgoing.setVolume(0, fadeDuration: fadeDuration)

        guard let incoming = makePlayer(url: url) else { return }
        incoming.volume = 0
        incoming.setVolume(volume, fadeDuration: fadeDuration)
        incomingPlayer = incoming

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

    private func makePlayer(url: URL) -> AVAudioPlayer? {
        guard let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        player.numberOfLoops = 0
        player.prepareToPlay()
        player.play()
        return player
    }
}
