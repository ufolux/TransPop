import Foundation

struct BingConfig {
    let ig: String
    let iid: String
    let key: Double
    let token: String
    let tokenTs: Double
    let tokenExpiryInterval: Double
    var count: Int
}

class BingWebTranslator {
    static let shared = BingWebTranslator()
    
    private var config: BingConfig?
    private let userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 Edg/122.0.0.0"
    private var websiteEndpoint = "https://www.bing.com/translator"
    private var translateEndpoint = "https://www.bing.com/ttranslatev3?isVertical=1"
    
    private init() {}
    
    func translate(text: String, from: String, to: String, completion: @escaping (Result<TranslationResponse, Error>) -> Void) {
        ensureConfig { [weak self] result in
            switch result {
            case .success(let config):
                self?.performTranslation(text: text, from: from, to: to, config: config, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func ensureConfig(completion: @escaping (Result<BingConfig, Error>) -> Void) {
        if let config = config, !isTokenExpired(config) {
            completion(.success(config))
            return
        }
        
        fetchGlobalConfig(completion: completion)
    }
    
    private func isTokenExpired(_ config: BingConfig) -> Bool {
        return Date().timeIntervalSince1970 * 1000 - config.tokenTs > config.tokenExpiryInterval
    }
    
    private func fetchGlobalConfig(completion: @escaping (Result<BingConfig, Error>) -> Void) {
        guard let url = URL(string: websiteEndpoint) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Handle Redirects / Domain Update
            if let httpResponse = response as? HTTPURLResponse,
               let url = httpResponse.url,
               let host = url.host {
                let scheme = url.scheme ?? "https"
                self?.websiteEndpoint = "\(scheme)://\(host)/translator"
                self?.translateEndpoint = "\(scheme)://\(host)/ttranslatev3?isVertical=1"
            }
            
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "No Data", code: 0)))
                return
            }
            
            do {
                let config = try self?.parseConfig(from: html)
                self?.config = config
                if let config = config {
                    completion(.success(config))
                } else {
                    completion(.failure(NSError(domain: "Failed to parse config", code: 0)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func parseConfig(from html: String) throws -> BingConfig {
        // Extract IG
        guard let igRange = html.range(of: "IG:\"([^\"]+)\"", options: .regularExpression),
              let igMatch = html[igRange].components(separatedBy: "\"").dropFirst().first else {
            throw NSError(domain: "Could not find IG", code: 0)
        }
        let ig = String(igMatch)
        
        // Extract IID
        // Note: IID might be in data-iid attribute
        var iid = "translator.5028" // Fallback
        if let iidRange = html.range(of: "data-iid=\"([^\"]+)\"", options: .regularExpression),
           let iidMatch = html[iidRange].components(separatedBy: "\"").dropFirst().first {
            iid = String(iidMatch)
        }
        
        // Extract params_AbusePreventionHelper
        // Format: params_AbusePreventionHelper = [key, "token", expiry]
        guard let paramsRange = html.range(of: "params_AbusePreventionHelper\\s?=\\s?([^]]+])", options: .regularExpression) else {
             throw NSError(domain: "Could not find params_AbusePreventionHelper", code: 0)
        }
        
        let paramsString = String(html[paramsRange])
            .components(separatedBy: "=").last?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Simple JSON parsing of the array [123, "token", 3600000]
        guard let data = paramsString.data(using: .utf8),
              let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [Any],
              jsonArray.count >= 3,
              let key = jsonArray[0] as? Double,
              let token = jsonArray[1] as? String,
              let expiry = jsonArray[2] as? Double else {
             throw NSError(domain: "Could not parse params array", code: 0)
        }
        
        return BingConfig(
            ig: ig,
            iid: iid,
            key: key,
            token: token,
            tokenTs: key, // The key seems to be the timestamp
            tokenExpiryInterval: expiry,
            count: 0
        )
    }
    
    private func performTranslation(text: String, from: String, to: String, config: BingConfig, completion: @escaping (Result<TranslationResponse, Error>) -> Void) {
        // Update count
        var currentConfig = config
        currentConfig.count += 1
        self.config = currentConfig
        
        // Use SFX (Side Effect? / Suffix?) parameter which seems to be required for most requests
        // This mimics the 'canUseEPT' path in the Node.js library
        let urlString = "\(translateEndpoint)&IG=\(config.ig)&IID=\(config.iid)&SFX=\(currentConfig.count)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid API URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(websiteEndpoint, forHTTPHeaderField: "Referer")
        
        // Add cookies from the config request
        if let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: websiteEndpoint)!) {
            let headers = HTTPCookie.requestHeaderFields(with: cookies)
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Map 'auto' to 'auto-detect'
        var fromLang = (from == "auto") ? "auto-detect" : from
        var toLang = to
        
        // Map Chinese codes to Bing standard
        if fromLang == "zh-CN" { fromLang = "zh-Hans" }
        if fromLang == "zh-TW" { fromLang = "zh-Hant" }
        if toLang == "zh-CN" { toLang = "zh-Hans" }
        if toLang == "zh-TW" { toLang = "zh-Hant" }
        
        // Body parameters
        // Order matters for some APIs, so we'll enforce it
        let orderedKeys = ["fromLang", "to", "text", "token", "key", "tryFetchingGenderDebiasedTranslations"]
        let bodyParams = [
            "text": text,
            "fromLang": fromLang,
            "to": toLang,
            "token": config.token,
            "key": String(format: "%.0f", config.key),
            "tryFetchingGenderDebiasedTranslations": "true"
        ]
        
        let bodyString = orderedKeys.map { key in
            let value = bodyParams[key] ?? ""
            let encodedKey = key.percentEncoded()
            let encodedValue = value.percentEncoded()
            return "\(encodedKey)=\(encodedValue)"
        }.joined(separator: "&")
        
        request.httpBody = bodyString.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0)))
                return
            }
            
            // Response is JSON: [{"detectedLanguage":{"language":"en","score":1.0},"translations":[{"text":"...","to":"zh-Hans"}]}]
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
                   let firstItem = json.first,
                   let translations = firstItem["translations"] as? [[String: Any]],
                   let firstTranslation = translations.first,
                   let translatedText = firstTranslation["text"] as? String {
                    
                    var detectedSource = from
                    if let detected = firstItem["detectedLanguage"] as? [String: Any],
                       let lang = detected["language"] as? String {
                        detectedSource = lang
                    }
                    
                    let response = TranslationResponse(text: translatedText, from: detectedSource)
                    completion(.success(response))
                } else {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Bing API Error Response: \(responseString)")
                    }
                    completion(.failure(NSError(domain: "Invalid Bing API Response", code: 0)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

extension String {
    func percentEncoded() -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return self.addingPercentEncoding(withAllowedCharacters: allowed) ?? self
    }
}
