import UIKit
import Combine

class ColorLoader: ObservableObject {
    static let shared = ColorLoader()
    
    @Published var lastUpdated = Date()
    
    private let defaults = UserDefaults.standard
    private let storageKey = "CachedDesignTokens"
    private let jsonURL = URL(string: "https://raw.githubusercontent.com/sanggab/DesignTokens/main/tokens.json")!
    
    private var cachedTokens: [String: String] = [:]
    
    init() {
        if let savedData = defaults.dictionary(forKey: storageKey) as? [String: String] {
            self.cachedTokens = savedData
            print("💾 Loaded \(savedData.count) tokens from local cache")
        }
        
        fetchLatestTokens()
    }
    
    func getColorHex(named key: String) -> String? {
        return cachedTokens[key]
    }
    
    func getCGFloat(named key: String) -> CGFloat? {
        guard let value = cachedTokens[key] else { return nil }
        return CGFloat(Double(value.replacingOccurrences(of: "px", with: "")) ?? 0)
    }
    
    func getString(named key: String) -> String? {
        return cachedTokens[key]
    }
    
    func fetchLatestTokens() {
        let urlString = "https://raw.githubusercontent.com/sanggab/DesignTokens/main/tokens.json?t=\(Date().timeIntervalSince1970)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        print("🎨 Fetching tokens from: \(urlString)")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Failed to fetch tokens: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🎨 Network Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else { return }
            
            self.parseAndSaveTokens(data: data)
        }.resume()
    }
    
    private func convertToHex(_ value: String) -> String {
        if value.lowercased().hasPrefix("rgb") {
            let pattern = "rgba?\\s*\\(\\s*(\\d+)\\s*,\\s*(\\d+)\\s*,\\s*(\\d+)\\s*(?:,\\s*([0-9.]+)\\s*)?\\)"
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                if let match = regex.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.utf16.count)) {
                    let nsString = value as NSString
                    let r = Int(nsString.substring(with: match.range(at: 1))) ?? 0
                    let g = Int(nsString.substring(with: match.range(at: 2))) ?? 0
                    let b = Int(nsString.substring(with: match.range(at: 3))) ?? 0
                    
                    var a: Int = 255
                    if match.range(at: 4).location != NSNotFound {
                        let aDouble = Double(nsString.substring(with: match.range(at: 4))) ?? 1.0
                        a = Int(aDouble * 255)
                    }
                    
                    return String(format: "#%02X%02X%02X%02X", a, r, g, b)
                }
            } catch {
                print("Regex error: \(error)")
            }
        }
        return value
    }

    private func parseAndSaveTokens(data: Data) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
            print("상갑 logEvent \(#function) json \(json)")
            
            // 1. Flatten all leaf tokens into a map (path -> rawValue)
            var rawTokens: [String: String] = [:]
            
            func collectLeaves(_ node: [String: Any], prefix: String) {
                for (key, value) in node {
                    if key.lowercased().contains("metadata") || key == "$themes" { continue }
                    
                    let currentPath = prefix.isEmpty ? key : "\(prefix).\(key)"
                    
                    if let item = value as? [String: Any],
                       let _ = item["type"] as? String {
                        
                        if let val = item["value"] as? String {
                            rawTokens[currentPath] = val
                        } else if let valDict = item["value"] as? [String: Any] {
                            // Composite value (e.g. boxShadow)
                            for (subKey, subVal) in valDict {
                                let subPath = "\(currentPath).\(subKey)"
                                if let subValStr = subVal as? String {
                                    rawTokens[subPath] = subValStr
                                } else if let subValNum = subVal as? NSNumber {
                                    rawTokens[subPath] = "\(subValNum)"
                                }
                            }
                        } else if let valNum = item["value"] as? NSNumber {
                             rawTokens[currentPath] = "\(valNum)"
                        }
                        
                    } else if let subNode = value as? [String: Any] {
                        collectLeaves(subNode, prefix: currentPath)
                    }
                }
            }
            
            collectLeaves(json, prefix: "")
            
            // 2. Resolve references
            var resolvedTokens: [String: String] = [:]
            
            func resolve(_ value: String) -> String {
                if value.hasPrefix("{") && value.hasSuffix("}") {
                    let key = String(value.dropFirst().dropLast())
                    
                    // Try direct match in rawTokens
                    if let refVal = rawTokens[key] {
                        return resolve(refVal)
                    }
                    
                    // Fallback: Fuzzy search (suffix match)
                    // Needed for references like {amber.friend} -> asset.amber.friend
                    for (path, val) in rawTokens {
                        if path.hasSuffix("." + key) || path == key {
                            return resolve(val)
                        }
                    }
                }
                return value
            }
            
            for (key, rawValue) in rawTokens {
                resolvedTokens[key] = convertToHex(resolve(rawValue))
            }
            
            self.cachedTokens = resolvedTokens
            self.defaults.set(resolvedTokens, forKey: self.storageKey)
            print("Tokens updated from GitHub! (Total: \(resolvedTokens.count))")
            
            DispatchQueue.main.async {
                self.lastUpdated = Date()
            }
        } catch {
            print("Failed to parse tokens: \(error)")
        }
    }
}
