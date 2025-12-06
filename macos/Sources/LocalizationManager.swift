import SwiftUI
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @AppStorage("appLanguage") var language: String = "en"
    
    // Ordered list of supported languages
    let supportedLanguages: [String] = [
        "en", "zh-CN", "zh-TW", "ja", "ko", "fr", "de", "es", "it", "pt", "ru", "vi", "th", "id", "hi", "ar",
        "nl", "pl", "tr", "uk", "sv", "da", "fi", "no", "el", "cs", "ro", "hu", "ms", "tl", "bn", "fa", "he", "ur",
        "sk", "hr", "bg", "sr", "ca", "ta"
    ]
    
    private init() {
         if UserDefaults.standard.object(forKey: "appLanguage") == nil {
             // Attempt to detect system language
             let detected = detectSystemLanguage()
             UserDefaults.standard.set(detected, forKey: "appLanguage")
         }
    }
    
    private func detectSystemLanguage() -> String {
        let preferred = Locale.preferredLanguages
        for lang in preferred {
            // Normalize: zh-Hans-US -> zh-CN, etc.
            // Simple robust check:
            if supportedLanguages.contains(lang) { return lang }
            
            // Partial match (e.g. zh-Hans -> zh-CN)
            if lang.starts(with: "zh-Hans") { return "zh-CN" }
            if lang.starts(with: "zh-Hant") { return "zh-TW" }
            
            // Check prefix (e.g. fr-CA -> fr)
            let prefix = String(lang.prefix(2))
            if supportedLanguages.contains(prefix) { return prefix }
        }
        return "en"
    }

    private var translations: [String: [String: String]] {
        return AP_LOCALE_DATA
    }
    
    func localizedString(_ key: String) -> String {
        let dict = translations[language] ?? translations["en"]!
        if let val = dict[key] {
            return val
        }
        return translations["en"]?[key] ?? key
    }
    
    func nativeLanguageName(for code: String) -> String {
        return NATIVE_LOCALE_NAMES[code] ?? code
    }
}

// Helper extension for easier usage in SwiftUI
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(self)
    }
}
