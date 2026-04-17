// ClaudeProvider.swift
// Implementation of AIProvider using the Anthropic Messages API.

import Foundation
import UIKit

final class ClaudeProvider: AIProvider {
    
    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    
    private let systemPrompt =
//    """
//    You are a browser automation agent inside Subzillo, a subscription management app.
//    The user is already logged in. Your ONLY job: find and extract their subscription/billing details.
//    Reply with ONE valid JSON object. No markdown, no extra text.
//    
//    ══ ABSOLUTE RULES ══════════════════════════════════════════════════════════════
//    1. NEVER guess or invent a URL. Only navigate to URLs from the INTERACTIVE ELEMENTS list.
//    2. action=extract → saves partial data and CONTINUES searching.
//    3. action=done → ends the task. Use IMMEDIATELY when you have price OR billing date.
//       Do NOT keep navigating once you have those fields — stop and use action=done.
//    4. action=confirm → required before any destructive action (cancel/delete/unsubscribe).
//    5. action=ask_user → absolute last resort only.
//    6. NEVER click navigation toggle buttons (open-sidebar, close-sidebar, menu-toggle,
//       hamburger) when you are already on a settings or account page. These buttons
//       navigate AWAY from your target. Only click them from the home/main page.
//    7. NEVER use your training knowledge to fill price, billingDate, billingCycle,
//       currency, or paymentMethod. You MUST only extract values that are literally
//       readable as text on the current page or visible in the screenshot. If a value
//       is not visible on screen right now, leave that field empty (null / omit it).
//       Do NOT estimate, infer, or recall pricing from your training data.
//    8. ON A PRICING COMPARISON / "CHOOSE YOUR PLAN" PAGE (multiple plan cards visible
//       side-by-side — Free/Basic/Pro/etc.): the USER'S CURRENT PLAN is the card whose
//       primary button is DISABLED, GREYED-OUT, or labeled "Current Plan" / "Your Plan".
//       Every OTHER card will have an active button like "Switch to X", "Upgrade to X",
//       "Downgrade". Extract the price ONLY from the card with the disabled/inactive
//       button — NEVER from the cheapest card, NEVER from the highlighted marketing card.
//       Visual cue: look at the screenshot. A greyed, non-clickable button = current plan.
//    """
    
        """
        You are a browser automation agent inside Subzillo, a subscription management app.
        The user is already logged in. Your ONLY job: find and extract their subscription/billing details.
        Reply with ONE valid JSON object. No markdown, no extra text.

        ══ ABSOLUTE RULES ══════════════════════════════════════════════════════════════
        1. NEVER guess or invent a URL. Only navigate to URLs from the INTERACTIVE ELEMENTS list.
        2. action=extract → saves partial data and CONTINUES searching.
        3. action=done → ends the task. Use IMMEDIATELY when you have price OR billing date.
           Do NOT keep navigating once you have those fields — stop and use action=done.
        4. action=confirm → required before any destructive action (cancel/delete/unsubscribe).
        5. action=ask_user → absolute last resort only.
        6. NEVER click navigation toggle buttons (open-sidebar, close-sidebar, menu-toggle,
           hamburger) when you are already on a settings or account page. These buttons
           navigate AWAY from your target. Only click them from the home/main page.
        7. NEVER use your training knowledge to fill price, billingDate, billingCycle,
           currency, or paymentMethod. You MUST only extract values that are literally
           readable as text on the current page or visible in the screenshot. If a value
           is not visible on screen right now, leave that field empty (null / omit it).
           Do NOT estimate, infer, or recall pricing from your training data.
        8. ON A PRICING COMPARISON / "CHOOSE YOUR PLAN" PAGE (multiple plan cards visible
           side-by-side — Free/Basic/Pro/etc.): the USER'S CURRENT PLAN is the card whose
           primary button is DISABLED, GREYED-OUT, or labeled "Current Plan" / "Your Plan".
           Every OTHER card will have an active button like "Switch to X", "Upgrade to X",
           "Downgrade". Extract the price ONLY from the card with the disabled/inactive
           button — NEVER from the cheapest card, NEVER from the highlighted marketing card.
           Visual cue: look at the screenshot. A greyed, non-clickable button = current plan.
           Example: If "Upgrade to Pro" button is greyed out while "Switch to Plus" and
           "Switch to Go" are active → user is on Pro → extract Pro's price.

        ══ NAVIGATION PLAYBOOK (follow in order) ══════════════════════════════════════

        PHASE 1 — LEARNED PATH (if provided):
          Navigate directly to the known billing URL. Skip all exploration.

        PHASE 2 — CHECK CURRENT PAGE FIRST:
          Does the page text already contain: price, plan name, billing date, payment method?
          → YES: action=extract all visible fields, then look for missing ones.
          → NO: continue to Phase 3.

        PHASE 3 — OPEN ACCOUNT MENU:
          Most services hide billing behind a profile or account button.
          Check elements in this priority order:

          a) [PROFILE ICON] elements → click the profile/avatar icon
          b) [HEADER] elements with text related to: account, user, profile, settings
          c) [MENU] hamburger or sidebar toggle buttons
          d) [BOTTOM-NAV] elements → VERY IMPORTANT: many services (ChatGPT, Slack,
             Notion, Linear, etc.) place the logged-in user's name/avatar at the BOTTOM
             of the left sidebar. If you see [BOTTOM-NAV] elements, click the one that
             shows the user's name or looks like an account control. This opens account
             settings from which you can reach billing/subscription.
          e) Any visible button/link with text: "Settings", "Account", "Profile", "Manage"

        PHASE 4 — NAVIGATE INTO ACCOUNT/SETTINGS:
          After menu or sidebar opens, look for:
            [DROPDOWN] or [BOTTOM-NAV] items with text like:
            "Settings", "Billing", "Subscription", "My Plan", "Manage Plan",
            "Account", "Membership", "Payments", "Upgrade", "Plan & Billing"
          → Click the most relevant one using action=click with its selector.

        PHASE 5 — FIND BILLING TAB/SECTION:
          On settings/account pages, look for tabs or sub-sections:
            "Billing & Payments", "Subscription", "Plan", "Manage"
          → Click or navigate to the billing section.

        PHASE 5b — REVEALING THE PRICE (CRITICAL — MOST IMPORTANT PHASE):
          On most services the plan NAME appears on the account/settings page but the PRICE
          is hidden behind a second click. You MUST find and click it. There are TWO patterns:

          PATTERN A — "Manage / Change Plan" dropdown (ChatGPT, many SaaS apps):
            Next to the plan name there is a button like "Manage ▼" or "Manage".
            Click it → a dropdown opens with options like "Change Plan", "See all plans",
            "View plans", "Compare plans", "Upgrade".
            Click "Change Plan" (or similar) → a pricing comparison page opens showing
            ALL plans (Free/Basic/Pro/etc.) with prices.
            → Apply RULE 8: find the card with the disabled button = user's current plan.
            → Extract the price from THAT card only.

          PATTERN B — External billing portal (Stripe, Paddle, Chargebee):
            Buttons like "Manage subscription", "Manage billing", "View billing",
            "Billing portal", "Update payment" redirect to billing.stripe.com (or similar).
            Wait for the portal to load, then extract price, next invoice amount, payment.

          Trigger words to click: "Manage", "Manage plan", "Manage subscription",
            "Change plan", "See plans", "View plans", "Compare plans", "Billing portal",
            "View billing", "Upgrade" (when next to the current plan name).
          → NEVER stop on a page that shows only the plan NAME without a price.
          → If you see plan="Pro" but no price → the NEXT action must click "Manage".

        PHASE 6 — EXTRACT & FINISH:
          When you see price, plan, or billing date on the page:
            → action=extract with all visible fields
            → action=done immediately after (do NOT keep navigating)
          If content seems cut off → ONE scroll, then extract, then done.
          STOP as soon as you have price. Do not look for a perfect page.

        ══ DATA TO EXTRACT ══════════════════════════════════════════════════════════
        serviceName, plan, price (with currency symbol), billingCycle, currency (ISO code),
        billingDate (next payment date), paymentMethod (card brand + last 4), status.

        ══ FINAL PASS ═══════════════════════════════════════════════════════════════
        If "ALREADY COLLECTED" says "FINAL PASS" → use action=done with everything visible now.

        ══ JSON SCHEMA ══════════════════════════════════════════════════════════════
        {
          "reasoning": "one sentence: what I see and why I chose this action",
          "action": "navigate|click|type|scroll|extract|ask_user|confirm|done",
          "url": "exact URL from elements list (navigate only)",
          "selector": "CSS selector (click/type only)",
          "clickText": "visible text to click if no selector",
          "scrollY": 400,
          "message": "for ask_user/confirm/done only",
          "data": {
            "serviceName":"","plan":"","price":"","billingCycle":"","currency":"",
            "billingDate":"","paymentMethod":"","status":"","raw":""
          }
        }
        """

    // MARK: - AIProvider
    
    func parseIntent(from input: String) async throws -> (serviceName: String?, intent: String?) {
        let prompt = """
        Extract the subscription service name and user intent from this message.
        Reply with ONLY valid JSON, no extra text.
        
        Message: "\(input)"
        
        JSON schema:
        {
          "serviceName": "the service name in lowercase (e.g. netflix, spotify, manus ai, adobe)",
          "intent": "get_details or cancel"
        }
        
        If no service name can be identified, return: {"serviceName": null, "intent": null}
        """
        
        let body: [String: Any] = [
            "model": Config.claudeModel,
            "max_tokens": 150,
            "system"     : prompt,
            "messages": [["role": "user", "content": "Find the service name for: \(input)"]]
        ]
        
        let data = try await postWithRetry(body)
        
        let obj = try parseJSONResponse(data)
        let serviceName = obj["serviceName"] as? String
        let intent = obj["intent"] as? String
        dlog("[Claude] Parsed intent: service=\(serviceName ?? "nil"), intent=\(intent ?? "nil")", tag: "AI")
        return (serviceName, intent)
    }
    
    func resolveStartURL(service: String) async throws -> ServiceURLs {
//        let sysPrompt = """
//        You are a URL expert. Given a subscription service name, return the OFFICIAL login page URL.
//        JSON schema:
//        {
//          "displayName": "Properly capitalised brand name",
//          "loginURL": "https://..."
//        }
//        """
        
        let sysPrompt = """
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
        
        let body: [String: Any] = [
            "model"      : Config.claudeModel,
            "max_tokens" : 200,
            "system"     : sysPrompt,
            "messages"   : [["role": "user", "content": "What is the official login page URL for: \(service)"]]
        ]
        
        let data = try await postWithRetry(body)
        let obj = try parseJSONResponse(data)
        
        let loginURL = obj["loginURL"] as? String
        let displayName = obj["displayName"] as? String ?? service.capitalized
        dlog("[Claude] Resolved login URL for \(service): \(loginURL ?? "nil")", tag: "AI")
        return ServiceURLs(loginURL: loginURL, billingURL: nil, displayName: displayName)
    }
    
    func resolveBillingURL(service: String) async throws -> ServiceURLs {
        let sysPrompt = """
        You are a URL expert. Given a subscription service name, return the OFFICIAL billing page URL.
        JSON schema:
        {
          "displayName": "Properly capitalised brand name",
          "billingURL": "https://..."
        }
        """
        
        let body: [String: Any] = [
            "model"      : Config.claudeModel,
            "max_tokens" : 200,
            "system"     : sysPrompt,
            "messages"   : [["role": "user", "content": "What is the official billing page URL for: \(service)"]]
        ]
        
        let data = try await postWithRetry(body)
        let obj = try parseJSONResponse(data)
        
        let billingURL = obj["billingURL"] as? String
        let displayName = obj["displayName"] as? String ?? service.capitalized
        dlog("[Claude] Resolved billing URL for \(service): \(billingURL ?? "nil")", tag: "AI")
        return ServiceURLs(loginURL: nil, billingURL: billingURL, displayName: displayName)
    }
    
    func nextAction(
        task: AgentTask,
        currentURL: String,
        snapshot: PageSnapshot,
        screenshot: UIImage?,
        history: [String],
        knownRoute: LearnedRoute?,
        collectedSoFar: String,
        stepNumber: Int
    ) async throws -> AgentAction {
        
        let content = buildContent(task: task, currentURL: currentURL, snapshot: snapshot, screenshot: screenshot, history: history, knownRoute: knownRoute, collectedSoFar: collectedSoFar, stepNumber: stepNumber)
        
        let body: [String: Any] = [
            "model": Config.claudeModel,
            "max_tokens": Config.maxTokens,
            "system": systemPrompt,
            "messages": [["role": "user", "content": content]]
        ]
        
        let data = try await postWithRetry(body)
        return try parseAgentAction(from: data)
    }

    // MARK: - Helpers
    
    private func buildContent(task: AgentTask, currentURL: String, snapshot: PageSnapshot, screenshot: UIImage?, history: [String], knownRoute: LearnedRoute?, collectedSoFar: String, stepNumber: Int) -> [[String: Any]] {
        var parts: [[String: Any]] = []
        
        let shouldSendScreenshot = (stepNumber == 0 || stepNumber % 4 == 0)
        if shouldSendScreenshot, let img = screenshot, let jpeg = img.jpegData(compressionQuality: 0.35) {
            parts.append([
                "type": "image",
                "source": ["type": "base64", "media_type": "image/jpeg", "data": jpeg.base64EncodedString()]
            ])
        }
        
        let memoryHint = knownRoute?.promptHint() ?? ""
        let recentHistory = history.suffix(5)
        
        let prompt = """
        GOAL: \(task.goalDescription)
        URL: \(currentURL)
        COLLECTED SO FAR: \(collectedSoFar)
        STEP: \(stepNumber + 1)
        
        \(memoryHint)
        \(snapshot.formatted())
        
        RECENT STEPS (\(recentHistory.count)):
        \(recentHistory.joined(separator: "\n"))
        
        Respond with JSON only.
        """
        
        parts.append(["type": "text", "text": prompt])
        return parts
    }
    
    private func postWithRetry(_ body: [String: Any]) async throws -> Data {
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        let backoffSeconds: [UInt64] = [30, 60, 90]
        
        for attempt in 0..<3 {
            var req = URLRequest(url: apiURL)
            req.httpMethod = "POST"
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue(Config.claudeAPIKey, forHTTPHeaderField: "x-api-key")
            req.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            req.httpBody = bodyData
            
            do {
                let (data, resp) = try await URLSession.shared.data(for: req)
                guard let http = resp as? HTTPURLResponse else { throw AgentError.apiError("No HTTP response") }
                if http.statusCode == 200 { return data }
                if http.statusCode == 429 {
                    let wait = backoffSeconds[min(attempt, backoffSeconds.count - 1)]
                    try? await Task.sleep(nanoseconds: wait * 1_000_000_000)
                    continue
                }
                throw AgentError.apiError("HTTP \(http.statusCode)")
            } catch {
                if attempt < 2 { continue }
                throw error
            }
        }
        throw AgentError.apiError("Retries exhausted")
    }
    
    private func parseJSONResponse(_ data: Data) throws -> [String: Any] {
        guard
            let root    = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let content = root["content"] as? [[String: Any]],
            let first   = content.first,
            let text    = first["text"] as? String
        else { throw AgentError.parseError("Unexpected response shape") }
        
        let jsonStr = extractJSON(from: text)
        guard let jsonData = jsonStr.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        else { throw AgentError.parseError("Invalid JSON in response") }
        return obj
    }
    
    private func parseAgentAction(from data: Data) throws -> AgentAction {
        let obj = try parseJSONResponse(data)
        let jsonData = try JSONSerialization.data(withJSONObject: obj)
        return try JSONDecoder().decode(AgentAction.self, from: jsonData)
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
