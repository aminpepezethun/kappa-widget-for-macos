import SwiftUI

struct SpaceTheme: Theme {
    let name = "Space"
    let backgroundGradient: [Color] = [
        Color(red: 0.07, green: 0.07, blue: 0.24),
        Color(red: 0.18, green: 0.07, blue: 0.35)
    ]
    let accentColor = Color(red: 0.55, green: 0.47, blue: 0.97)
    let completionColor = Color(red: 0.40, green: 0.75, blue: 0.98)
    let taskIcons = ["star.fill", "moon.fill", "sparkles", "planet.fill", "bolt.fill"]
    let particleColors: [Color] = [
        Color(red: 0.55, green: 0.47, blue: 0.97),
        Color(red: 0.40, green: 0.75, blue: 0.98),
        Color(red: 0.98, green: 0.90, blue: 0.40)
    ]
    let particleSymbols = ["star.fill", "sparkles", "circle.fill", "diamond.fill"]
    let iconAnimationStyle: IconAnimationStyle = .orbit(radius: 4)
    let fontDesign: Font.Design = .default
}
