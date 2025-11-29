import SwiftUI

@main
struct TransPopApp: App {
    // We use a custom AppDelegate to handle status bar and global events
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
