import Foundation

enum TimerPhase: Sendable {
    case work
    case shortBreak
    case longBreak
}

@Observable @MainActor
final class TimerState {
    // Durations (in seconds)
    var workDuration: Int = 25 * 60
    var shortBreakDuration: Int = 5 * 60
    var longBreakDuration: Int = 15 * 60
    var sessionsBeforeLongBreak: Int = 4

    // Runtime state
    var currentPhase: TimerPhase = .work
    var secondsRemaining: Int = 25 * 60
    var isRunning: Bool = false
    var completedSessions: Int = 0

    private var timer: Timer?

    var progress: Double {
        let total = duration(for: currentPhase)
        guard total > 0 else { return 0 }
        return 1.0 - Double(secondsRemaining) / Double(total)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tick() }
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        secondsRemaining = duration(for: currentPhase)
    }

    func tick() {
        guard isRunning else { return }
        if secondsRemaining > 0 {
            secondsRemaining -= 1
        } else {
            advancePhase()
        }
    }

    // MARK: - Private

    private func duration(for phase: TimerPhase) -> Int {
        switch phase {
        case .work:       return workDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak:  return longBreakDuration
        }
    }

    private func advancePhase() {
        pause()
        switch currentPhase {
        case .work:
            completedSessions += 1
            if completedSessions % sessionsBeforeLongBreak == 0 {
                currentPhase = .longBreak
                secondsRemaining = longBreakDuration
            } else {
                currentPhase = .shortBreak
                secondsRemaining = shortBreakDuration
            }
        case .shortBreak, .longBreak:
            currentPhase = .work
            secondsRemaining = workDuration
        }
    }
}
