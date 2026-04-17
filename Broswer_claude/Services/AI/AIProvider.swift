// AIProvider.swift
// Protocol defining the standard interface for LLM providers.

import Foundation
import UIKit

protocol AIProvider {
    /// Extracts service name and intent from a message.
    func parseIntent(from input: String) async throws -> (serviceName: String?, intent: String?)
    
    /// Resolves the official login URL for a service.
    func resolveStartURL(service: String) async throws -> ServiceURLs
    
    /// Resolves the official billing/pricing URL for a service.
    func resolveBillingURL(service: String) async throws -> ServiceURLs
    
    /// Determines the next automation step based on the browser state.
    func nextAction(
        task: AgentTask,
        currentURL: String,
        snapshot: PageSnapshot,
        screenshot: UIImage?,
        history: [String],
        knownRoute: LearnedRoute?,
        collectedSoFar: String,
        stepNumber: Int
    ) async throws -> AgentAction
}
