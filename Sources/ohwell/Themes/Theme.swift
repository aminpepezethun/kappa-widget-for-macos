import SwiftUI

enum IconAnimationStyle: Sendable {
    case bounce
    case pulse
    case wiggle
    case orbit(radius: CGFloat)
}

protocol Theme: Sendable {
    var name: String { get }
    var backgroundGradient: [Color] { get }   // 2-3 stops
    var accentColor: Color { get }
    var completionColor: Color { get }
    var taskIcons: [String] { get }           // SF Symbol names, cycled per task
    var particleColors: [Color] { get }
    var particleSymbols: [String] { get }     // SF Symbols used as confetti
    var iconAnimationStyle: IconAnimationStyle { get }
    var fontDesign: Font.Design { get }
}
