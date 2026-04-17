// URLResolver.swift
// Resolves the correct login URL for ANY service using:
//   1. NavigationMemory (learned from previous runs)
//   2. Claude API (AI-driven resolution — no hardcoded URLs)

import Foundation


final class URLResolver {

    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!

    private let systemPrompt = """
    You are a URL expert. Given a subscription service name, return the OFFICIAL login page URL.
    You must know the real, current login URLs for all major subscription services worldwide —
    streaming, music, productivity, cloud, gaming, news, VPN, fitness, AI, SaaS, etc.

    Rules:
    - Return the REAL login page URL (not the homepage).
    - If the service uses a separate auth domain (e.g. accounts.google.com), use that.
    - For lesser-known services, use your knowledge to find the correct URL.
    - Capitalise the brand name properly (e.g. "Netflix", "Manus AI", "ChatGPT").
    - Reply with valid JSON ONLY. No markdown, no explanation.

    JSON schema:
    {
      "displayName": "Properly capitalised brand name",
      "loginURL": "https://..."
    }
    """

    // MARK: - Public

    func resolve(service: String) async throws -> ServiceURLs {
        // 1. Check NavigationMemory — fastest path
        if let knownURL = NavigationMemory.shared.loginURL(for: service) {
            let displayName = NavigationMemory.shared.route(for: service)?.displayName ?? service.capitalized
            dlog("[SOURCE: MEMORY] Found login URL for \(service): \(knownURL)", tag: "URL")
            return ServiceURLs(loginURL: knownURL, billingURL: "", displayName: displayName)
        }

        // 2. Ask Claude AI for the real login URL
        let resolved = try await resolveViaAI(service: service)

        // 3. Save to memory for next time
        NavigationMemory.shared.recordLoginURL(
            service: service,
            displayName: resolved.displayName,
            loginURL: resolved.loginURL ?? ""
        )

        return resolved
    }

    // MARK: - AI Resolution

//    private func resolveViaAI(service: String) async throws -> ResolvedURLs {
//        let body: [String: Any] = [
//            "model"      : Config.claudeModel,
//            "max_tokens" : 200,
//            "system"     : systemPrompt,
//            "messages"   : [[
//                "role"    : "user",
//                "content" : "What is the official login page URL for: \(service)"
//            ]]
//        ]
//
//        var req        = URLRequest(url: apiURL)
//        req.httpMethod = "POST"
//        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        req.setValue(Config.claudeAPIKey, forHTTPHeaderField: "x-api-key")
//        req.setValue("2023-06-01",        forHTTPHeaderField: "anthropic-version")
//        req.httpBody   = try JSONSerialization.data(withJSONObject: body)
//
//        let (data, response) = try await URLSession.shared.data(for: req)
//        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
//            throw URLResolverError.apiError(String(data: data, encoding: .utf8) ?? "unknown")
//        }
//
//        return try parse(data: data, fallbackName: service)
//    }
    
    private func resolveViaAI(service: String) async throws -> ServiceURLs {
        let aiService = AIService()
        let resolved = try await aiService.resolveStartURL(service: service)
        dlog("[SOURCE: AI] Resolved login URL for \(service): \(resolved.loginURL ?? "nil")", tag: "URL")
        return resolved
    }

    private func parse(data: Data, fallbackName: String) throws -> ServiceURLs {
        guard
            let root    = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = root["content"] as? [[String: Any]],
            let first   = content.first,
            let text    = first["text"] as? String
        else { throw URLResolverError.parseError("Unexpected response shape") }

        let json = extractJSON(from: text)
        guard
            let jsonData = json.data(using: .utf8),
            let obj      = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
            let loginURL = obj["loginURL"] as? String
        else { throw URLResolverError.parseError("Missing loginURL in response") }

        let displayName = obj["displayName"] as? String ?? fallbackName.capitalized
        return ServiceURLs(loginURL: loginURL, billingURL: "", displayName: displayName)
    }

    private func extractJSON(from text: String) -> String {
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
}

enum URLResolverError: LocalizedError {
    case apiError(String)
    case parseError(String)
    var errorDescription: String? {
        switch self {
        case .apiError(let m):   return "URL resolution failed: \(m)"
        case .parseError(let m): return "URL parse error: \(m)"
        }
    }
}
