import Foundation
import AppKit

struct GitHubRelease: Codable {
    let tagName: String
    let assets: [GitHubAsset]
    let body: String?
    let htmlUrl: String
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case assets
        case body
        case htmlUrl = "html_url"
    }
}

struct GitHubAsset: Codable {
    let browserDownloadUrl: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case browserDownloadUrl = "browser_download_url"
        case name
    }
}

class UpdateManager: ObservableObject {
    static let shared = UpdateManager()
    
    @Published var isChecking = false
    @Published var updateAvailable = false
    @Published var latestVersion: String?
    @Published var releaseNotes: String?
    @Published var updateError: String?
    @Published var downloadProgress: Double = 0
    @Published var isDownloading = false
    
    private var latestRelease: GitHubRelease?
    
    private init() {}
    
    func checkForUpdates(manual: Bool = false) {
        guard !isChecking else { return }
        
        isChecking = true
        updateError = nil
        
        let url = URL(string: "https://api.github.com/repos/ufolux/TransPop/releases/latest")!
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isChecking = false
                
                if let error = error {
                    if manual {
                        self?.updateError = "Failed to check for updates: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                    self?.handleRelease(release, manual: manual)
                } catch {
                    if manual {
                        self?.updateError = "Failed to parse update data."
                    }
                    print("Update parse error: \(error)")
                }
            }
        }.resume()
    }
    
    private func handleRelease(_ release: GitHubRelease, manual: Bool) {
        let currentVersion = "v" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0")
        let latestVersion = release.tagName
        
        print("Current: \(currentVersion), Latest: \(latestVersion)")
        
        if compareVersions(current: currentVersion, latest: latestVersion) {
            self.latestRelease = release
            self.latestVersion = latestVersion
            self.releaseNotes = release.body
            self.updateAvailable = true
        } else if manual {
            self.updateError = "You are up to date! (\(currentVersion))"
        }
    }
    
    private func compareVersions(current: String, latest: String) -> Bool {
        let currentClean = current.replacingOccurrences(of: "v", with: "")
        let latestClean = latest.replacingOccurrences(of: "v", with: "")
        
        return latestClean.compare(currentClean, options: .numeric) == .orderedDescending
    }
    
    func downloadAndInstall() {
        guard let release = latestRelease,
              let asset = release.assets.first(where: { $0.name.hasSuffix(".zip") }),
              let url = URL(string: asset.browserDownloadUrl) else {
            self.updateError = "No suitable update file found."
            return
        }
        
        isDownloading = true
        downloadProgress = 0
        
        let task = URLSession.shared.downloadTask(with: url) { [weak self] localURL, response, error in
            DispatchQueue.main.async {
                self?.isDownloading = false
                
                if let error = error {
                    self?.updateError = "Download failed: \(error.localizedDescription)"
                    return
                }
                
                guard let localURL = localURL else { return }
                self?.installUpdate(from: localURL)
            }
        }
        
        // Observation for progress could be added here with KVO, but for simplicity we'll skip detailed progress for now
        // or implement a delegate if needed.
        
        task.resume()
    }
    
    private func installUpdate(from tempZipURL: URL) {
        guard let appPath = Bundle.main.bundlePath as String? else { return }
        
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        do {
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
            let destinationZip = tempDir.appendingPathComponent("update.zip")
            try fileManager.moveItem(at: tempZipURL, to: destinationZip)
            
            // Unzip
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
            process.arguments = ["-o", destinationZip.path, "-d", tempDir.path]
            try process.run()
            process.waitUntilExit()
            
            // Find the .app in the unzipped contents
            let contents = try fileManager.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            guard let newAppURL = contents.first(where: { $0.pathExtension == "app" }) else {
                updateError = "Update failed: Could not find .app in update package."
                return
            }
            
            // Create installation script
            let script = """
            #!/bin/bash
            sleep 2
            echo "Replacing \(appPath) with \(newAppURL.path)"
            rm -rf "\(appPath)"
            mv "\(newAppURL.path)" "\(appPath)"
            xattr -cr "\(appPath)"
            open "\(appPath)"
            """
            
            let scriptPath = tempDir.appendingPathComponent("install_update.sh")
            try script.write(to: scriptPath, atomically: true, encoding: .utf8)
            try fileManager.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptPath.path)
            
            // Run script
            let installProcess = Process()
            installProcess.executableURL = URL(fileURLWithPath: "/bin/bash")
            installProcess.arguments = [scriptPath.path]
            try installProcess.run()
            
            NSApp.terminate(nil)
            
        } catch {
            updateError = "Installation failed: \(error.localizedDescription)"
            print("Install error: \(error)")
        }
    }
}
