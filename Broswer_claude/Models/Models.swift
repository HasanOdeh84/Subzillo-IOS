// Models.swift

import Foundation

// MARK: - Chat

enum MessageSender { case user, assistant, system }

struct ChatMessage: Identifiable {
    let id   = UUID()
    let sender: MessageSender
    let text: String
    var subscriptionData: ExtractedFields? = nil
}

// MARK: - Agent Actions

struct AgentAction: Decodable {
    let action: ActionType
    var reasoning: String?     // Claude's one-sentence reasoning — logged for debugging
    var url: String?
    var selector: String?
    var clickText: String?
    var x: Double?
    var y: Double?
    var text: String?
    var scrollY: Int?
    var message: String?
    var data: ExtractedData?

    enum ActionType: String, Decodable {
        case navigate
        case click
        case type
        case scroll
        case extract
        case askUser  = "ask_user"
        case confirm
        case done
    }
}

struct ExtractedData: Decodable {
    var serviceName: String?
    var plan: String?
    var price: String?
    var billingDate: String?
    var billingCycle: String?
    var currency: String?
    var paymentMethod: String?
    var status: String?
    var raw: String?

    /// True only when at least one BILLING field is present.
    /// serviceName alone does NOT count — it is always set by the parser.
    var hasAnyData: Bool {
        plan != nil || price != nil || billingDate != nil ||
        billingCycle != nil || currency != nil || paymentMethod != nil || status != nil
    }

    /// True when we have enough to show the user a meaningful result.
    /// Requires at least a price OR a billing date.
    var hasMeaningfulData: Bool {
        price != nil || billingDate != nil
    }
}

// MARK: - Resolved URLs

struct ServiceURLs {
    var loginURL: String?
    var billingURL: String?
    var displayName: String
}

// MARK: - Agent Task

enum AgentIntent {
    case getDetails
    case cancelSubscription
    case custom(goal: String)
}

struct AgentTask {
    let rawServiceName: String
    let intent: AgentIntent
    var resolvedURLs: ServiceURLs?
    var knownRoute: LearnedRoute?       // from NavigationMemory

    var displayName: String { resolvedURLs?.displayName ?? knownRoute?.displayName ?? rawServiceName.capitalized }
    var loginURL: String    { resolvedURLs?.loginURL ?? knownRoute?.loginURL ?? "https://www.\(rawServiceName).com" }

    var goalDescription: String {
        switch intent {
        case .getDetails:
            return """
            The user is logged into \(displayName). You are on a page inside their account.
            GOAL: Find and extract ALL subscription/billing details:
            - Plan name, Price/Amount, Billing cycle (monthly/yearly), Currency,
              Next billing/payment date, Payment method, Status (active/cancelled/trial).

            STRATEGY:
            1. Read the current page carefully — the data may already be visible.
            2. If not, look for links/menu items related to:
               account, billing, subscription, plan, membership, payments, settings.
            3. Profile icons (top-right) often hide account/billing menus — click them.
            4. Click links to navigate deeper — NEVER guess or fabricate a URL.
            5. Use action=extract every time you find ANY useful data field.
            6. If data is spread across pages, navigate between them and extract incrementally.
            7. Use action=done when you have collected everything available.
            """
        case .cancelSubscription:
            return """
            The user is logged into \(displayName). You are on a page inside their account.
            GOAL: Cancel the subscription.

            STRATEGY:
            1. Read the page for links to: account, subscription, membership, plan, settings.
            2. Navigate through those pages to find the cancellation option.
            3. Do NOT guess or fabricate any URL — follow real links on the page.
            4. Use action=confirm before any final irreversible cancellation step.
            """
        case .custom(let goal):
            return goal
        }
    }
}

// MARK: - Agent State

enum AgentState {
    case idle
    case parsingIntent
    case resolvingURL(service: String)
    case waitingForLogin(service: String)
    case planning
    case running
    case waitingForConfirmation(message: String, onConfirm: () -> Void)
    case manualNavigation          // user is steering; AI watches and learns
    case done(result: String)
    case failed(error: String)
}

enum AgentError: LocalizedError {
    case apiError(String), parseError(String), browserError(String)
    var errorDescription: String? {
        switch self {
        case .apiError(let m):     return "API: \(m)"
        case .parseError(let m):   return "Parse: \(m)"
        case .browserError(let m): return "Browser: \(m)"
        }
    }
}

// MARK: - Learned Route (self-learning memory)

struct LearnedRoute: Codable {
    var serviceName: String         // normalised key (e.g. "netflix")
    var displayName: String         // proper name (e.g. "Netflix")
    var loginURL: String            // confirmed working login URL
    var billingURLs: [String]       // URLs where billing data was found
    var navigationSteps: [String]   // human-readable steps that worked
    var successCount: Int
    var lastSuccessDate: Date

    /// Best billing URL — most recently successful
    var bestBillingURL: String? { billingURLs.first }

    /// Format as a prompt hint so the AI can re-use the known path
    func promptHint() -> String {
        var hint = "══ LEARNED PATH (from \(successCount) previous successful run\(successCount == 1 ? "" : "s")) ══\n"
        hint += "Service: \(displayName)\n"
        if !billingURLs.isEmpty {
            hint += "Known billing page(s):\n"
            for url in billingURLs.prefix(3) { hint += "  → \(url)\n" }
        }
        if !navigationSteps.isEmpty {
            hint += "Steps that worked before:\n"
            for step in navigationSteps.suffix(8) { hint += "  \(step)\n" }
        }
        hint += "TRY the known billing URL(s) FIRST after login. If they fail (404, no data), explore normally.\n"
        return hint
    }
}
