import Testing
@testable import ohwell

@Suite("PlanParser")
struct PlanParserTests {

    // MARK: - Empty / blank input

    @Test func emptyTextReturnsEmpty() {
        #expect(PlanParser.parse(text: "").isEmpty)
    }

    @Test func blankLinesSkipped() {
        let result = PlanParser.parse(text: "\n\n  \n")
        #expect(result.isEmpty)
    }

    // MARK: - Bullet stripping

    @Test func stripsDashBullet() {
        let result = PlanParser.parse(text: "- Buy milk")
        #expect(result.count == 1)
        #expect(result[0].title == "Buy milk")
    }

    @Test func stripsStarBullet() {
        let result = PlanParser.parse(text: "* Buy milk")
        #expect(result[0].title == "Buy milk")
    }

    @Test func stripsDotBullet() {
        let result = PlanParser.parse(text: "• Buy milk")
        #expect(result[0].title == "Buy milk")
    }

    @Test func stripsNumberedBullet() {
        let result = PlanParser.parse(text: "1. Buy milk")
        #expect(result[0].title == "Buy milk")
    }

    @Test func stripsMultiDigitNumberedBullet() {
        let result = PlanParser.parse(text: "12. Buy milk")
        #expect(result[0].title == "Buy milk")
    }

    @Test func noBulletPassesThrough() {
        let result = PlanParser.parse(text: "Buy milk")
        #expect(result[0].title == "Buy milk")
    }

    // MARK: - Time hint extraction

    @Test func extractsTildeMinutes() {
        let result = PlanParser.parse(text: "Write report ~15min")
        #expect(result[0].estimatedMinutes == 15)
        #expect(result[0].title == "Write report")
    }

    @Test func extractsParenMinutes() {
        let result = PlanParser.parse(text: "Write report (30m)")
        #expect(result[0].estimatedMinutes == 30)
        #expect(result[0].title == "Write report")
    }

    @Test func extractsBracketHours() {
        let result = PlanParser.parse(text: "Deep work [1h]")
        #expect(result[0].estimatedMinutes == 60)
        #expect(result[0].title == "Deep work")
    }

    @Test func extractsTildeHours() {
        let result = PlanParser.parse(text: "Deep work ~2h")
        #expect(result[0].estimatedMinutes == 120)
        #expect(result[0].title == "Deep work")
    }

    @Test func noTimeHintDefaultsTwentyFiveMinutes() {
        // When no time hint is present, tasks default to 25 min
        let result = PlanParser.parse(text: "Buy milk")
        #expect(result[0].estimatedMinutes == 25)
    }

    @Test func explicitTimeHintOverridesDefault() {
        let result = PlanParser.parse(text: "Write report ~10min")
        #expect(result[0].estimatedMinutes == 10)
    }

    // MARK: - Multi-line

    @Test func parsesMultipleLines() {
        let text = """
        - Task one
        - Task two
        - Task three
        """
        let result = PlanParser.parse(text: text)
        #expect(result.count == 3)
        #expect(result[0].title == "Task one")
        #expect(result[2].title == "Task three")
    }

    // MARK: - Icon cycling

    @Test func cyclesIcons() {
        let icons = ["leaf", "star", "moon"]
        let text = "A\nB\nC\nD"
        let result = PlanParser.parse(text: text, icons: icons)
        #expect(result[0].iconSymbol == "leaf")
        #expect(result[1].iconSymbol == "star")
        #expect(result[2].iconSymbol == "moon")
        #expect(result[3].iconSymbol == "leaf")   // wraps around
    }

    @Test func emptyIconsFallsBackToCircle() {
        let result = PlanParser.parse(text: "Task", icons: [])
        #expect(result[0].iconSymbol == "circle")
    }
}
