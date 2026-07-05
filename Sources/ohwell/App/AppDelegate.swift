import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let appState = AppState()
    private let timerState = TimerState()
    private let historyState = HistoryState()
    private let audioManager = AudioManager()
    private let persistence = PersistenceController.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Wire persistence
        let ctx = persistence.container.mainContext
        appState.modelContext = ctx
        appState.loadSavedPlan()
        historyState.load(from: ctx)

        setupStatusItem()
        setupPopover()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "timer", accessibilityDescription: "OhWell")
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 480)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: ContentView()
                .environment(appState)
                .environment(timerState)
                .environment(historyState)
                .environment(audioManager)
        )
        self.popover = popover
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }
        if let popover, popover.isShown {
            popover.performClose(nil)
        } else {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
