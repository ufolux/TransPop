import SwiftUI

struct SettingsView: View {
    @ObservedObject var localization = LocalizationManager.shared
    @AppStorage("appTheme") private var appTheme: String = "system"
    
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
        .frame(width: 400, height: 240)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
