import Foundation

class OpenAITranslator {
    static let shared = OpenAITranslator()
    
    private init() {}
    
    func translate(text: String, source: String, target: String, completion: @escaping (Result<TranslationResponse, Error>) -> Void) {
        let apiUrl = UserDefaults.standard.string(forKey: "apiUrl") ?? "http://localhost:11434/v1/chat/completions"
        let apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        let modelName = UserDefaults.standard.string(forKey: "modelName") ?? "llama3"
        
        guard let url = URL(string: apiUrl) else {
            completion(.failure(NSError(domain: "Invalid API URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if !apiKey.isEmpty {
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        let languageNames: [String: String] = [
            "en": "English",
            "zh-CN": "Simplified Chinese",
            "zh-TW": "Traditional Chinese",
            "ja": "Japanese",
            "ko": "Korean",
            "fr": "French",
            "de": "German",
            "es": "Spanish",
            "auto": "any language"
        ]
        
        let sourceName = languageNames[source] ?? source
        let targetName = languageNames[target] ?? target
        
        let systemPrompt = "You are a professional translator. Translate the following text from \(sourceName) to \(targetName). Return ONLY the translated text, no explanations or other text."
        
        let body: [String: Any] = [
            "model": modelName,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": "Translate to \(targetName):\n\(text)"]
            ],
            "stream": false
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        print("Sending request to: \(url.absoluteString)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("URLSession Error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "No Data", code: 0)))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if !(200...299).contains(httpResponse.statusCode) {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Error Response Body: \(responseString)")
                    }
                }
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    let response = TranslationResponse(text: content.trimmingCharacters(in: .whitespacesAndNewlines), from: source)
                    completion(.success(response))
                } else {
                    // Try to parse error message from API
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let error = json["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        completion(.failure(NSError(domain: "API Error: \(message)", code: 0)))
                    } else {
                        completion(.failure(NSError(domain: "Invalid API Response", code: 0)))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
