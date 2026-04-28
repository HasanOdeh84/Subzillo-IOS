import Foundation

enum AgentTaskIntent: String, Codable {
    case getDetails = "GET_DETAILS"
    case cancelSubscription = "CANCEL_SUBSCRIPTION"
    case changePlan = "CHANGE_PLAN"
    case custom = "CUSTOM"
}

struct AgentTask: Codable, Identifiable {
    var id: String = UUID().uuidString
    let rawServiceName: String
    let displayName: String
    let intent: AgentTaskIntent
    var loginURL: String = ""
    var knownRoute: LearnedRoute? = nil
    var isLoggedIn: BooleanField = .unknown
    
    enum CodingKeys: String, CodingKey {
        case id, rawServiceName, displayName, intent, loginURL, knownRoute, isLoggedIn
    }
}

enum BooleanField: String, Codable {
    case yes = "true"
    case no = "false"
    case unknown = "unknown"
    
    var boolValue: Bool {
        return self == .yes
    }
}

struct LearnedRoute: Codable {
    let serviceName: String
    let loginURL: String
    let billingURL: String
    let steps: [String]
    
    func promptHint() -> String {
        if steps.isEmpty { return "Known direct billing URL: \(billingURL)" }
        return "The user previously reached the billing page via these steps:\n" +
                steps.map { "  - \($0)" }.joined(separator: "\n") +
                "\nTry to mimic these steps if possible."
    }
}

enum AgentActionType: String, Codable {
    case navigate = "navigate"
    case click = "click"
    case type = "type"
    case scroll = "scroll"
    case extract = "extract"
    case confirm = "confirm"
    case askUser = "askUser"
    case clickText = "clickText"
    case done = "done"
}

struct AgentAction: Codable {
    let reasoning: String?
    let action: AgentActionType?
    let url: String?
    let selector: String?
    let clickText: String?
    let x: Double?
    let y: Double?
    let text: String?
    let scrollY: Int?
    let message: String?
    let data: ExtractedData?
}

struct ExtractedData: Codable {
    let serviceName: String?
    let plan: String?
    let price: String?
    let billingDate: String?
    let billingCycle: String?
    let currency: String?
    let paymentMethod: String?
    let status: String?
    let raw: String?
}

struct PageSnapshot: Codable {
    let text: String
    let elements: [PageElement]
    let url: String
    var isLoggedIn: Bool = false
    var scrollY: Int? = nil
    
    func formatted() -> String {
        var output = "PAGE TEXT:\n\(String(text.prefix(3000)))\n\n"
        if elements.isEmpty { return output }
        
        output += "INTERACTIVE ELEMENTS:\n"
        for el in elements {
            if !el.href.isEmpty {
                output += "  • [\(el.selector)] \"\(el.text)\" (link -> \(el.href))\n"
            } else if !el.selector.isEmpty {
                output += "  • [\(el.selector)] \"\(el.text)\"\n"
            }
        }
        return output
    }
}

struct PageElement: Codable {
    let text: String
    let href: String
    let selector: String
    let area: String
    let x: Int?
    let y: Int?
}

enum ChatSender: String, Codable {
    case user = "USER"
    case agent = "AGENT"
    case system = "SYSTEM"
}

struct ChatMessage: Codable, Identifiable {
    var id: String = UUID().uuidString
    let sender: ChatSender
    let text: String
    var extractedFields: ExtractedFields? = nil
    var isError: Bool = false
    var isLoading: Bool = false
}

struct ExtractedFields: Codable {
    var serviceName: String? = nil
    var plan: String? = nil
    var price: String? = nil
    var billingDate: String? = nil
    var billingCycle: String? = nil
    var currency: String? = nil
    var paymentMethod: String? = nil
    var status: String? = nil
    var agentMessage: String? = nil
    var extras: [String] = []

    var hasMeaningfulData: Bool {
        return price != nil || billingDate != nil
    }

    var hasAnyData: Bool {
        return plan != nil || price != nil || billingDate != nil ||
                billingCycle != nil || currency != nil || paymentMethod != nil ||
                status != nil || !extras.isEmpty
    }

    mutating func merge(_ d: ExtractedData) {
        if let sn = d.serviceName, !sn.isEmpty { serviceName = sn }
        if let p = d.plan, !p.isEmpty { plan = p }
        if let pr = d.price, !pr.isEmpty { price = pr }
        if let bd = d.billingDate, !bd.isEmpty { billingDate = bd }
        if let bc = d.billingCycle, !bc.isEmpty { billingCycle = bc }
        if let cur = d.currency, !cur.isEmpty { currency = cur }
        if let pm = d.paymentMethod, !pm.isEmpty { paymentMethod = pm }
        if let st = d.status, !st.isEmpty { status = st }
        if let r = d.raw, !r.isEmpty { extras.append(r) }
    }

    func summary() -> String {
        var p: [String] = []
        if let plan = plan { p.append("plan=\(plan)") }
        if let price = price { p.append("price=\(price)") }
        if let date = billingDate { p.append("billingDate=\(date)") }
        return p.isEmpty ? "nothing yet" : p.joined(separator: ", ")
    }
}

struct ServiceDetails: Codable {
    let serviceName: String
    let loginUrl: String
    let billingUrl: String
}
