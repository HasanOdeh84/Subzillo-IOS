import Foundation

/// Handles persistence of Agent-related data (like cached service URLs) using the Documents directory.
class AgentStorageManager {
    static let shared = AgentStorageManager()
    
    private let fileName = "agent_service_details.json"
    
    private var fileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(fileName)
    }
    
    private init() {}
    
    /// Loads all cached service details from the documents directory.
    func getAllServiceDetails() -> [ServiceDetails] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }
        do {
            return try JSONDecoder().decode([ServiceDetails].self, from: data)
        } catch {
            print("AgentStorageManager: Failed to decode service details: \(error)")
            return []
        }
    }
    
    /// Gets specific service details by name.
    func getServiceDetails(for serviceName: String) -> ServiceDetails? {
        let all = getAllServiceDetails()
        return all.first { $0.serviceName.lowercased() == serviceName.lowercased() }
    }
    
    /// Inserts or updates service details in the cache.
    func saveServiceDetails(_ details: ServiceDetails) {
        var all = getAllServiceDetails()
        
        // Remove existing if any
        all.removeAll { $0.serviceName.lowercased() == details.serviceName.lowercased() }
        
        // Add new
        all.append(details)
        
        save(all)
    }
    
    private func save(_ details: [ServiceDetails]) {
        do {
            let data = try JSONEncoder().encode(details)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        } catch {
            print("AgentStorageManager: Failed to save service details: \(error)")
        }
    }
}
