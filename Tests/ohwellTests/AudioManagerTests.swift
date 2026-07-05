import Foundation
import Testing
@testable import ohwell

@Suite("AudioManager")
@MainActor
struct AudioManagerTests {

    // MARK: - importCustomAudio size validation

    @Test func importRejectsFileOverLimit() throws {
        let manager = AudioManager()
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("oversized_\(UUID().uuidString).mp3")
        // Write 11 MB of zeros
        let data = Data(repeating: 0, count: 11 * 1024 * 1024)
        try data.write(to: tmp)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let result = manager.importCustomAudio(from: tmp)
        #expect(!result)
        #expect(manager.importError != nil)
    }

    @Test func importAcceptsFileUnderLimit() throws {
        let manager = AudioManager()
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("valid_\(UUID().uuidString).mp3")
        // Write 1 KB — well under 10 MB; not a real MP3 but size check passes
        let data = Data(repeating: 0, count: 1024)
        try data.write(to: tmp)
        defer { try? FileManager.default.removeItem(at: tmp) }

        // importCustomAudio copies the file; will fail to play (not real audio)
        // but the size validation + copy itself should succeed
        let result = manager.importCustomAudio(from: tmp)
        #expect(result)
        #expect(manager.importError == nil)
    }

    @Test func maxImportBytesIsTenMB() {
        #expect(AudioManager.maxImportBytes == 10 * 1024 * 1024)
    }
}
