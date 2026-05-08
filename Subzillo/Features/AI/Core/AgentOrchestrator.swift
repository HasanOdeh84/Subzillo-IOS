import Foundation
import Combine

enum AgentUpdate {
    case initialLoadStarted
    case initialLoadFinished
    case status(String)
    case completed(ExtractedFields)
    case failed(String)
    case needsIntervention(String)
}

class AgentOrchestrator: ObservableObject {
    let browser: AgentBrowserController
    let ai: AgentAIService
    
    private var automationTask: Task<Void, Never>?
    private let totalSteps = 30
    
    private let _updates = PassthroughSubject<AgentUpdate, Never>()
    var updates: AnyPublisher<AgentUpdate, Never> { _updates.eraseToAnyPublisher() }
    
    private var resumeContinuation: CheckedContinuation<Void, Never>?
    
    var isRunning = false
    private var isWaitingForUser = false
    private var collectedFields = ExtractedFields()
    private var history: [String] = []
    
    init(browser: AgentBrowserController, ai: AgentAIService = .shared) {
        self.browser = browser
        self.ai = ai
    }
    
    @MainActor
    func start(task: AgentTask) {
        stop()
        isRunning = true
        
        automationTask = Task {
            do {
                history.removeAll()
                collectedFields = ExtractedFields(serviceName: task.displayName)
                
                _updates.send(.initialLoadStarted)
                _updates.send(.status("Starting automation for \(task.displayName)..."))
                
                _updates.send(.status("Preparing browser..."))
                
                // Clean transition: stop previous site and wait for blank load
                browser.prepareForNewTask {
                    Task { @MainActor in
                        let targetUrl = !task.loginURL.isEmpty ? task.loginURL : ""
                        if !targetUrl.isEmpty {
                            self.browser.navigate(to: targetUrl)
                            await self.browser.waitForLoad()
                        }
                        self._updates.send(.initialLoadFinished)
                    }
                }
                
                // PRE-EMPTIVE LOGIN HANDOVER:
                // Stop immediately if we land on a page that looks like a login portal.
                let url = browser.currentURL.lowercased()
                let isAuthPage = ["login", "signin", "sign-in", "sign_in", "auth", "accounts.google.com", "accounts.apple.com"].contains { url.contains($0) }
                if isAuthPage {
                    print("🚪 Agent: Landed on auth page [\(url)]. Handing over to user.")
                    _updates.send(.needsIntervention("Please login to \(task.displayName) and solve any captchas. Click 'Reautomate' when finished."))
                    await suspendAutomation()
                }
                
                var lastStateHash: String? = nil
                var lastActionIsStateChanging = false
                var lastActionFailed = false
                
                var steps = 0
                while isRunning && steps < totalSteps {
                    steps += 1
                    _updates.send(.status("Analyzing page... (Step \(steps))"))
                    await browser.waitForLoad()
                    
                    // NATIVE CAPTCHA GUARD:
                    // Check for captchas BEFORE any snapshotting or AI calls.
                    if await browser.isCaptchaVisible() {
                        print("🛡️ Agent: Captcha detected. Freezing automation.")
                        _updates.send(.needsIntervention("Security check detected. Please solve the captcha manually and click 'Reautomate'."))
                        await suspendAutomation()
                        continue // Re-check after resume
                    }
                    
                    
                    // Final UI Stability Delay for accurate snapshots
                    try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds (Reduced from 1.5s for responsiveness)
                    
                    let snapshot = await browser.extractPageSnapshot()
                    print("📸 Agent Snapshot: [\(snapshot.text.prefix(200))...] | URL: \(browser.currentURL) | Elements: \(snapshot.elements.count)")
                    
                    // Improved Hash: Includes URL + Text Sample + Element Count + Scroll position to detect progress
                    let currentStateHash = "\(browser.currentURL)_\(snapshot.text.prefix(500))_\(snapshot.elements.count)_\(snapshot.scrollY ?? 0)"
                    
                    if lastActionIsStateChanging {
                        lastActionFailed = (currentStateHash == lastStateHash)
                    }
                    lastStateHash = currentStateHash
                    
                    guard let action = await ai.nextAction(
                        task: task,
                        currentURL: browser.currentURL,
                        snapshot: snapshot,
                        history: history,
                        knownRoute: task.knownRoute,
                        collectedSoFar: collectedFields.summary(),
                        lastActionFailed: lastActionFailed
                    ) else {
                        _updates.send(.failed("Failed to get action from AI."))
                        stop()
                        return
                    }
                    
                    let actionStr = "Action: \(action.action?.rawValue ?? "?") (Selector: \(action.selector ?? action.clickText ?? "?"))"
                    
                    print("🤖 Agent Chosen Action: \(actionStr)")
                    
                    let isStateChangingAction: [AgentActionType] = [.navigate, .click, .clickText, .type, .scroll]
                    if let type = action.action, isStateChangingAction.contains(type) {
                        lastActionIsStateChanging = true
                    } else {
                        lastActionIsStateChanging = false
                    }
                    
                    
                    // SMART LOOP DETECTION:
                    // We check if the exact same action has been repeated multiple times recently.
                    // Checking the last 6 actions allows us to catch oscillating loops (e.g., A -> B -> A -> B)
                    // and immediate loops (A -> A -> A).
                    if lastActionIsStateChanging {
                        let recentActions = history.suffix(6)
                        let repeats = recentActions.filter { $0 == actionStr }.count
                        
                        // If we see the same action 3 times in the last 6 steps, it's a loop.
                        if repeats >= 3 && steps > 3 {
                            _updates.send(.needsIntervention("Loop detected. The page isn't responding as expected. Please perform the action manually then click Reautomate."))
                            await suspendAutomation()
                            history.removeAll()
                            continue
                        }
                    }
                    
                    history.append(actionStr)
                    
                    _updates.send(.status("Executing: \(action.action?.rawValue ?? "action")..."))
                    
                    if try await executeAction(action, task: task, snapshot: snapshot, lastActionFailed: lastActionFailed) {
                        // Task finished normally through action execution (e.g. .done)
                        return
                    }
                }
                
                if steps >= totalSteps {
                    _updates.send(.failed("Step limit reached."))
                }
            } catch {
                _updates.send(.failed("Error: \(error.localizedDescription)"))
            }
            isRunning = false
        }
    }
    
    @MainActor
    private func executeAction(_ action: AgentAction, task: AgentTask, snapshot: PageSnapshot? = nil, lastActionFailed: Bool = false) async throws -> Bool {
        guard let type = action.action else { return false }
        
        switch type {
        case .navigate:
            if let url = action.url {
                browser.navigate(to: url)
                await browser.waitForLoad()
            }
        case .click, .clickText:
            var success = false
            
            // FUZZY COORDINATE FALLBACK:
            // If the last action failed, find the best element in the snapshot to tap physically.
            if lastActionFailed, let snapshot = snapshot {
                let targetText = action.clickText?.lowercased() ?? ""
                let targetSelector = action.selector
                let targetHref = action.url
                
                // Find by Selector (Exact) OR Text (Fuzzy) OR Href (Fuzzy)
                let element = snapshot.elements.first { el in
                    if let sel = targetSelector, el.selector == sel { return true }
                    if !targetText.isEmpty && el.text.lowercased().contains(targetText) { return true }
                    if let href = targetHref, !href.isEmpty && el.href.contains(href) { return true }
                    return false
                }
                
                if let el = element, let x = el.x, let y = el.y {
                    print("🎯 Agent: Physical Tap Fallback at (\(x), \(y)) for [\(el.text)]")
                    success = await browser.clickAt(x: x, y: y)
                }
            }
            
            if !success {
                success = await browser.click(selector: action.selector, text: action.clickText)
            }
            
            if success { await browser.waitForLoad() }
        case .type:
            if let sel = action.selector, let txt = action.text {
                _ = await browser.type(selector: sel, text: txt)
                await browser.waitForLoad()
            }
        case .scroll:
            await browser.scroll(y: action.scrollY ?? 400)
        case .extract:
            if let data = action.data {
                collectedFields.merge(data)
                _updates.send(.status("Extracted data: \(collectedFields.summary())"))
            }
        case .done:
            if let data = action.data { collectedFields.merge(data) }
            _updates.send(.completed(collectedFields))
            stop()
            return true
        case .askUser:
            _updates.send(.needsIntervention(action.message ?? "User intervention required."))
            await suspendAutomation()
        case .confirm:
            _updates.send(.status("Agent requested confirmation..."))
        }
        return false
    }
    
    func resume() {
        
        print("⏯ Agent: Resuming automation.")
        let wasIntervention = isWaitingForUser
        isWaitingForUser = false
        history.removeAll()
        
        Task { @MainActor in
            let url = browser.currentURL.lowercased()
            // Force reload if we were waiting for user (to sync session) or on a blank/callback page
            let shouldReload = wasIntervention || url.isEmpty || url == "about:blank" || url.contains("callback") || url.contains("auth")
            
            if shouldReload {
                print("⏯ Agent: Reloading to sync session after intervention/redirect.")
                browser.webView.reload()
                try? await Task.sleep(nanoseconds: 800_000_000)
            } else {
                print("⏯ Agent: Resuming without reload.")
            }
            
            // Add a hint to history so AI knows to check for login success
            if wasIntervention {
                self.history.append("User performed manual intervention. Verifying success...")
            }
            
            resumeContinuation?.resume()
            resumeContinuation = nil
        }
    }
    
    func stop() {
        isRunning = false
        automationTask?.cancel()
        automationTask = nil
        
        // If we were suspended, resume so the loop can exit
        resumeContinuation?.resume()
        resumeContinuation = nil
        
        
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.browser.webView.stopLoading()
            self.browser.webView.load(URLRequest(url: URL(string: "about:blank")!))
            if let popup = self.browser.popupWebView {
                popup.stopLoading()
                popup.load(URLRequest(url: URL(string: "about:blank")!))
            }
        }
    }
    
    private func suspendAutomation() async {
        isWaitingForUser = true
        await withCheckedContinuation { continuation in
            resumeContinuation = continuation
        }
    }
}
