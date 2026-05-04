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
    @Published var isAgenticMode: Bool = false
    @Published var sessionId: String? = nil
    @Published var recordTime: TimeInterval = 0
    
    @Published var isRecordingAudio: Bool = false
    @Published var transcribedText: String = ""
    @Published var audioPower: Float = 0.1
    private let audioManager = AudioRecorderManager()
    @Published var conversationDbId: String? = nil
    @Published var conversationId: String? = nil
    @Published var isThinking: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        let b = AgentBrowserController()
        self.browser = b
        self.orchestrator = AgentOrchestrator(browser: b)
        self.resolver = ServiceDetailsResolver()
        
        setupOrchestratorObservation()
        
        audioManager.$recordTime
            .receive(on: DispatchQueue.main)
            .assign(to: \.recordTime, on: self)
            .store(in: &cancellables)
        
        audioManager.$audioPower
            .receive(on: DispatchQueue.main)
            .assign(to: \.audioPower, on: self)
            .store(in: &cancellables)
        
        Task {
            await fetchWelcomeMessage()
        }
    }
    
    //MARK: fetchWelcomeMessage
    private func fetchWelcomeMessage() async {
        do {
            let response = try await AgentAIService.shared.getWelcomeMessage()
            PrintLogger.modelLog(response, type: .response, isInput: false)
            await MainActor.run {
                self.sessionId = response.state?.session_id
                self.addMessage(sender: .agent, text: response.reply)
            }
            
            // Call conversations API after welcome
            let convResponse = try await AgentAIService.shared.createConversation(sessionId: response.state?.session_id)
            PrintLogger.modelLog(convResponse, type: .response, isInput: false)
            await MainActor.run {
                self.conversationDbId = convResponse.conversation_db_id
                self.conversationId = convResponse.conversation_id
            }
        } catch {
            print("Error fetching welcome message: \(error)")
            // Fallback message if API fails
            await MainActor.run {
                self.addMessage(sender: .agent, text: "👋 Hi! How can I help you today?")
            }
        }
    }
    
    //MARK: setupOrchestratorObservation
    private func setupOrchestratorObservation() {
        orchestrator.updates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                guard let self = self else { return }
                switch update {
                case .status(let text):
                    self.currentStatus = text
                    self.updateDisplayMessage(text)
                case .completed(let fields):
                    self.isAgentRunning = false
                    self.showBrowser = false
                    self.currentStatus = "Task completed!"
                    self.displayMessage = ""
                    let statusMessage = fields.status ?? "Details found!"
                    self.addMessage(sender: .agent, text: statusMessage, fields: fields)
                    
                    self.sendAgenticContext(message: statusMessage, provider: fields.serviceName ?? "Unknown")
                    
                    if let serviceName = fields.serviceName,
                       let cached = self.resolver.storage.getServiceDetails(for: serviceName),
                       !cached.isFromBackend {
                        self.addProviderUrlsApi(
                            providerId: "",
                            providerName: serviceName,
                            loginUrl: cached.loginUrl,
                            billingUrl: cached.billingUrl
                        )
                    }
                case .failed(let error):
                    guard self.isAgentRunning else { return }
                    self.isAgentRunning = false
                    self.showBrowser = false
                    self.currentStatus = "Error: \(error)"
                    self.displayMessage = ""
                    self.addMessage(sender: .agent, text: "Task failed: \(error)", isError: true)
                case .needsIntervention(let message):
                    self.needsIntervention = true
                    self.currentStatus = message
                    self.updateDisplayMessage(message, isPrompt: true)
                case .initialLoadStarted:
                    self.isInitialLoading = true
                case .initialLoadFinished:
                    self.isInitialLoading = false
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: updateDisplayMessage
    private func updateDisplayMessage(_ text: String, isPrompt: Bool = false) {
        // We now trust the AI to send the correct standardized message based on the updated system prompt.
        displayMessage = text
    }
    
    //MARK: - sendMessage
    func sendMessage(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        clearAllSuggestions()
        addMessage(sender: .user, text: text)
        
        if !isAgenticMode {
            // Standard Chatbot Mode
            isThinking = true
            Task {
                do {
                    let response = try await AgentAIService.shared.sendChatMessage(text: text, conversationId: conversationId ?? "")
                    PrintLogger.modelLog(response, type: .response, isInput: false)
                    await MainActor.run {
                        self.isThinking = false
                        self.addMessage(sender: .agent, text: response.reply ?? "I'm sorry, I couldn't process that.", suggestedReplies: response.suggested_replies ?? [])
                    }
                } catch {
                    await MainActor.run {
                        self.isThinking = false
                        self.addMessage(sender: .agent, text: "Error: \(error.localizedDescription)", isError: true)
                    }
                }
            }
            return
        }
        
        if isAgentRunning {
            addSystemMessage("Agent is already working. Please wait.")
            return
        }
        
        isAgentRunning = true
        currentStatus = "Analyzing..."
        
        Task {
            do {
                let gateAction = try await AgentAIService.shared.checkAgenticGate(prompt: text)
                PrintLogger.modelLog(gateAction, type: .response, isInput: false)
                if gateAction == "answer" {
                    print("🧠 Agent: Gate evaluated as 'answer'. Falling back to chatbot API.")
                    await MainActor.run {
                        self.isAgentRunning = false
                        self.currentStatus = ""
                        self.isThinking = true
                    }
                    
                    let response = try await AgentAIService.shared.sendChatMessage(text: text, conversationId: self.conversationId ?? "")
                    PrintLogger.modelLog(response, type: .response, isInput: false)
                    await MainActor.run {
                        self.isThinking = false
                        self.addMessage(sender: .agent, text: response.reply ?? "I'm sorry, I couldn't process that.", suggestedReplies: response.suggested_replies ?? [])
                    }
                    return
                }
                
                let details = try await resolver.resolve(prompt: text, agentViewModel: self) { progress in
                    DispatchQueue.main.async { self.currentStatus = progress }
                }
                
                print("🧠 Agent: Resolver returned ServiceName: [\(details.serviceName)], LoginURL: [\(details.loginUrl)]")
                
                if details.serviceName.isEmpty {
                    print("⚠️ Agent: Service name is empty. Aborting.")
                    await MainActor.run {
                        self.addMessage(sender: .agent, text: "Could not identify the service.")
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
                
                print("🚀 Agent: Starting task for \(task.displayName) (Intent: \(task.intent), URL: \(task.loginURL))")
                
                // Prepare browser for the new task while keeping login sessions
                await MainActor.run {
                    self.browser.prepareForNewTask {
                        Task {
                            await self.orchestrator.start(task: task)
                        }
                    }
                }
            } catch let error as AgentAIService.AgentAIError {
                let errorMessage: String
                switch error {
                case .apiError(_, let message):
                    errorMessage = "AI API Error: \(message)"
                default:
                    errorMessage = "AI Service is temporarily unavailable."
                }
                
                await MainActor.run {
                    self.addMessage(sender: .agent, text: errorMessage, isError: true)
                    self.isAgentRunning = false
                    self.showBrowser = false
                }
            } catch {
                await MainActor.run {
                    self.addMessage(sender: .agent, text: "System Error: \(error.localizedDescription)", isError: true)
                    self.isAgentRunning = false
                    self.showBrowser = false
                }
            }
        }
    }
    
    //MARK: resume
    func resume() {
        needsIntervention = false
        orchestrator.resume()
    }
    
    //MARK: startAudioRecording
    func startAudioRecording() {
        isRecordingAudio = true
        audioManager.startRecording()
    }
    
    //MARK: stopAudioRecording
    func stopAudioRecording() {
        isRecordingAudio = false
        audioManager.stopRecording()
        
        guard let url = audioManager.audioURL else { return }
        
        Task {
            do {
                let response = try await AgentAIService.shared.transcribeAudio(audioURL: url, conversationId: conversationId)
                PrintLogger.modelLog(response, type: .response, isInput: false)
                await MainActor.run {
                    self.transcribedText = response.transcript
                }
            } catch {
                print("❌ Transcription failed: \(error)")
                await MainActor.run {
                    self.addSystemMessage("Failed to transcribe audio. Please try again.")
                }
            }
        }
    }
    
    //MARK: cancelAudioRecording
    func cancelAudioRecording() {
        isRecordingAudio = false
        audioManager.discardAll()
    }
    
    //MARK: clearPendingSession
    func clearPendingSession() {
        guard let sid = conversationId else { return }
        Task {
            do {
                var response = try await AgentAIService.shared.clearPendingSession(sessionId: sid)
                PrintLogger.modelLog(response, type: .response, isInput: false)
            } catch {
                print("Error clearing pending session: \(error)")
            }
        }
    }
    
    //MARK: sendImage
    func sendImage(_ image: UIImage) {
        clearAllSuggestions()
        addMessage(sender: .user, text: "", image: image)
        isThinking = true
        
        Task {
            do {
                let response = try await AgentAIService.shared.sendChatImage(image: image, conversationId: conversationId ?? "")
                PrintLogger.modelLog(response, type: .response, isInput: false)
                await MainActor.run {
                    self.isThinking = false
                    self.addMessage(sender: .agent, text: response.reply ?? "I've received your image.", suggestedReplies: response.suggested_replies ?? [])
                }
            } catch {
                await MainActor.run {
                    self.isThinking = false
                    self.addMessage(sender: .agent, text: "Error uploading image: \(error.localizedDescription)", isError: true)
                }
            }
        }
    }
    
    //MARK: cancel
    func cancel() {
        guard isAgentRunning else { return }
        orchestrator.stop()
        isAgentRunning = false
        needsIntervention = false
        showBrowser = false
        currentStatus = ""
        addMessage(sender: .agent, text: "Agent execution cancelled")
    }
    
    //MARK: addMessage
    private func addMessage(sender: ChatSender, text: String, fields: ExtractedFields? = nil, image: UIImage? = nil, isError: Bool = false, suggestedReplies: [String] = []) {
        var finalReplies = suggestedReplies
        
        // Auto-detect replies if not provided by API
        if sender == .agent && finalReplies.isEmpty {
            finalReplies = QuickReplyDetector.detect(content: text)
        }
        
        var msg = ChatMessage(sender: sender, text: text, extractedFields: fields, isError: isError, suggestedReplies: finalReplies)
        if let image = image {
            msg.imageData = image.jpegData(compressionQuality: 0.5)
        }
        messages.append(msg)
    }
    
    func removeSuggestions(from messageId: String) {
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            messages[index].suggestedReplies = []
        }
    }
    
    func clearAllSuggestions() {
        for i in 0..<messages.count {
            if !messages[i].suggestedReplies.isEmpty {
                messages[i].suggestedReplies = []
            }
        }
    }
    
    private func addSystemMessage(_ text: String) {
        addMessage(sender: .system, text: text)
    }
    
    //MARK: sendAgenticContext
    func sendAgenticContext(message: String, provider: String, source: String = "mobile_agentic") {
        guard let cid = conversationId else { return }
        
        let metadata = AgenticContextMetadata(provider: provider, source: source)
        let request = AgenticContextRequest(
            conversation_id : cid,
            user_id         : Constants.getUserId(),
            message         : message,
            metadata        : metadata
        )
        
        Task {
            do {
                let response = try await AgentAIService.shared.sendAgenticContext(requestBody: request)
                PrintLogger.modelLog(response, type: .response, isInput: false)
                print("✅ Agentic context stored successfully. Session: \(response.session_id)")
            } catch {
                print("❌ Failed to send agentic context: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: fetchProviderUrlsApi
    func fetchProviderUrlsApi(providerName: String) async -> ProviderUrlData? {
        let requestBody = FetchProviderUrlsRequest(
            providerId: "",
            providerName: providerName,
            countryCode: Constants.getUserDefaultsValue(for: Constants.userIsoCountryCode)
        )
        
        do {
            let response = try await AgentAIService.shared.fetchProviderUrls(requestBody: requestBody)
            PrintLogger.modelLog(response, type: .response, isInput: false)
            return response.data
        } catch {
            print("❌ Failed to fetch provider URLs: \(error.localizedDescription)")
            return nil
        }
    }
    
    //MARK: addProviderUrlsApi
    func addProviderUrlsApi(providerId: String, providerName: String, loginUrl: String, billingUrl: String) {
        let requestBody = AddProviderUrlsRequest(
            providerId      : providerId,
            providerName    : providerName,
            countryCode     : Constants.getUserDefaultsValue(for: Constants.userIsoCountryCode),
            loginUrl        : loginUrl,
            billingUrl      : billingUrl
        )
        
        Task {
            do {
                let response = try await AgentAIService.shared.addProviderUrls(requestBody: requestBody)
                PrintLogger.modelLog(response, type: .response, isInput: false)
                print("✅ Provider URLs added successfully.")
            } catch {
                print("❌ Failed to add provider URLs: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: updateProviderUrlsApi
    func updateProviderUrlsApi(providerUrlId: String, loginUrl: String, billingUrl: String) {
        let requestBody = UpdateProviderUrlsRequest(
            providerUrlId: providerUrlId,
            loginUrl: loginUrl,
            billingUrl: billingUrl
        )
        
        Task {
            do {
                let response = try await AgentAIService.shared.updateProviderUrls(requestBody: requestBody)
                PrintLogger.modelLog(response, type: .response, isInput: false)
                print("✅ Provider URLs updated successfully.")
            } catch {
                print("❌ Failed to update provider URLs: \(error.localizedDescription)")
            }
        }
    }
}
