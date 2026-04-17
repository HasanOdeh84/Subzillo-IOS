// IntentParser.swift
// Extracts service name + intent from ANY free-text message.
// No hardcoded service list — works with 500+ services via regex extraction.
// Falls back to Claude API when regex-based extraction fails.

import Foundation
import Combine

enum IntentParser {
    
    // MARK: - Synchronous (fast, regex-based)

    static func parse(_ input: String) -> AgentTask? {
        let lower = input.lowercased()
        guard let service = extractServiceName(from: input) else { return nil }

        let cancelWords = ["cancel", "unsubscribe", "stop", "end",
                           "terminate", "remove", "turn off"]
        let intent: AgentIntent = cancelWords.contains(where: { lower.contains($0) })
            ? .cancelSubscription
            : .getDetails

        // Check NavigationMemory for a known route
        let knownRoute = NavigationMemory.shared.route(for: service)

        return AgentTask(
            rawServiceName: service,
            intent: intent,
            resolvedURLs: nil,
            knownRoute: knownRoute
        )
    }

    // MARK: - Async AI fallback (called when regex fails)

//    static func parseWithAI(_ input: String) async -> AgentTask? {
//        let prompt = """
//        Extract the subscription service name and user intent from this message.
//        Reply with ONLY valid JSON, no extra text.
//
//        Message: "\(input)"
//
//        JSON schema:
//        {
//          "serviceName": "the service name in lowercase (e.g. netflix, spotify, manus ai, adobe)",
//          "intent": "get_details or cancel"
//        }
//
//        If no service name can be identified, return: {"serviceName": null, "intent": null}
//        """
//
//        do {
//            let body: [String: Any] = [
//                "model": Config.claudeModel,
//                "max_tokens": 150,
//                "messages": [["role": "user", "content": prompt]]
//            ]
//
//            let data = try await callAPI(body: body)
//            guard
//                let root    = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                let content = root["content"] as? [[String: Any]],
//                let first   = content.first,
//                let text    = first["text"] as? String,
//                let jsonData = extractJSON(from: text).data(using: .utf8),
//                let obj      = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
//                let service  = obj["serviceName"] as? String,
//                !service.isEmpty
//            else { return nil }
//
//            let intentStr = obj["intent"] as? String ?? "get_details"
//            let intent: AgentIntent = intentStr == "cancel" ? .cancelSubscription : .getDetails
//            let knownRoute = NavigationMemory.shared.route(for: service)
//
//            return AgentTask(
//                rawServiceName: service,
//                intent: intent,
//                resolvedURLs: nil,
//                knownRoute: knownRoute
//            )
//        } catch {
//            return nil
//        }
//    }
    
    static func parseWithAI(_ input: String) async -> AgentTask? {
        do {
            print("Started AI to extract service name")
            let aiService = AIService()
            let (service, intentStr) = try await aiService.parseIntent(from: input)
            
            guard let service = service, !service.isEmpty else { return nil }
            dlog("AI extracted service: \(service), intent: \(intentStr ?? "nil")", tag: "AI")
            
            let intent: AgentIntent
            if intentStr == "cancel" {
                intent = .cancelSubscription
            } else {
                intent = .getDetails
            }
            
            let knownRoute = NavigationMemory.shared.route(for: service)
            
            return AgentTask(
                rawServiceName: service,
                intent: intent,
                resolvedURLs: nil,
                knownRoute: knownRoute
            )
        } catch {
            return nil
        }
    }

    // MARK: - Extract service name from natural language (regex)

    static func extractServiceName(from input: String) -> String? {
        let lower = input.lowercased()

        // 1. Known aliases — linguistic mappings, NOT URLs
        let aliases: [String: String] = [
            "prime video"     : "amazon",
            "amazon prime"    : "amazon",
            "prime"           : "amazon",
            "youtube premium" : "youtube",
            "youtube tv"      : "youtube",
            "google one"      : "google",
            "icloud"          : "apple",
            "apple tv"        : "apple",
            "apple tv+"       : "apple",
            "apple music"     : "apple",
            "d+"              : "disney",
            "disney+"         : "disney",
            "paramount+"      : "paramount",
            "hbo max"         : "max",
            "hbo"             : "max",
            "chat gpt"        : "chatgpt",
            "open ai"         : "openai",
            "ms office"       : "microsoft",
            "office 365"      : "microsoft",
            "microsoft 365"   : "microsoft",
            "o365"            : "microsoft",
            "aws"             : "amazon web services",
            "gcp"             : "google cloud",
        ]
        for (alias, canonical) in aliases where lower.contains(alias) {
            return canonical
        }

        // 2. Regex patterns to extract service brand from common sentence shapes
        let patterns: [String] = [
            // "log into / sign into / open / go to / add / check / retrieve [my] X [Y]"
            #"(?:log(?:ging)?\s+in(?:to)?|sign(?:ing)?\s+in(?:to)?|open|go\s+to|navigate\s+to|launch|check|show|get|retrieve|add|manage|view|fetch|pull|grab|find|browser\s+and\s+go\s+to)\s+(?:my\s+)?([A-Za-z][A-Za-z0-9]*(?:\s+[A-Za-z][A-Za-z0-9]*){0,2})"#,
            // "X subscription / account / billing / plan / subz / sub"
            #"([A-Za-z][A-Za-z0-9]*(?:\s+[A-Za-z][A-Za-z0-9]*){0,2})\s+(?:subscription|subscriptions|sub|subz|account|billing|plan|membership|details|info)"#,
            // "cancel / my X"
            #"(?:cancel|stop|end|my)\s+([A-Za-z][A-Za-z0-9]*(?:\s+[A-Za-z][A-Za-z0-9]*){0,2})"#,
        ]

        let stopWords: Set<String> = [
            "my", "the", "a", "an", "and", "or", "for", "to", "in", "on",
            "get", "show", "log", "open", "go", "check", "find", "add",
            "me", "details", "info", "browser", "subscription", "subscriptions",
            "sub", "subz", "account", "billing", "plan", "membership",
            "cancel", "stop", "please", "can", "you", "i", "want", "would",
            "like", "into", "sign", "navigate", "view", "manage", "launch",
            "retrieve", "fetch", "pull", "grab", "from", "about", "with",
            "all", "up", "its", "their", "of", "this", "that",
        ]

        for pattern in patterns {
            if let match = firstMatch(pattern: pattern, in: input, group: 1) {
                let candidate = match
                    .trimmingCharacters(in: .whitespaces)
                    .lowercased()
                    .replacingOccurrences(
                        of: #"\.(com|au|io|ai|co|net|org|app)$"#,
                        with: "",
                        options: .regularExpression
                    )

                let words = candidate.split(separator: " ").map(String.init)
                let meaningful = words.filter { !stopWords.contains($0) }

                if !meaningful.isEmpty && meaningful.joined().count > 1 {
                    let result = meaningful.joined(separator: " ")
                    dlog("Regex extracted service: \(result)", tag: "PARSER")
                    return result
                }
            }
        }

        return nil
    }

    // MARK: - Helpers

    private static func firstMatch(pattern: String, in text: String, group: Int) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard
            let match = regex.firstMatch(in: text, options: [], range: range),
            match.numberOfRanges > group
        else { return nil }
        let r = match.range(at: group)
        guard r.location != NSNotFound, let sr = Range(r, in: text) else { return nil }
        return String(text[sr])
    }

    private static func extractJSON(from text: String) -> String {
        var depth = 0; var start: String.Index?
        for idx in text.indices {
            switch text[idx] {
            case "{": if depth == 0 { start = idx }; depth += 1
            case "}":
                depth -= 1
                if depth == 0, let s = start { return String(text[s...idx]) }
            default: break
            }
        }
        return text
    }

    private static func callAPI(body: [String: Any]) async throws -> Data {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(Config.claudeAPIKey, forHTTPHeaderField: "x-api-key")
        req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw NSError(domain: "IntentParser", code: -1)
        }
        return data
    }
}
