import SwiftUI

struct OnboardingView: View {
    @State private var isTrusted: Bool = false
    @State private var showManualRestart: Bool = false
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "hand.raised.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            VStack(spacing: 10) {
                Text("Permissions Required")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("TransPop needs Accessibility permissions to detect the global shortcut (Cmd+C+C) and read the selected text.")
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 15) {
                if isTrusted || showManualRestart {
                    VStack(spacing: 10) {
                        Image(systemName: isTrusted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(isTrusted ? .green : .orange)
                            .font(.system(size: 40))
                        
                        Text(isTrusted ? "Permissions Granted!" : "Restart Required")
                            .font(.headline)
                            .foregroundColor(isTrusted ? .green : .orange)
                        
                        Text(isTrusted ? "Please restart the app to apply changes." : "macOS may require a restart to detect the new permissions.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Quit & Restart") {
                            if showManualRestart {
                                UserDefaults.standard.set(true, forKey: "BypassPermissionCheck")
                                UserDefaults.standard.synchronize()
                            }
                            restartApp()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        if !isTrusted {
                            Button("Force Start (I'm sure)") {
                                UserDefaults.standard.set(true, forKey: "BypassPermissionCheck")
                                NotificationCenter.default.post(name: NSNotification.Name("ForceStartApp"), object: nil)
                            }
                            .buttonStyle(.link)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 10)
                        }
                    }
                } else {
                    Button("Open System Settings") {
                        openSystemSettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Text("Go to Privacy & Security > Accessibility and enable TransPop")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("I have enabled permissions") {
                        // If system doesn't report true yet, we force the restart flow
                        // because macOS often requires restart anyway.
                        checkPermissions()
                        if !isTrusted {
                            showManualRestart = true
                        }
                    }
                    .buttonStyle(.link)
                    .padding(.top, 5)
                }
            }
        }
        .padding()
        .frame(width: 450, height: 600)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            checkPermissions()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            print("App became active, checking permissions...")
            checkPermissions()
        }
    }
    
    func openSystemSettings() {
        // Open System Settings directly
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
        // Also trigger the system prompt just in case
        PermissionManager.shared.requestPermissions()
    }
    
    func checkPermissions() {
        let isTrusted = PermissionManager.shared.isTrusted()
        
        DispatchQueue.main.async {
            self.isTrusted = isTrusted
            // If trusted, we can clear the bypass flag
            if isTrusted {
                UserDefaults.standard.removeObject(forKey: "BypassPermissionCheck")
            }
        }
    }
    
    func startTimer() {
        // Check every 1 second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            checkPermissions()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func restartApp() {
        let url = URL(fileURLWithPath: Bundle.main.bundlePath)
        let config = NSWorkspace.OpenConfiguration()
        config.createsNewApplicationInstance = true
        
        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, _ in
            DispatchQueue.main.async {
                NSApp.terminate(nil)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
