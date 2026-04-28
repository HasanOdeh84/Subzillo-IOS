import Foundation

class SerpDiscoveryService {
    static let shared = SerpDiscoveryService()
    
    private let apiKey = AgentConfig.serpAPIKey
    
    func fetchLoginUrls(serviceName: String) async -> [String] {
        guard !apiKey.isEmpty else { 
            print("🌐 SerpDiscovery: API Key is empty, skipping.")
            return [] 
        }
        
        let query = "\(serviceName) login url"
        var components = URLComponents(string: "https://serpapi.com/search")!
        components.queryItems = [
            URLQueryItem(name: "engine", value: "google"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "num", value: "5"),
            URLQueryItem(name: "hl", value: "en")
        ]
        
        guard let url = components.url else { return [] }
        
        print("🌐 SerpDiscovery: Fetching login URLs for: \(serviceName)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return []
            }
            
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let results = json["organic_results"] as? [[String: Any]] else {
                return []
            }
            
            var rawUrls: [String] = []
            for result in results {
                if let link = result["link"] as? String {
                    rawUrls.append(link)
                }
            }
            
            // 🧠 Intent Scoring Engine (Ported from Android with Domain Match Bonus)
            let scoredUrls = rawUrls.map { url -> (url: String, score: Int) in
                var score = 0
                let lowUrl = url.lowercased()
                
                // 1. Strong Positive (Direct Login)
                if lowUrl.contains("login") || lowUrl.contains("signin") || lowUrl.contains("sign-in") {
                    score += 20
                }
                
                // 2. Medium Positive (Account/Profile)
                if lowUrl.contains("mypage") || lowUrl.contains("account") || 
                   lowUrl.contains("membership") || lowUrl.contains("profile") {
                    score += 10
                }
                
                // 3. Official Domain Match Bonus (Intelligence Enhancement)
                let cleanService = serviceName.lowercased().replacingOccurrences(of: " ", with: "")
                if lowUrl.contains(cleanService) {
                    score += 50 // Massive bonus for being on the official domain
                }
                
                // 4. Hard Negatives (Filtering noise)
                if lowUrl.contains("help") || lowUrl.contains("support") || lowUrl.contains("faq") ||
                   lowUrl.contains("blog") || lowUrl.contains("news") || lowUrl.contains("forum") ||
                   lowUrl.contains("quora") || lowUrl.contains("reddit") {
                    score -= 40
                }
                
                // 5. Neutral Homepages
                if lowUrl.hasSuffix(".com/") || lowUrl.hasSuffix(".com/in") || lowUrl.hasSuffix(".in/") {
                    score -= 5
                }
                
                // 6. Path Depth Check
                let components = url.components(separatedBy: "/")
                if components.count <= 5 {
                    score += 5 // Prefer shallow login pages
                }
                
                return (url, score)
            }
            
            // Sort by score DESC
            let sorted = scoredUrls.sorted { $0.score > $1.score }
            
            for item in sorted {
                print("🌐 SerpDiscovery: Ranked URL: \(item.url) (Score: \(item.score))")
            }
            
            return sorted.map { $0.url }
            
        } catch {
            print("🌐 SerpDiscovery: Error during discovery: \(error.localizedDescription)")
            return []
        }
    }
}
