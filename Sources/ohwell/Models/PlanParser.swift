import Foundation

struct PlanParser {
    /// Parse a multi-line text plan into TaskItems.
    /// - Parameter text: Raw plan text (one task per line)
    /// - Parameter icons: SF Symbol names to cycle through per task
    /// - Returns: Array of TaskItems with stripped bullets and extracted time hints
    static func parse(text: String, icons: [String] = ["circle"]) -> [TaskItem] {
        let lines = text.components(separatedBy: .newlines)
        var items: [TaskItem] = []
        var index = 0

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            var title = stripBullet(trimmed)
            let minutes = extractTime(from: &title)
            let icon = icons.isEmpty ? "circle" : icons[index % icons.count]

            items.append(TaskItem(title: title, estimatedMinutes: minutes, iconSymbol: icon))
            index += 1
        }

        return items
    }

    // MARK: - Private helpers

    private static func stripBullet(_ line: String) -> String {
        // Ordered: "1. ", "- ", "* ", "• "
        let patterns = [#"^\d+\.\s+"#, #"^[-*•]\s+"#]
        for pattern in patterns {
            if let range = line.range(of: pattern, options: .regularExpression) {
                return String(line[range.upperBound...])
            }
        }
        return line
    }

    private static func extractTime(from title: inout String) -> Int? {
        // Matches: ~15min, (30m), [1h], ~2h
        let pattern = #"[\~\(\[]\s*(\d+)\s*(h|min|m)\s*[\)\]]?"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: title, range: NSRange(title.startIndex..., in: title)),
              let valueRange = Range(match.range(at: 1), in: title),
              let unitRange = Range(match.range(at: 2), in: title) else {
            return nil
        }

        let value = Int(title[valueRange]) ?? 0
        let unit = title[unitRange].lowercased()
        let minutes = unit == "h" ? value * 60 : value

        // Remove the time hint from the title
        if let fullRange = Range(match.range, in: title) {
            title = title.replacingCharacters(in: fullRange, with: "").trimmingCharacters(in: .whitespaces)
        }

        return minutes > 0 ? minutes : nil
    }
}
