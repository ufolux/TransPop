import Foundation
import Combine

struct HistoryItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let sourceText: String
    let targetText: String
    let sourceLang: String
    let targetLang: String
    let timestamp: Date
    
    // Custom coding keys to exclude ID if we don't want to persist it, or keep it consistent.
    // For simplicity, we just use default Codable.
}

class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    @Published var items: [HistoryItem] = []
    
    // We use a property wrapper or simple didSet for maxItems, but since we read from UserDefaults
    // directly in add(), we might just want a helper or published property if we want UI to update.
    // For now, let's just read UserDefaults when needed to keep it simple.
    
    private let storageKey = "translationHistory"
    private var fileURL: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsDirectory.appendingPathComponent("translation_history.json")
    }
    
    init() {
        loadHistory()
    }
    
    func loadHistory() {
        guard let url = fileURL else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            items = try decoder.decode([HistoryItem].self, from: data)
            // Sort by new to old just in case
            items.sort { $0.timestamp > $1.timestamp }
        } catch {
            print("Failed to load history: \(error)")
            // If file doesn't exist, items is just empty, which is fine
        }
    }
    
    func saveHistory() {
        guard let url = fileURL else { return }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(items)
            try data.write(to: url)
        } catch {
            print("Failed to save history: \(error)")
        }
    }
    
    func add(sourceText: String, targetText: String, sourceLang: String, targetLang: String) {
        // Prevent duplicates at the top - if the same translation just happened
        if let first = items.first, first.sourceText == sourceText, first.targetText == targetText {
            return
        }
        
        let newItem = HistoryItem(
            sourceText: sourceText,
            targetText: targetText,
            sourceLang: sourceLang,
            targetLang: targetLang,
            timestamp: Date()
        )
        
        items.insert(newItem, at: 0)
        
        // Enforce limit
        let maxItems = UserDefaults.standard.integer(forKey: "historyMaxItems")
        let limit = maxItems > 0 ? maxItems : 100 // Default to 100 if not set or 0
        
        if items.count > limit {
            items = Array(items.prefix(limit))
        }
        
        saveHistory()
    }
    
    func delete(id: UUID) {
        items.removeAll { $0.id == id }
        saveHistory()
    }
    
    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        saveHistory()
    }
    
    func clearAll() {
        items.removeAll()
        saveHistory()
    }
}
