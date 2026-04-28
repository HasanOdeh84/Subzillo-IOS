import Foundation
import WebKit
import Combine

@MainActor
class AgentViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isAgentRunning: Bool = false
    @Published var currentStatus: String = ""
    @Published var needsIntervention: Bool = false
    @Published var showBrowser: Bool = false
    
    let browser: AgentBrowserController
    let orchestrator: AgentOrchestrator
    let resolver: ServiceDetailsResolver
    
    @Published var displayMessage: String = ""
    @Published var isInitialLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let b = AgentBrowserController()
        self.browser = b
        self.orchestrator = AgentOrchestrator(browser: b)
        self.resolver = ServiceDetailsResolver()
        
        setupOrchestratorObservation()
        addSystemMessage("Hello! I am the Subzillo Subscription Agent. Tell me which subscription you want me to find billing details for.")
    }
    
    private func setupOrchestratorObservation() {
        orchestrator.updates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                guard let self = self else { return }
                switch update {
                case .status(let text):
                    self.currentStatus = text
                    self.updateDisplayMessage(text)
                    // Log landmarks
                    let landmarks = ["starting", "navigating", "resetting", "completed", "failed"]
                    if landmarks.contains(where: { text.lowercased().contains($0) }) {
                        self.addSystemMessage(text)
                    }
                case .completed(let fields):
                    self.isAgentRunning = false
                    self.showBrowser = false
                    self.currentStatus = "Task completed!"
                    self.displayMessage = ""
                    self.addMessage(sender: .agent, text: fields.status ?? "Details found!", fields: fields)
                case .failed(let error):
                    self.isAgentRunning = false
                    self.showBrowser = false
                    self.currentStatus = "Error: \(error)"
                    self.displayMessage = ""
                    self.addMessage(sender: .agent, text: "Task failed: \(error)", isError: true)
                case .needsIntervention(let message):
                    self.needsIntervention = true
                    self.currentStatus = message
                    self.updateDisplayMessage(message, isPrompt: true)
                    self.addSystemMessage("Action Required: \(message)")
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateDisplayMessage(_ text: String, isPrompt: Bool = false) {
        // We now trust the AI to send the correct standardized message based on the updated system prompt.
        displayMessage = text
    }
    
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        addMessage(sender: .user, text: text)
        
        if isAgentRunning {
            addSystemMessage("Agent is already working. Please wait.")
            return
        }
        
        isAgentRunning = true
        currentStatus = "Analyzing..."
        
        Task {
            do {
                let details = try await resolver.resolve(prompt: text) { progress in
                    DispatchQueue.main.async { self.currentStatus = progress }
                }
                
                if details.serviceName.isEmpty {
                    await MainActor.run {
                        self.addSystemMessage("Could not identify the service.")
                        self.isAgentRunning = false
                        self.showBrowser = false
                    }
                    return
                }
                
                // Success! Now we show the browser
                await MainActor.run {
                    self.showBrowser = true
                }
                
                // Determine intent
                let upgradeWords = ["upgrade", "buy", "purchase", "change", "downgrade"]
                let cancelWords = ["cancel", "stop", "unsubscribe"]
                
                var intent: AgentTaskIntent = .getDetails
                if upgradeWords.contains(where: { text.lowercased().contains($0) }) { intent = .changePlan }
                else if cancelWords.contains(where: { text.lowercased().contains($0) }) { intent = .cancelSubscription }
                
                let task = AgentTask(
                    rawServiceName: details.serviceName.lowercased(),
                    displayName: details.serviceName,
                    intent: intent,
                    loginURL: details.loginUrl
                )
                
                await orchestrator.start(task: task)
            } catch let error as AgentAIService.AgentAIError {
                let errorMessage: String
                switch error {
                case .apiError(_, let message):
                    errorMessage = "AI API Error: \(message)"
                default:
                    errorMessage = "AI Service is temporarily unavailable."
                }
                
                await MainActor.run {
                    self.addMessage(sender: .system, text: errorMessage, isError: true)
                    self.isAgentRunning = false
                    self.showBrowser = false
                }
            } catch {
                await MainActor.run {
                    self.addMessage(sender: .system, text: "System Error: \(error.localizedDescription)", isError: true)
                    self.isAgentRunning = false
                    self.showBrowser = false
                }
            }
        }
    }
    
    func resume() {
        needsIntervention = false
        orchestrator.resume()
    }
    
    func cancel() {
        orchestrator.stop()
        isAgentRunning = false
        needsIntervention = false
        showBrowser = false
        currentStatus = ""
        addSystemMessage("Automation cancelled.")
    }
    
    private func addMessage(sender: ChatSender, text: String, fields: ExtractedFields? = nil, isError: Bool = false) {
        let msg = ChatMessage(sender: sender, text: text, extractedFields: fields, isError: isError)
        messages.append(msg)
    }
    
    private func addSystemMessage(_ text: String) {
        addMessage(sender: .system, text: text)
    }
}
