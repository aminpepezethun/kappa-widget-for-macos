import Testing
@testable import ohwell

@Suite("TimerState")
@MainActor
struct TimerStateTests {

    // MARK: - Initial state

    @Test func defaultsToWorkPhase() {
        let state = TimerState()
        #expect(state.currentPhase == .work)
    }

    @Test func defaultSecondsRemainingMatchesWorkDuration() {
        let state = TimerState()
        #expect(state.secondsRemaining == state.workDuration)
    }

    @Test func defaultIsNotRunning() {
        let state = TimerState()
        #expect(!state.isRunning)
    }

    @Test func defaultProgressIsZero() {
        let state = TimerState()
        #expect(state.progress == 0.0)
    }

    // MARK: - start / pause

    @Test func startSetsIsRunning() {
        let state = TimerState()
        state.start()
        #expect(state.isRunning)
        state.pause() // cleanup
    }

    @Test func pauseClearsIsRunning() {
        let state = TimerState()
        state.start()
        state.pause()
        #expect(!state.isRunning)
    }

    @Test func doubleStartIsIdempotent() {
        let state = TimerState()
        state.start()
        state.start()   // second call should be no-op
        #expect(state.isRunning)
        state.pause()
    }

    // MARK: - tick

    @Test func tickDecrementsSecondsRemaining() {
        let state = TimerState()
        state.start()
        let before = state.secondsRemaining
        state.tick()
        #expect(state.secondsRemaining == before - 1)
        state.pause()
    }

    @Test func tickDoesNothingWhenPaused() {
        let state = TimerState()
        // Not started — isRunning = false
        let before = state.secondsRemaining
        state.tick()
        #expect(state.secondsRemaining == before)
    }

    // MARK: - reset

    @Test func resetRestoresSecondsRemaining() {
        let state = TimerState()
        state.start()
        state.tick()
        state.tick()
        state.reset()
        #expect(state.secondsRemaining == state.workDuration)
    }

    @Test func resetStopsTimer() {
        let state = TimerState()
        state.start()
        state.reset()
        #expect(!state.isRunning)
    }

    // MARK: - progress

    @Test func progressIncreasesAfterTick() {
        let state = TimerState()
        state.start()
        state.tick()
        #expect(state.progress > 0.0)
        state.pause()
    }

    @Test func progressIsOneWhenExhausted() {
        let state = TimerState()
        state.start()
        // Exhaust work phase without triggering advancePhase (set secondsRemaining directly)
        state.secondsRemaining = 0
        // At 0 seconds, progress = 1 - 0/total = 1.0
        #expect(state.progress == 1.0)
        state.pause()
    }

    // MARK: - phase transitions

    @Test func workPhaseTransitionsToShortBreak() {
        let state = TimerState()
        state.start()
        state.secondsRemaining = 0
        state.tick()   // triggers advancePhase
        #expect(state.currentPhase == .shortBreak)
        #expect(state.secondsRemaining == state.shortBreakDuration)
    }

    @Test func shortBreakTransitionsBackToWork() {
        let state = TimerState()
        // Jump to short break
        state.start()
        state.secondsRemaining = 0
        state.tick()  // → shortBreak
        // Now exhaust short break
        state.start()
        state.secondsRemaining = 0
        state.tick()  // → work
        #expect(state.currentPhase == .work)
        #expect(state.secondsRemaining == state.workDuration)
    }

    @Test func fourthSessionTriggersLongBreak() {
        let state = TimerState()
        // Simulate 4 work completions
        for _ in 0..<4 {
            state.start()
            state.secondsRemaining = 0
            state.tick()   // work → break
            if state.currentPhase != .longBreak {
                // exhaust short break
                state.start()
                state.secondsRemaining = 0
                state.tick() // break → work
            }
        }
        // After 4th work session, should be in longBreak
        // completedSessions == 4, 4 % 4 == 0 → longBreak
        #expect(state.currentPhase == .longBreak)
        #expect(state.secondsRemaining == state.longBreakDuration)
    }

    // MARK: - completedSessions

    @Test func completedSessionsIncreasesOnWorkFinish() {
        let state = TimerState()
        state.start()
        state.secondsRemaining = 0
        state.tick()
        #expect(state.completedSessions == 1)
    }

    @Test func completedSessionsDoesNotIncreaseOnBreakFinish() {
        let state = TimerState()
        // Complete work → short break
        state.start()
        state.secondsRemaining = 0
        state.tick()
        let afterWork = state.completedSessions
        // Complete break → work
        state.start()
        state.secondsRemaining = 0
        state.tick()
        #expect(state.completedSessions == afterWork)
    }
}
