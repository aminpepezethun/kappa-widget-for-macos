# OhWell
`Just a side project for my little undiagnosed ADHD mind 👾`
\
\
A macOS menu bar focus timer built for ADHD brains. Paste your plan, get a task list, work through it with a pomodoro timer, and get an animated hit every time you check something off. 

---

## Features

- **Plan → Tasks** — paste any text (notes, bullet lists, numbered steps) and OhWell splits it into a checklist automatically
- **Pomodoro timer** — circular progress ring with work/break phases; time hints in your plan (`~15min`, `(30m)`) set per-task estimates
- **Dopamine on demand** — confetti burst fires the instant you complete a task by holding it for 5 seconds for the ring to fill up
- **Animated icons** — each task gets a themed moving icon; the active task's icon bounces, orbits, or pulses depending on your theme
- **Theme system (_for fellow's developer_ 👽)** — swap between built-in themes or create your own by conforming to the `Theme` protocol

### Built-in Themes

| Theme | Vibe | Animation |
|-------|------|-----------|
| Forest | Green/teal gradients, leaf icons | Bounce |
| Space | Navy/purple gradients, star icons | Orbit |
| Minimal | Near-white, geometric icons | Pulse |

---

## How It Works

1. Click the OhWell icon in your menu bar
2. Paste your plan or add tasks manually
3. Hit **Split into Tasks** — each line becomes a checklist item
4. Start the timer and work through your list
5. Check off a task → confetti → move on

---

## Requirements

- macOS 14 (Sonoma) or later
- Swift 6.3+

## Build & Run

```bash
swift build
swift run ohwell
```

---

## Creating a Custom Theme

Conform to the `Theme` protocol and you have full control over colors, icons, particles, and animation style:

```swift
struct OceanTheme: Theme {
    var name = "Ocean"
    var backgroundGradient: [Color] = [.blue.opacity(0.9), .cyan.opacity(0.6)]
    var accentColor: Color = .cyan
    var completionColor: Color = .teal
    var taskIcons: [String] = ["fish.fill", "drop.fill", "water.waves", "shell.fill"]
    var particleColors: [Color] = [.cyan, .blue, .white]
    var particleSymbols: [String] = ["drop.fill", "sparkle", "circle.fill"]
    var iconAnimationStyle: IconAnimationStyle = .wiggle
    var fontDesign: Font.Design = .rounded
}
```

---

## Tech Stack

- **Swift 6** — strict concurrency throughout
- **SwiftUI** — `@Observable`, `Canvas`, `TimelineView`
- **AppKit** — `NSStatusItem`, `NSPopover` for the menu bar experience
- **Swift Package Manager** — no external dependencies
