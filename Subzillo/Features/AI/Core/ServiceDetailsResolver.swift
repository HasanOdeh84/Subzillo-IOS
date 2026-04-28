import Foundation

class ServiceDetailsResolver {
    let aiService: AgentAIService
    let storage: AgentStorageManager
    
    init(aiService: AgentAIService = .shared, storage: AgentStorageManager = .shared) {
        self.aiService = aiService
        self.storage = storage
    }
    
    func resolve(prompt: String, onProgress: (String) -> Void) async throws -> ServiceDetails {
        onProgress("Resolving service name...")
        guard let serviceName = try await aiService.resolveServiceName(query: prompt) else {
            onProgress("Failed to resolve service name.")
            return ServiceDetails(serviceName: "", loginUrl: "", billingUrl: "")
        }
        
        // 1. Check Memory/Cache
        if let cached = storage.getServiceDetails(for: serviceName) {
            onProgress("Found details in memory.")
            return cached
        }
        
        // 2. Search for the Service Domain
        onProgress("Discovering \(serviceName)...")
        let serpUrls = await SerpDiscoveryService.shared.fetchLoginUrls(serviceName: serviceName)
        
        // --- BRAND PREFERENCE FILTER ---
        // We prefer a URL that matches the brand domain over a generic SSO portal
        let brandDomainUrl = serpUrls.first { url in
            let lowUrl = url.lowercased()
            let lowService = serviceName.lowercased()
            // If the URL contains the brand name and isn't a generic accounts portal, it's our winner
            return lowUrl.contains(lowService) && !lowUrl.contains("accounts.google") && !lowUrl.contains("appleid.apple")
        }
        
        let startUrl = brandDomainUrl ?? serpUrls.first ?? ""
        
        if !startUrl.isEmpty {
            let result = ServiceDetails(serviceName: serviceName, loginUrl: startUrl, billingUrl: "")
            storage.saveServiceDetails(result)
            return result
        }
        
        // 3. Fallback to AI API Knowledge
        onProgress("Fetching details from AI for \(serviceName)...")
        
        let loginUrl = try await aiService.resolveLoginUrl(serviceName: serviceName) ?? ""
        print("🤖 Agent: Login URL resolved via AI API for [\(serviceName)]: \(loginUrl)")
        
        let result = ServiceDetails(serviceName: serviceName, loginUrl: loginUrl, billingUrl: "")
        
        if !loginUrl.isEmpty {
            storage.saveServiceDetails(result)
        }
        
        return result
    }
}
