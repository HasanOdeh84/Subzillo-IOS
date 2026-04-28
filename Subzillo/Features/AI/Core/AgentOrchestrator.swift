import Foundation
import Combine

enum AgentUpdate {
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
                
                _updates.send(.status("Starting automation for \(task.displayName)..."))
                
                let targetUrl = !task.loginURL.isEmpty ? task.loginURL : ""
                if !targetUrl.isEmpty {
                    _updates.send(.status("Navigating to login page..."))
                    browser.navigate(to: targetUrl)
                    await browser.waitForLoad()
                }
                
                var lastStateHash: String? = nil
                var lastActionIsStateChanging = false
                var lastActionFailed = false
                
                var steps = 0
                while isRunning && steps < totalSteps {
                    steps += 1
                    _updates.send(.status("Analyzing page... (Step \(steps))"))
                    await browser.waitForLoad()
                
                // Final UI Stability Delay for accurate snapshots
                try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                
                let snapshot = await browser.extractPageSnapshot()
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
                    
                    let isStateChangingAction: [AgentActionType] = [.navigate, .click, .clickText, .type, .scroll]
                    if let type = action.action, isStateChangingAction.contains(type) {
                        lastActionIsStateChanging = true
                    } else {
                        lastActionIsStateChanging = false
                    }
                    
                    // Loop detection
                    if lastActionIsStateChanging && actionStr == history.last {
                        let repeats = history.suffix(3).filter { $0 == actionStr }.count
                        if repeats >= 3 {
                            _updates.send(.needsIntervention("Loop detected. Please perform action manually then resume."))
                            await suspendAutomation()
                            history.removeAll()
                            continue
                        }
                    }
                    
                    history.append(actionStr)
                    
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
        resumeContinuation?.resume()
        resumeContinuation = nil
    }
    
    func stop() {
        isRunning = false
        automationTask?.cancel()
        automationTask = nil
        
        // If we were suspended, resume so the loop can exit
        resumeContinuation?.resume()
        resumeContinuation = nil
    }
    
    private func suspendAutomation() async {
        await withCheckedContinuation { continuation in
            resumeContinuation = continuation
        }
    }
}
