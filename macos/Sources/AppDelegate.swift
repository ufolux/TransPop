import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var window: NSWindow!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Force app to be a regular app (shows in Dock, has UI)
        NSApp.setActivationPolicy(.regular)
        
        // Setup Status Bar
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            // Initial Icon Setup
            updateStatusBarIcon()
            
            button.action = #selector(toggleWindow(_:))
            
            // Observe Appearance Changes
            NSApp.addObserver(self, forKeyPath: "effectiveAppearance", options: [.new], context: nil)
        }
        
        // Set App Icon
        // Set App Icon
        // Use Bundle.main because we are running in a manually created App Bundle
        // and build_app.sh puts AppIcon.icns in Contents/Resources.
        // Note: NSApp.applicationIconImage is usually set automatically from Info.plist,
        // but we can force it here if needed.
        // Since we set CFBundleIconFile in Info.plist, we might not even need this code,
        // but if we keep it, we must use Bundle.main.
        if let iconPath = Bundle.main.path(forResource: "AppIcon", ofType: "icns"),
            let iconImage = NSImage(contentsOfFile: iconPath) {
            NSApp.applicationIconImage = iconImage
        }
        
        // Check Permissions
        let isTrusted = PermissionManager.shared.isTrusted()
        var isBypassed = UserDefaults.standard.bool(forKey: "BypassPermissionCheck")
        
        // Debug: Check for Option key to reset bypass
        // let event = NSAppleEventManager.shared().currentAppleEvent // Not needed for modifier check
        if NSEvent.modifierFlags.contains(.option) {
            print("Option key held: Resetting Bypass Flag")
            UserDefaults.standard.removeObject(forKey: "BypassPermissionCheck")
            isBypassed = false
        }
        
        print("Startup Check: Trusted=\(isTrusted), Bypassed=\(isBypassed)")
        
        // Create Window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        
        window.center()
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.isReleasedWhenClosed = false
        window.delegate = self
        
        if isTrusted || isBypassed {
            window.contentView = NSHostingView(rootView: ContentView())
            // Setup Global Shortcut Listener only if trusted or bypassed
            GlobalShortcutManager.shared.startListening()
        } else {
            window.contentView = NSHostingView(rootView: OnboardingView())
        }
        
        window.makeKeyAndOrderFront(nil)
        
        // Observers
        NotificationCenter.default.addObserver(self, selector: #selector(handleTranslationRequest(_:)), name: NSNotification.Name("TriggerTranslation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(expandWindow), name: NSNotification.Name("ExpandWindow"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(forceStartApp), name: NSNotification.Name("ForceStartApp"), object: nil)
        
        // Activate app
        NSApp.activate(ignoringOtherApps: true)
        
        // Check for Updates
        UserDefaults.standard.register(defaults: ["autoCheckUpdates": true])
        if UserDefaults.standard.bool(forKey: "autoCheckUpdates") {
            UpdateManager.shared.checkForUpdates()
        }
        
        // Initial Theme Setup
        updateWindowAppearance()
        
        // Observe Theme Changes
        UserDefaults.standard.addObserver(self, forKeyPath: "appTheme", options: [.new], context: nil)
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "appTheme")
    }
    
    func updateWindowAppearance() {
        let theme = UserDefaults.standard.string(forKey: "appTheme") ?? "system"
        switch theme {
        case "light":
            window.appearance = NSAppearance(named: .aqua)
        case "dark":
            window.appearance = NSAppearance(named: .darkAqua)
        default:
            window.appearance = nil // Reset to system
        }
        updateStatusBarIcon()
    }
    
    @objc func forceStartApp() {
        print("Force starting app...")
        window.contentView = NSHostingView(rootView: ContentView())
        GlobalShortcutManager.shared.startListening()
        window.makeKeyAndOrderFront(nil)
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
        var x = mouseLoc.x
        var y = mouseLoc.y - height - 20 // 20px offset
        
        // Ensure Window is Screen-Bound
        // Find the screen that contains the mouse cursor
        if let screen = NSScreen.screens.first(where: { NSPointInRect(mouseLoc, $0.frame) }) ?? NSScreen.main {
            let visibleFrame = screen.visibleFrame
            
            // Validate X
            if x < visibleFrame.minX {
                x = visibleFrame.minX
            } else if x + width > visibleFrame.maxX {
                x = visibleFrame.maxX - width
            }
            
            // Validate Y
            if y < visibleFrame.minY {
                // If falls off bottom, pin to bottom (but above dock if any)
                y = visibleFrame.minY
            } else if y + height > visibleFrame.maxY {
                // If falls off top, pin to top (but below menu bar)
                y = visibleFrame.maxY - height
            }
        }

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

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "effectiveAppearance" {
            updateStatusBarIcon()
        } else if keyPath == "appTheme" {
            updateWindowAppearance()
        }
    }

    func updateStatusBarIcon() {
        guard let button = statusBarItem.button else { return }
        
        let appearance = NSApp.effectiveAppearance
        let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        
        let iconName = isDark ? "dark" : "light"
        
        // Try to load from bundle resources
        // Use Bundle.main because we copy resources directly to Contents/Resources
        if let iconPath = Bundle.main.path(forResource: iconName, ofType: "png"),
           let image = NSImage(contentsOfFile: iconPath) {
            // Resize to standard status bar size (usually 18x18 or 22x22)
            image.size = NSSize(width: 18, height: 18)
            image.isTemplate = false // Keep original colors
            button.image = image
            button.title = "" // Clear title if image exists
        } else {
            // Fallback
            print("⚠️ Status bar icon not found: \(iconName)")
            button.image = NSImage(systemSymbolName: "character.bubble", accessibilityDescription: "TransPop")
        }
    }

}

extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // If in Mini Mode, just minimize without asking
        // If in Mini Mode, just minimize without asking
        if AppState.shared.viewMode == .mini {
            // Hiding the app (cmd+h equivalent) returns focus to the previous app naturally
            NSApp.hide(nil)
            return false
        }
        
        let closeAction = UserDefaults.standard.string(forKey: "closeAction") ?? "prompt"
        
        if closeAction == "minimize" {
            sender.orderOut(nil)
            return false
        } else if closeAction == "quit" {
            NSApp.terminate(nil)
            return true
        }
        
        let alert = NSAlert()
        alert.messageText = "Close TransPop?"
        alert.informativeText = "Do you want to quit the application or minimize it to the status bar?"
        alert.addButton(withTitle: "Minimize")
        alert.addButton(withTitle: "Quit")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning
        
        alert.showsSuppressionButton = true
        alert.suppressionButton?.title = "Do not ask again"
        
        let response = alert.runModal()
        let rememberChoice = alert.suppressionButton?.state == .on
        
        switch response {
        case .alertFirstButtonReturn: // Minimize
            if rememberChoice {
                UserDefaults.standard.set("minimize", forKey: "closeAction")
            }
            sender.orderOut(nil)
            return false
        case .alertSecondButtonReturn: // Quit
            if rememberChoice {
                UserDefaults.standard.set("quit", forKey: "closeAction")
            }
            NSApp.terminate(nil)
            return true
        default: // Cancel
            return false
        }
    }
}
