import Foundation

struct TranslationResponse: Codable {
    let text: String
    let from: String
}

class TranslationService {
    static let shared = TranslationService()
    
    func translate(text: String, source: String, target: String, completion: @escaping (Result<TranslationResponse, Error>) -> Void) {
        let provider = UserDefaults.standard.string(forKey: "apiProvider") ?? "googleFree"
        
        if provider == "openaiCompatible" {
            translateWithOpenAI(text: text, source: source, target: target, completion: completion)
        } else {
            translateWithGoogleFree(text: text, source: source, target: target, completion: completion)
        }
    }
    
    private func translateWithGoogleFree(text: String, source: String, target: String, completion: @escaping (Result<TranslationResponse, Error>) -> Void) {
        // Using the same unofficial API as google-translate-api-x
        // Note: This is a simplified version and might need token generation or a different endpoint
        // For a native app, using a proper API key is recommended, but we'll try to mimic the free one
        // or use a public endpoint if available.
        // Actually, google-translate-api-x uses complex logic to generate tokens.
        // Replicating that in Swift is hard without a library.
        // For this demo, we might need to use a simpler endpoint or mock it, 
        // OR ask the user to provide an API Key for DeepL/Google.
        // Let's try a simple public endpoint often used for testing:
        // https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=en&dt=t&q=...
        
        var components = URLComponents(string: "https://translate.googleapis.com/translate_a/single")!
        components.queryItems = [
            URLQueryItem(name: "client", value: "gtx"),
            URLQueryItem(name: "sl", value: source),
            URLQueryItem(name: "tl", value: target),
            URLQueryItem(name: "dt", value: "t"),
            URLQueryItem(name: "q", value: text)
        ]
        
        guard let url = components.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0)))
                return
            }
            
            // The response is a nested JSON array: [[["Translated Text", "Source Text", ...], ["Segment 2", ...]], "auto", ...]
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [Any],
                   let firstBlock = json.first as? [[Any]] {
                    
                    // Join all segments
                    let translatedText = firstBlock.compactMap { segment -> String? in
                        return segment.first as? String
                    }.joined()
                    
                    let detectedSource = (json.count > 2) ? (json[2] as? String) ?? source : source
                    
                    let response = TranslationResponse(text: translatedText, from: detectedSource)
                    completion(.success(response))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON Structure", code: 0)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func translateWithOpenAI(text: String, source: String, target: String, completion: @escaping (Result<TranslationResponse, Error>) -> Void) {
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
