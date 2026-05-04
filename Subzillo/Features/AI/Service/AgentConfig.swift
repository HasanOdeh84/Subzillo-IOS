import Foundation

enum AIProviderType {
    case claude
    case chatGPT
}

struct AgentConfig {
    /// The currently active AI provider.
    static var activeProvider: AIProviderType = .claude
    
    /// Anthropic Claude API Key. TODO: Replace with secure storage or real key.
    static let claudeAPIKey = ""
    static let claudeModel = "claude-sonnet-4-6"
    
    /// OpenAI API Key. TODO: Replace with secure storage or real key.
    static let openAIAPIKey = ""
    static let openAIModel = "gpt-4o"
    
    /// Maximum tokens for AI response.
    static let maxTokens = 2048//1024
    
    /// SERP API Key for web discovery.
//    static let serpAPIKey = "08cffbda24ca015fb442ec5855d7b62c815e6b95e8e92c6619dc7800fd17ac1a" // Add your key here
    static let serpAPIKey = "" // Add your key here
}
