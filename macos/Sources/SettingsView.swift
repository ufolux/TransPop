import SwiftUI

struct SettingsView: View {
    @ObservedObject var localization = LocalizationManager.shared
    
    var body: some View {
        Form {
            Section(header: Text("settings.general".localized)) {
                Picker("settings.language".localized, selection: $localization.language) {
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
            }
            
            Section {
                Button("settings.quit".localized) {
                    NSApp.terminate(nil)
                }
                .foregroundColor(.red)
            }
        }
        .padding()
        .frame(width: 350, height: 200)
        .navigationTitle("settings.title".localized)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
