import XCTest

/// End-to-end UI tests for OhWell.
///
/// Run via:
///   make ui-test          (builds .app, runs all tests)
///   make ui-test-filter T=testAddTask
///
/// Requirements:
///   - App must be built as .app bundle first (make ui-test handles this)
///   - Tests interact with the live popover via Accessibility APIs
final class OhWellUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        // Give the status-bar app a moment to appear
        sleep(1)
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - Popover

    func testPopoverOpensOnStatusItemClick() throws {
        // The popover window should appear after launch
        let popover = app.windows.firstMatch
        XCTAssertTrue(popover.waitForExistence(timeout: 3))
    }

    // MARK: - Task input

    func testAddTaskAppearsInList() throws {
        openPopoverIfNeeded()

        // Tap "Add Plan" button
        let addPlanBtn = app.buttons["Add Plan"]
        XCTAssertTrue(addPlanBtn.waitForExistence(timeout: 3))
        addPlanBtn.click()

        // Fill task name
        let taskField = app.textFields["Task name"]
        XCTAssertTrue(taskField.waitForExistence(timeout: 2))
        taskField.click()
        taskField.typeText("Write UI tests")

        // Add Task
        app.buttons["Add Task"].click()

        // Save
        let saveBtn = app.buttons["Save Tasks"]
        XCTAssertTrue(saveBtn.waitForExistence(timeout: 2))
        saveBtn.click()

        // Task title should appear in the list
        XCTAssertTrue(app.staticTexts["Write UI tests"].waitForExistence(timeout: 2))
    }

    func testCompleteTaskShowsCheckmark() throws {
        addOneTask(title: "Test complete")
        openPopoverIfNeeded()

        // Tap the checkbox (circle button next to the task)
        let taskRow = app.staticTexts["Test complete"]
        XCTAssertTrue(taskRow.waitForExistence(timeout: 2))

        // The checkbox is a sibling element — click the checkmark circle
        let checkbox = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'circle'")).firstMatch
        XCTAssertTrue(checkbox.waitForExistence(timeout: 2))
        checkbox.click()

        // Task text should be struck through (dimmed) — verify it still exists
        XCTAssertTrue(app.staticTexts["Test complete"].exists)
    }

    // MARK: - Theme picker

    func testThemePickerButtonsExist() throws {
        openPopoverIfNeeded()
        // Theme circles are in the header — at least one should exist
        let circles = app.buttons.matching(NSPredicate(format: "value != nil"))
        XCTAssertGreaterThan(circles.count, 0)
    }

    // MARK: - Settings sheet

    func testSettingsSheetOpens() throws {
        openPopoverIfNeeded()
        let gear = app.buttons["Settings"]
        XCTAssertTrue(gear.waitForExistence(timeout: 2))
        gear.click()

        // Settings sheet should contain the Done button
        let done = app.buttons["Done"]
        XCTAssertTrue(done.waitForExistence(timeout: 3))
        done.click()
    }

    // MARK: - Timer

    func testTimerStartButtonExists() throws {
        openPopoverIfNeeded()
        // Play button in TimerView
        let play = app.buttons.matching(NSPredicate(format: "label CONTAINS 'play' OR label CONTAINS 'pause'")).firstMatch
        XCTAssertTrue(play.waitForExistence(timeout: 2))
    }

    // MARK: - Helpers

    private func openPopoverIfNeeded() {
        // If no window visible, click the status bar item to open
        if !app.windows.firstMatch.exists {
            let statusItem = app.statusItems.firstMatch
            if statusItem.exists { statusItem.click() }
        }
    }

    private func addOneTask(title: String) {
        openPopoverIfNeeded()
        let addPlanBtn = app.buttons["Add Plan"]
        guard addPlanBtn.waitForExistence(timeout: 2) else { return }
        addPlanBtn.click()

        let taskField = app.textFields["Task name"]
        guard taskField.waitForExistence(timeout: 2) else { return }
        taskField.click()
        taskField.typeText(title)

        app.buttons["Add Task"].click()
        app.buttons["Save Tasks"].click()
    }
}
