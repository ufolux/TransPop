import Foundation

class GoogleTranslator {
    static let shared = GoogleTranslator()
    
    private init() {}
    
    func translate(text: String, source: String, target: String, completion: @escaping (Result<TranslationResponse, Error>) -> Void) {
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
}
