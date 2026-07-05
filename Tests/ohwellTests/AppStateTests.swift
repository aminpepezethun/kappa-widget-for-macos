import Foundation
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

    // MARK: - appendTasks (Phase E bug fix)

    @Test func appendTasksAddsToExistingList() {
        let state = AppState()
        state.setTasks([TaskItem(title: "A")])
        state.appendTasks([TaskItem(title: "B"), TaskItem(title: "C")])
        #expect(state.tasks.count == 3)
    }

    @Test func appendTasksPreservesCompletedItems() {
        let state = AppState()
        let a = TaskItem(title: "A")
        state.setTasks([a])
        state.complete(task: a.id)
        state.appendTasks([TaskItem(title: "B")])
        #expect(state.tasks[0].isCompleted)   // A still done
        #expect(!state.tasks[1].isCompleted)  // B is new
    }

    @Test func appendTasksUpdatesActiveIndex() {
        let state = AppState()
        let a = TaskItem(title: "A")
        state.setTasks([a])
        state.complete(task: a.id)
        // All done before append — activeTaskIndex should be nil
        #expect(state.activeTaskIndex == nil)
        state.appendTasks([TaskItem(title: "B")])
        // B is now the first incomplete task
        #expect(state.activeTaskIndex == 1)
    }

    // MARK: - updateTime (Phase E editable time)

    @Test func updateTimeSetsEstimatedMinutes() {
        let state = AppState()
        let task = TaskItem(title: "A")
        state.setTasks([task])
        state.updateTime(taskId: task.id, minutes: 30)
        #expect(state.tasks[0].estimatedMinutes == 30)
    }

    @Test func updateTimeClearsEstimateWhenNil() {
        let state = AppState()
        let task = TaskItem(title: "A", estimatedMinutes: 20)
        state.setTasks([task])
        state.updateTime(taskId: task.id, minutes: nil)
        #expect(state.tasks[0].estimatedMinutes == nil)
    }

    @Test func updateTimeIgnoresUnknownId() {
        let state = AppState()
        state.setTasks([TaskItem(title: "A")])
        // Should not crash or mutate anything
        state.updateTime(taskId: UUID(), minutes: 10)
        #expect(state.tasks[0].estimatedMinutes == nil)
    }

    // MARK: - updateTask (Phase F edit)

    @Test func updateTaskChangesTitleAndDescription() {
        let state = AppState()
        let task = TaskItem(title: "Old", description: "")
        state.setTasks([task])
        state.updateTask(id: task.id, title: "New", description: "Details")
        #expect(state.tasks[0].title == "New")
        #expect(state.tasks[0].description == "Details")
    }

    @Test func updateTaskIgnoresUnknownId() {
        let state = AppState()
        state.setTasks([TaskItem(title: "A")])
        state.updateTask(id: UUID(), title: "X", description: "Y")
        #expect(state.tasks[0].title == "A")
    }

    // MARK: - archiveCompleted (Phase F)

    @Test func archiveCompletedRemovesDoneTasks() {
        let state = AppState()
        let a = TaskItem(title: "A")
        let b = TaskItem(title: "B")
        state.setTasks([a, b])
        state.complete(task: a.id)
        state.archiveCompleted()
        #expect(state.tasks.count == 1)
        #expect(state.tasks[0].title == "B")
    }

    @Test func archiveCompletedDoesNothingWhenNoneComplete() {
        let state = AppState()
        state.setTasks([TaskItem(title: "A")])
        state.archiveCompleted()
        #expect(state.tasks.count == 1)
    }

    // MARK: - setTasks with empty list (session disk "New Plan")

    @Test func setTasksWithEmptyListClearsDashboard() {
        let state = AppState()
        state.setTasks([TaskItem(title: "A"), TaskItem(title: "B")])
        state.setTasks([], planText: "")
        #expect(state.tasks.isEmpty)
        #expect(state.activeTaskIndex == nil)
    }

    // MARK: - archiveCompleted

    @Test func archiveCompletedClearsCompletionTriggers() {
        let state = AppState()
        let a = TaskItem(title: "A")
        state.setTasks([a])
        state.complete(task: a.id)
        state.archiveCompleted()
        #expect(state.completionTriggers.isEmpty)
    }
}
