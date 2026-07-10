import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var hostingController: NSHostingController<AnyView>?
    private var settingsWindow: NSWindow?
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

        // Resize popover whenever task count changes
        updatePopoverSize()
        observeTaskCount()
        observeShowSettings()
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
        let hc = NSHostingController(
            rootView: AnyView(
                ContentView()
                    .environment(appState)
                    .environment(timerState)
                    .environment(historyState)
                    .environment(audioManager)
            )
        )
        hostingController = hc

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 480)
        popover.behavior = .transient
        popover.contentViewController = hc
        self.popover = popover
    }

    private func updatePopoverSize() {
        guard let hc = hostingController, let popover else { return }
        let fit = hc.sizeThatFits(in: NSSize(width: 320, height: 9999))
        let maxH = (NSScreen.main?.visibleFrame.height ?? 800) * 0.85
        popover.contentSize = NSSize(width: 320, height: min(fit.height, maxH))
    }

    // withObservationTracking fires once per call — re-register on each change.
    private func observeTaskCount() {
        withObservationTracking {
            _ = appState.tasks.count
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.updatePopoverSize()
                self?.observeTaskCount()
            }
        }
    }

    // withObservationTracking fires once — re-register on each change.
    private func observeShowSettings() {
        withObservationTracking {
            _ = appState.showSettings
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.appState.showSettings {
                    self.openSettingsWindow()
                } else {
                    self.settingsWindow?.close()
                }
                self.observeShowSettings()
            }
        }
    }

    private func openSettingsWindow() {
        if let w = settingsWindow, w.isVisible { w.makeKeyAndOrderFront(nil); return }
        let hc = NSHostingController(rootView: AnyView(
            SettingsView()
                .environment(appState)
                .environment(timerState)
                .environment(historyState)
                .environment(audioManager)
        ))
        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 440),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        w.title = "Settings"
        w.contentViewController = hc
        w.isReleasedWhenClosed = false
        w.delegate = self
        w.center()
        w.makeKeyAndOrderFront(nil)
        settingsWindow = w
    }

    // NSWindowDelegate — sync flag when user clicks the close button
    nonisolated func windowWillClose(_ notification: Notification) {
        let win = notification.object as? NSWindow
        Task { @MainActor [weak self] in
            guard let self, win === self.settingsWindow else { return }
            self.appState.showSettings = false
        }
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
