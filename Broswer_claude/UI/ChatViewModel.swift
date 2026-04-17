// ChatViewModel.swift

import Foundation
import SwiftUI
import Combine

@MainActor
final class ChatViewModel: ObservableObject {

    @Published var messages: [ChatMessage]   = []
    @Published var inputText: String         = ""
    @Published var showBrowser: Bool         = false
    @Published var isProcessing: Bool        = false

    let agent = AgentOrchestrator()

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Wire up completion callbacks
        agent.onTaskComplete = { [weak self] result, fields in
            Task { @MainActor in
                self?.showBrowser  = false
                self?.isProcessing = false
                if let fields = fields {
                    self?.appendSubscriptionResult(fields)
                } else {
                    self?.appendAssistant(result)
                }
            }
        }
        agent.onTaskFailed = { [weak self] error in
            Task { @MainActor in
                self?.showBrowser  = false
                self?.isProcessing = false
                self?.appendAssistant("Something went wrong: \(error)")
            }
        }

        // Welcome message
        appendAssistant(
            "Hi! I'm your Subzillo AI assistant.\n\n" +
            "Tell me which subscription to look up and I'll handle the rest. For example:\n" +
            "• \"Add my Netflix subscription\"\n" +
            "• \"Retrieve my Spotify billing details\"\n" +
            "• \"Get my Manus AI subscription info\"\n\n" +
            "I work with 500+ services — just name it!"
        )

        // Mirror agent status into chat
        agent.$statusText
            .dropFirst()
            .filter { !$0.isEmpty }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.appendSystem(text)
            }
            .store(in: &cancellables)
    }

    // MARK: - Send message

    func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        appendUser(text)

        // Don't process new commands while waiting for user action
        switch agent.state {
        case .waitingForLogin, .waitingForConfirmation, .resolvingURL, .parsingIntent:
            return
        default:
            break
        }

        /*
        // 1. Try fast local regex parsing
        if let task = IntentParser.parse(text) {
            startTask(task)
            return
        }
         */

        // 2. Fall back to AI-powered intent parsing
        isProcessing = true
        appendSystem("Understanding your request…")

        Task {
            if var task = await IntentParser.parseWithAI(text) {
                // 1. Check Memory first, then Parallel fetch Login & Billing URLs
                appendSystem("Discovery: Checking memory for \(task.displayName)…")
                print("Discovery: Checking memory for \(task.displayName)…")
                
                let knownRoute = NavigationMemory.shared.route(for: task.rawServiceName)
                let memoryLogin = (knownRoute?.loginURL != nil && !knownRoute!.loginURL.isEmpty) ? knownRoute?.loginURL : nil
                let memoryBilling = knownRoute?.bestBillingURL

                var resolvedLogin: String? = memoryLogin
                var resolvedBilling: String? = memoryBilling
                
                if resolvedLogin == nil || resolvedBilling == nil {
                    if resolvedLogin == nil && resolvedBilling == nil {
                        appendSystem("Discovery: Finding official login and billing pages via AI…")
                    } else if resolvedLogin == nil {
                        appendSystem("Discovery: Finding login page via AI…")
                    } else {
                        appendSystem("Discovery: Finding billing page via AI…")
                    }
                    
                    let aiService = AIService()
                    
                    // Only fetch what we don't already have in memory
                    async let aiLoginRes: ServiceURLs? = (resolvedLogin == nil) 
                        ? try? await aiService.resolveStartURL(service: task.rawServiceName) 
                        : nil
                    async let aiBillingRes: ServiceURLs? = (resolvedBilling == nil) 
                        ? try? await aiService.resolveBillingURL(service: task.rawServiceName) 
                        : nil
                    
                    let (aiLogin, aiBilling) = await (aiLoginRes, aiBillingRes)
                    
                    if let al = aiLogin?.loginURL { resolvedLogin = al }
                    if let ab = aiBilling?.billingURL { resolvedBilling = ab }
                } else {
                    appendSystem("Discovery: Using learned paths from memory.")
                }
                
                // 2. Persist both to internal memory (updates if we found something new)
                let finalDisplayName = knownRoute?.displayName ?? task.displayName
                NavigationMemory.shared.recordResolvedURLs(
                    service: task.rawServiceName,
                    displayName: finalDisplayName,
                    loginURL: resolvedLogin,
                    billingURL: resolvedBilling
                )
                
                // 3. Update task with resolved URLs
                task.resolvedURLs = ServiceURLs(
                    loginURL: resolvedLogin,
                    billingURL: resolvedBilling,
                    displayName: finalDisplayName
                )
                
                // Refresh known route from memory (since we just saved/updated)
                task.knownRoute = NavigationMemory.shared.route(for: task.rawServiceName)
                
                self.startTask(task)
            } else {
                self.isProcessing = false
                self.appendAssistant(
                    "I couldn't identify a service in your message.\n" +
                    "Try something like: \"Get my Netflix billing details\" or \"Add my Dropbox subscription\"."
                )
            }
        }
    }

    private func startTask(_ task: AgentTask) {
        showBrowser  = true
        isProcessing = true

        if task.knownRoute != nil {
            appendSystem("I've seen this service before — using learned path for faster navigation.")
        }

        // Wait for the sheet to fully present and the WKWebView to get a real frame
        // before starting the agent (which navigates immediately).
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)  // 0.6s for sheet animation
            await self.agent.start(task: task)
            self.isProcessing = false
        }
    }

    // MARK: - Browser overlay actions

    func userDidLogin() {
        agent.userDidLogin()
        appendSystem("Resuming… AI is navigating.")
    }

    func userConfirmed() {
        agent.userDidConfirm(true)
    }

    func userDenied() {
        agent.userDidConfirm(false)
        appendAssistant("Action cancelled.")
    }

    func cancelTask() {
        agent.cancel()
        isProcessing = false
        showBrowser  = false
        appendAssistant("Task cancelled.")
    }

    /// Switch to manual-navigation mode — user drives, AI watches and learns.
    func enterManualMode() {
        agent.enterManualMode()
        appendSystem("Manual mode: navigate to your billing page, then tap \"Extract Now\".")
    }

    /// Trigger extraction from the page the user manually navigated to.
    func extractNow() {
        Task {
            await agent.extractFromManualNavigation()
        }
    }

    // MARK: - Helpers

    func appendUser(_ text: String) {
        messages.append(ChatMessage(sender: .user, text: text))
    }

    func appendAssistant(_ text: String) {
        messages.append(ChatMessage(sender: .assistant, text: text))
    }

    func appendSystem(_ text: String) {
        messages.append(ChatMessage(sender: .system, text: text))
    }

    func appendSubscriptionResult(_ fields: ExtractedFields) {
        var msg = ChatMessage(sender: .assistant, text: "Here's what I found:")
        msg.subscriptionData = fields
        messages.append(msg)
    }
}
