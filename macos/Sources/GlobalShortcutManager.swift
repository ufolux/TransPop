import Cocoa
import Carbon

class GlobalShortcutManager {
    static let shared = GlobalShortcutManager()
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    private var lastCPressTime: TimeInterval = 0
    private let doublePressDelay: TimeInterval = 0.5
    
    func startListening() {
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                return GlobalShortcutManager.shared.handle(event: event, type: type)
            },
            userInfo: nil
        ) else {
            print("Failed to create event tap")
            return
        }
        
        self.eventTap = eventTap
        self.runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    private func handle(event: CGEvent, type: CGEventType) -> Unmanaged<CGEvent>? {
        if type == .keyDown {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            let flags = event.flags
            
            // Key Code for 'C' is 8
            if keyCode == 8 && flags.contains(.maskCommand) {
                print("Cmd+C pressed")
                let now = Date().timeIntervalSince1970
                if now - lastCPressTime < doublePressDelay {
                    print("Double Cmd+C detected!")
                    // Trigger Translation
                    DispatchQueue.main.async {
                        self.triggerTranslation()
                    }
                    lastCPressTime = 0
                } else {
                    lastCPressTime = now
                }
            }
        }
        return Unmanaged.passRetained(event)
    }
    
    private func triggerTranslation() {
        // Read Clipboard
        let pasteboard = NSPasteboard.general
        if let text = pasteboard.string(forType: .string) {
            print("Clipboard text: \(text)")
            // Notify UI to translate
            NotificationCenter.default.post(name: NSNotification.Name("TriggerTranslation"), object: text)
            
            // Show App
            NSApp.activate(ignoringOtherApps: true)
            // Bring window to front
        }
    }
}
