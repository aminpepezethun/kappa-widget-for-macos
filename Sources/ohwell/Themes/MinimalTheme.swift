import SwiftUI

struct MinimalTheme: Theme {
    let name = "Minimal"
    let backgroundGradient: [Color] = [
        Color(red: 0.97, green: 0.97, blue: 0.97),
        Color(red: 0.93, green: 0.93, blue: 0.95)
    ]
    let accentColor = Color(red: 0.20, green: 0.20, blue: 0.22)
    let completionColor = Color(red: 0.40, green: 0.40, blue: 0.42)
    let taskIcons = ["square.fill", "circle.fill", "diamond.fill", "triangle.fill", "hexagon.fill"]
    let particleColors: [Color] = [
        Color(red: 0.60, green: 0.60, blue: 0.62),
        Color(red: 0.40, green: 0.40, blue: 0.42),
        Color(red: 0.80, green: 0.80, blue: 0.82)
    ]
    let particleSymbols = ["square.fill", "circle.fill", "diamond.fill", "triangle.fill"]
    let iconAnimationStyle: IconAnimationStyle = .pulse
    let fontDesign: Font.Design = .monospaced
}
