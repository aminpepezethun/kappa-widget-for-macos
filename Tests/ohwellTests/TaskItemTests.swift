import Testing
@testable import ohwell

@Suite("TaskItem")
struct TaskItemTests {

    @Test func defaultsToNotCompleted() {
        let item = TaskItem(title: "Foo")
        #expect(!item.isCompleted)
    }

    @Test func defaultEstimatedMinutesIsNil() {
        let item = TaskItem(title: "Foo")
        #expect(item.estimatedMinutes == nil)
    }

    @Test func defaultIconIsCircle() {
        let item = TaskItem(title: "Foo")
        #expect(item.iconSymbol == "circle")
    }

    @Test func uniqueIdsForDistinctItems() {
        let a = TaskItem(title: "A")
        let b = TaskItem(title: "B")
        #expect(a.id != b.id)
    }

    @Test func customFieldsRoundTrip() {
        let item = TaskItem(title: "Work", isCompleted: true,
                            estimatedMinutes: 25, iconSymbol: "star.fill")
        #expect(item.title == "Work")
        #expect(item.isCompleted)
        #expect(item.estimatedMinutes == 25)
        #expect(item.iconSymbol == "star.fill")
    }
}
