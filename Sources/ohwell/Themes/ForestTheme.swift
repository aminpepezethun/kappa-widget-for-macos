import SwiftUI

struct ForestTheme: Theme {
    let name = "Forest"
    let backgroundGradient: [Color] = [
        Color(red: 0.13, green: 0.37, blue: 0.31),
        Color(red: 0.07, green: 0.24, blue: 0.20)
    ]
    let accentColor = Color(red: 0.40, green: 0.85, blue: 0.65)
    let completionColor = Color(red: 0.27, green: 0.73, blue: 0.53)
    let taskIcons = ["leaf.fill", "tree.fill", "flower.fill", "ant.fill", "bird.fill"]
    let particleColors: [Color] = [
        Color(red: 0.40, green: 0.85, blue: 0.65),
        Color(red: 0.56, green: 0.93, blue: 0.56),
        Color(red: 0.13, green: 0.70, blue: 0.47)
    ]
    let particleSymbols = ["leaf.fill", "star.fill", "sparkle", "circle.fill"]
    let iconAnimationStyle: IconAnimationStyle = .bounce
    let fontDesign: Font.Design = .rounded
}
