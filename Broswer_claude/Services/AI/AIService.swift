// AIService.swift
// Unified AI service wrapper — delegates to the active provider (Claude or ChatGPT).

import Foundation
import UIKit

final class AIService {
    
    private let provider: AIProvider
    
    init() {
        switch Config.activeProvider {
        case .claude:
            self.provider = ClaudeProvider()
        case .chatGPT:
            self.provider = ChatGPTProvider()
        }
    }
    
    // MARK: - Business Logic delegation
    
    func nextAction(
        task: AgentTask,
        currentURL: String,
        snapshot: PageSnapshot,
        screenshot: UIImage?,
        history: [String],
        knownRoute: LearnedRoute?,
        collectedSoFar: String,
        stepNumber: Int = 0
    ) async throws -> AgentAction {
        return try await provider.nextAction(
            task: task,
            currentURL: currentURL,
            snapshot: snapshot,
            screenshot: screenshot,
            history: history,
            knownRoute: knownRoute,
            collectedSoFar: collectedSoFar,
            stepNumber: stepNumber
        )
    }
    
    func parseIntent(from input: String) async throws -> (serviceName: String?, intent: String?) {
        return try await provider.parseIntent(from: input)
    }
    
    func resolveStartURL(service: String) async throws -> ServiceURLs {
        return try await provider.resolveStartURL(service: service)
    }
    
    func resolveBillingURL(service: String) async throws -> ServiceURLs {
        return try await provider.resolveBillingURL(service: service)
    }
}
