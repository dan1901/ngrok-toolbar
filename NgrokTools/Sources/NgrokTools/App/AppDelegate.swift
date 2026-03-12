import AppKit
import SwiftUI

extension Notification.Name {
    static let toggleDetach = Notification.Name("toggleDetach")
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var detachedWindow: NSWindow?
    private var isDetached = false
    private let appViewModel = AppViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleToggleDetach),
            name: .toggleDetach, object: nil
        )
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "network", accessibilityDescription: "ngrok Tools")
            button.action = #selector(togglePopover)
            button.target = self
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 380, height: 480)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: ContentView(appViewModel: appViewModel, isDetached: false)
        )
    }

    @objc private func togglePopover() {
        if isDetached {
            // Bring detached window to front
            detachedWindow?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        guard let popover = popover, let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    @objc private func handleToggleDetach() {
        if isDetached {
            attachToToolbar()
        } else {
            detachToWindow()
        }
    }

    private func detachToWindow() {
        // Close popover
        popover?.performClose(nil)

        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 560),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "ngrok Tools"
        window.minSize = NSSize(width: 360, height: 400)
        window.contentViewController = NSHostingController(
            rootView: ContentView(appViewModel: appViewModel, isDetached: true)
        )
        window.center()
        window.delegate = self
        window.makeKeyAndOrderFront(nil)
        window.isReleasedWhenClosed = false

        NSApp.activate(ignoringOtherApps: true)

        detachedWindow = window
        isDetached = true
    }

    private func attachToToolbar() {
        // Close window
        detachedWindow?.close()
        detachedWindow = nil
        isDetached = false

        // Re-setup popover with fresh view
        popover?.contentViewController = NSHostingController(
            rootView: ContentView(appViewModel: appViewModel, isDetached: false)
        )

        // Show popover
        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func updateBadge(count: Int) {
        guard let button = statusItem?.button else { return }
        button.title = count > 0 ? " \(count)" : ""
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        // When user closes the detached window via red button, go back to toolbar mode
        if isDetached {
            detachedWindow = nil
            isDetached = false

            popover?.contentViewController = NSHostingController(
                rootView: ContentView(appViewModel: appViewModel, isDetached: false)
            )
        }
    }
}
