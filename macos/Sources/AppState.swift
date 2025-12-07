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
    
    private var searchWorkItem: DispatchWorkItem?
    
    func performTranslation() {
        // Cancel previous request
        searchWorkItem?.cancel()
        
        guard !sourceText.isEmpty else {
            targetText = ""
            isTranslating = false
            return
        }
        
        // Create new work item
        var workItem: DispatchWorkItem?
        workItem = DispatchWorkItem { [weak self] in
            guard let self = self, let item = workItem, !item.isCancelled else { return }
            
            self.isTranslating = true
            
            TranslationService.shared.translate(text: self.sourceText, source: self.sourceLang, target: self.targetLang) { result in
                DispatchQueue.main.async {
                    // Check if this specific item was cancelled
                    guard let item = workItem, !item.isCancelled else { return }
                    
                    self.isTranslating = false
                    switch result {
                    case .success(let response):
                        self.targetText = response.text
                        
                        // Add to history
                        HistoryManager.shared.add(
                            sourceText: self.sourceText,
                            targetText: response.text,
                            sourceLang: self.sourceLang,
                            targetLang: self.targetLang
                        )
                        
                    case .failure(let error):
                        print("Translation error: \(error)")
                        self.targetText = "[Error] \(error.localizedDescription)"
                    }
                }
            }
        }
        
        searchWorkItem = workItem
        
        // Execute with delay (debounce)
        if let workItem = workItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
    }
}
