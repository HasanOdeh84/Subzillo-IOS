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
    static let serpAPIKey = "" // Add your key here
}
