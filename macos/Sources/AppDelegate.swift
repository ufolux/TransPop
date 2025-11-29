import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Force app to be a regular app (shows in Dock, has UI)
        NSApp.setActivationPolicy(.regular)
        
        // Check for Accessibility Permissions
        checkAccessibilityPermissions()
        
        // Setup Status Bar
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "character.bubble", accessibilityDescription: "TransPop")
            // Fallback if image fails (though character.bubble is standard)
            if button.image == nil {
                button.title = "T"
            }
            button.action = #selector(toggleWindow(_:))
        }
        
        // Set App Icon
        if let iconPath = Bundle.module.path(forResource: "AppIcon", ofType: "png"),
           let iconImage = NSImage(contentsOfFile: iconPath) {
            NSApp.applicationIconImage = iconImage
        }
        
        // Create Window
        let contentView = ContentView()
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        
        window.center()
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.contentView = NSHostingView(rootView: contentView)
        window.delegate = self
        window.makeKeyAndOrderFront(nil)
        
        // Setup Global Shortcut Listener
        GlobalShortcutManager.shared.startListening()
        
        // Observers
        NotificationCenter.default.addObserver(self, selector: #selector(handleTranslationRequest(_:)), name: NSNotification.Name("TriggerTranslation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(expandWindow), name: NSNotification.Name("ExpandWindow"), object: nil)
        
        // Activate app
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func handleTranslationRequest(_ notification: Notification) {
        print("AppDelegate received TriggerTranslation")
        guard let text = notification.object as? String else { 
            print("No text in notification")
            return 
        }
        print("Text to translate: \(text)")
        
        // Update State
        AppState.shared.sourceText = text
        AppState.shared.sourceLang = "auto" // Always auto-detect for shortcut
        AppState.shared.viewMode = .mini
        AppState.shared.performTranslation()
        
        // Hide Zoom (Fullscreen) button in Mini Mode
        window.standardWindowButton(.zoomButton)?.isHidden = true
        
        // Position Window at Cursor
        let mouseLoc = NSEvent.mouseLocation
        // Note: NSEvent.mouseLocation is in screen coordinates (0,0 at bottom-left)
        // Window coordinates also use bottom-left.
        
        // Mini size
        let width: CGFloat = 300
        let height: CGFloat = 200
        
        // Adjust Y to be slightly below cursor (cursor is top-left of pointer usually)
        // We want window top to be at cursor Y.
        let x = mouseLoc.x
        let y = mouseLoc.y - height - 20 // 20px offset
        
        window.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true, animate: true)
        
        if !window.isVisible {
            window.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func expandWindow() {
        AppState.shared.viewMode = .full
        
        // Show Zoom button in Full Mode
        window.standardWindowButton(.zoomButton)?.isHidden = false
        
        // Center window or keep position but resize?
        // Let's center for full mode as it's cleaner
        let width: CGFloat = 450
        let height: CGFloat = 600
        
        // Animate frame change
        let currentFrame = window.frame
        let newFrame = NSRect(
            x: currentFrame.minX, // Keep X
            y: currentFrame.maxY - height, // Grow downwards
            width: width,
            height: height
        )
        
        window.setFrame(newFrame, display: true, animate: true)
        window.center() // Optional: Center it if we prefer
    }
    
    @objc func toggleWindow(_ sender: AnyObject?) {
        if window.isVisible {
            window.orderOut(nil)
        } else {
            AppState.shared.viewMode = .full
            // Show Zoom button in Full Mode
            window.standardWindowButton(.zoomButton)?.isHidden = false
            window.setFrame(NSRect(x: 0, y: 0, width: 450, height: 600), display: true)
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Always switch to Full Mode when clicking Dock Icon
        AppState.shared.viewMode = .full
        window.standardWindowButton(.zoomButton)?.isHidden = false
        
        // Reset to default full size and center
        window.setFrame(NSRect(x: 0, y: 0, width: 450, height: 600), display: true)
        window.center()
        window.makeKeyAndOrderFront(nil)
        
        return true
    }
    func checkAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if !accessEnabled {
            print("Access not enabled. Prompting user.")
            let alert = NSAlert()
            alert.messageText = "Permissions Required"
            alert.informativeText = "TransPop needs Accessibility permissions to detect shortcuts. Please grant access in System Settings and then RESTART the app."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // If in Mini Mode, just minimize without asking
        if AppState.shared.viewMode == .mini {
            sender.orderOut(nil)
            return false
        }
        
        let alert = NSAlert()
        alert.messageText = "Close TransPop?"
        alert.informativeText = "Do you want to quit the application or minimize it to the status bar?"
        alert.addButton(withTitle: "Minimize")
        alert.addButton(withTitle: "Quit")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning
        
        let response = alert.runModal()
        
        switch response {
        case .alertFirstButtonReturn: // Minimize
            sender.orderOut(nil)
            return false
        case .alertSecondButtonReturn: // Quit
            NSApp.terminate(nil)
            return true
        default: // Cancel
            return false
        }
    }
}
