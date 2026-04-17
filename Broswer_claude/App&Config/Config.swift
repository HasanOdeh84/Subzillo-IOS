// Config.swift
// API configuration only — no hardcoded service URLs.
// All URL resolution is handled by AI at runtime.

import Foundation

enum AIProviderType {
    case claude
    case chatGPT
}

enum Config {
    // For pilot only — move to a backend proxy before production
    static let claudeAPIKey = ""
    static let claudeModel  = "claude-opus-4-6"//"claude-sonnet-4-6"
    static let maxTokens    = 2048
    
    static let chatGptAPIKey = ""
    static let chatGptModel  = "gpt-5.2" // or "gpt-4o"
    static let gptTokens    = 512

    // Switch this to change the AI engine across the entire app
    static let activeProvider: AIProviderType = .chatGPT
}
