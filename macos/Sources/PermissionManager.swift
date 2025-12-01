import Cocoa

class PermissionManager {
    static let shared = PermissionManager()
    
    func isTrusted() -> Bool {
        // 1. Standard Check (Metadata)
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : false]
        let standardTrusted = AXIsProcessTrustedWithOptions(options)
        
        // 2. Hard Check (Functional)
        let hardTrusted = canCreateEventTap()
        
        print("PermissionManager - Standard: \(standardTrusted), Hard: \(hardTrusted)")
        
        return standardTrusted || hardTrusted
    }
    
    private func canCreateEventTap() -> Bool {
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        guard CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (_, _, event, _) -> Unmanaged<CGEvent>? in
                return Unmanaged.passUnretained(event)
            },
            userInfo: nil
        ) != nil else {
            return false
        }
        return true
    }
    
    func requestPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        AXIsProcessTrustedWithOptions(options)
    }
}
