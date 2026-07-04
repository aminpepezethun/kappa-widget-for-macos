import Testing
@testable import ohwell

@Suite("AppState")
@MainActor
struct AppStateTests {

    @Test func setTasksPopulatesAndSetsActive() {
        let state = AppState()
        let tasks = [
            TaskItem(title: "A"),
            TaskItem(title: "B"),
        ]
        state.setTasks(tasks)
        #expect(state.tasks.count == 2)
        #expect(state.activeTaskIndex == 0)
    }

    @Test func completingTaskMarksItDone() {
        let state = AppState()
        let task = TaskItem(title: "A")
        state.setTasks([task])
        state.complete(task: task.id)
        #expect(state.tasks[0].isCompleted)
    }

    @Test func completingTaskAppendsCompletionTrigger() {
        let state = AppState()
        let task = TaskItem(title: "A")
        state.setTasks([task])
        state.complete(task: task.id)
        #expect(state.completionTriggers.count == 1)
        #expect(state.completionTriggers[0] == task.id)
    }

    @Test func completingTaskAdvancesActiveIndex() {
        let state = AppState()
        let a = TaskItem(title: "A")
        let b = TaskItem(title: "B")
        state.setTasks([a, b])
        state.complete(task: a.id)
        // A is done, B is next
        #expect(state.activeTaskIndex == 1)
    }

    @Test func completingLastTaskSetsActiveIndexNil() {
        let state = AppState()
        let task = TaskItem(title: "A")
        state.setTasks([task])
        state.complete(task: task.id)
        #expect(state.activeTaskIndex == nil)
    }

    @Test func resetAllClearsCompletionState() {
        let state = AppState()
        let task = TaskItem(title: "A")
        state.setTasks([task])
        state.complete(task: task.id)
        state.resetAll()
        #expect(!state.tasks[0].isCompleted)
        #expect(state.completionTriggers.isEmpty)
        #expect(state.activeTaskIndex == 0)
    }

    @Test func completedCountAccurate() {
        let state = AppState()
        let a = TaskItem(title: "A")
        let b = TaskItem(title: "B")
        state.setTasks([a, b])
        state.complete(task: a.id)
        #expect(state.completedCount == 1)
    }
}
