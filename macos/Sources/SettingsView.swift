import SwiftUI

struct SettingsView: View {
    @ObservedObject var localization = LocalizationManager.shared
    @AppStorage("appTheme") private var appTheme: String = "system"
    @AppStorage("closeAction") private var closeAction: String = "prompt"
    
    // API Settings
    @AppStorage("apiProvider") private var apiProvider: String = "googleFree"
    @AppStorage("apiUrl") private var apiUrl: String = "http://127.0.0.1:11434/v1/chat/completions"
    @AppStorage("apiKey") private var apiKey: String = ""
    @AppStorage("modelName") private var modelName: String = "llama3"
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("settings.title".localized)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            ScrollView {
                VStack(spacing: 20) {
                    // General Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("settings.general".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            // Language Picker
                            HStack {
                                Label("settings.language".localized, systemImage: "globe")
                                    .foregroundColor(.primary)
                                Spacer()
                                Picker("", selection: $localization.language) {
                                    Text("English").tag("en")
                                    Text("简体中文").tag("zh-CN")
                                    Text("繁體中文").tag("zh-TW")
                                    Text("日本語").tag("ja")
                                    Text("한국어").tag("ko")
                                    Text("Français").tag("fr")
                                    Text("Deutsch").tag("de")
                                    Text("Español").tag("es")
                                }
                                .pickerStyle(.menu)
                                .frame(width: 140)
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Theme Picker
                            HStack {
                                Label("settings.theme".localized, systemImage: "paintpalette")
                                    .foregroundColor(.primary)
                                Spacer()
                                Picker("", selection: $appTheme) {
                                    Text("theme.system".localized).tag("system")
                                    Text("theme.light".localized).tag("light")
                                    Text("theme.dark".localized).tag("dark")
                                }
                                .pickerStyle(.menu)
                                .frame(width: 140)
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Close Action Picker
                            HStack {
                                Label("When closing window", systemImage: "xmark.circle")
                                    .foregroundColor(.primary)
                                Spacer()
                                Picker("", selection: $closeAction) {
                                    Text("Ask every time").tag("prompt")
                                    Text("Minimize to tray").tag("minimize")
                                    Text("Quit application").tag("quit")
                                }
                                .pickerStyle(.menu)
                                .frame(width: 140)
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                        }
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // Translation API Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Translation API")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            // Provider Picker
                            HStack {
                                Label("Provider", systemImage: "server.rack")
                                    .foregroundColor(.primary)
                                Spacer()
                                Picker("", selection: $apiProvider) {
                                    Text("Google (Free)").tag("googleFree")
                                    Text("OpenAI Compatible").tag("openaiCompatible")
                                }
                                .pickerStyle(.menu)
                                .frame(width: 160)
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            
                            if apiProvider == "openaiCompatible" {
                                Divider()
                                    .padding(.leading, 16)
                                
                                // API URL
                                HStack {
                                    Label("API URL", systemImage: "link")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    TextField("http://127.0.0.1:11434/v1/chat/completions", text: $apiUrl)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 200)
                                }
                                .padding()
                                .background(Color(NSColor.controlBackgroundColor))
                                
                                Divider()
                                    .padding(.leading, 16)
                                
                                // API Key
                                HStack {
                                    Label("API Key", systemImage: "key")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    SecureField("Optional for local", text: $apiKey)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 200)
                                }
                                .padding()
                                .background(Color(NSColor.controlBackgroundColor))
                                
                                Divider()
                                    .padding(.leading, 16)
                                
                                // Model Name
                                HStack {
                                    Label("Model", systemImage: "cube")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    TextField("gpt-3.5-turbo", text: $modelName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 200)
                                }
                                .padding()
                                .background(Color(NSColor.controlBackgroundColor))
                            }
                        }
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                }
                .padding()
            }
        }
        .frame(width: 400, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
