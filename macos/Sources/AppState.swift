import SwiftUI
import Combine

enum ViewMode {
    case full
    case mini
}

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var sourceText: String = ""
    @Published var targetText: String = ""
    @Published var viewMode: ViewMode = .full
    @Published var isTranslating: Bool = false
    
    @AppStorage("sourceLang") var sourceLang: String = "auto"
    @AppStorage("targetLang") var targetLang: String = "en"
    
    func performTranslation() {
        guard !sourceText.isEmpty else { return }
        isTranslating = true
        
        TranslationService.shared.translate(text: sourceText, source: sourceLang, target: targetLang) { result in
            DispatchQueue.main.async {
                self.isTranslating = false
                switch result {
                case .success(let response):
                    self.targetText = response.text
                case .failure(let error):
                    print("Translation error: \(error)")
                    self.targetText = "[Error] Translation failed"
                }
            }
        }
    }
}
