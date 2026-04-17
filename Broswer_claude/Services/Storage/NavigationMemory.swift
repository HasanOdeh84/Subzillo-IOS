// NavigationMemory.swift
// Persistent self-learning system — stores successful navigation paths per service
// so that future runs go directly to the right page without re-exploring.

import Foundation

final class NavigationMemory {

    static let shared = NavigationMemory()

    private var routes: [String: LearnedRoute] = [:]
    private let fileURL: URL

    // MARK: - Init

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appendingPathComponent("subzillo_nav_memory.json")
        load()
    }

    // MARK: - Read

    /// Returns the learned route for a service, if one exists.
    func route(for service: String) -> LearnedRoute? {
        routes[normalise(service)]
    }

    /// Returns the known login URL for a service, if previously learned.
    func loginURL(for service: String) -> String? {
        routes[normalise(service)]?.loginURL
    }

    // MARK: - Write — record a successful run

    func recordSuccess(
        service: String,
        displayName: String,
        loginURL: String,
        billingURL: String,
        steps: [String]
    ) {
        // Skip URLs that are obviously session-specific / expire quickly.
        // These URLs work once and then 404 on the next run.
        if isEphemeralURL(billingURL) {
            print("[NavMemory] Skipping ephemeral URL: \(billingURL)")
            return
        }

        let key = normalise(service)
        var route = routes[key] ?? LearnedRoute(
            serviceName: key,
            displayName: displayName,
            loginURL: loginURL,
            billingURLs: [],
            navigationSteps: [],
            successCount: 0,
            lastSuccessDate: Date()
        )

        // Always update login URL to the most recent one
        route.loginURL = loginURL
        route.displayName = displayName

        // Prepend billing URL (most recent first), deduplicate, cap at 5
        let normBilling = billingURL.lowercased()
        route.billingURLs.removeAll { $0.lowercased() == normBilling }
        route.billingURLs.insert(billingURL, at: 0)
        if route.billingURLs.count > 5 {
            route.billingURLs = Array(route.billingURLs.prefix(5))
        }

        // Save the latest successful navigation steps (last 10)
        route.navigationSteps = Array(steps.suffix(10))
        route.successCount += 1
        route.lastSuccessDate = Date()

        routes[key] = route
        save()
    }

    /// Remove a stale/broken billing URL from a service's learned routes.
    /// Called when the fast path hits a 404 so the bad URL doesn't keep failing.
    func removeBillingURL(service: String, badURL: String) {
        let key = normalise(service)
        guard var route = routes[key] else { return }
        let norm = badURL.lowercased()
        route.billingURLs.removeAll { $0.lowercased() == norm }
        // If no usable URLs remain, also drop successCount so fast-path won't fire
        if route.billingURLs.isEmpty {
            route.successCount = 0
        }
        routes[key] = route
        save()
        print("[NavMemory] Purged bad URL: \(badURL)")
    }

    /// Detects URLs that are session/token-bound and will 404 on re-use.
    /// Examples: Stripe sessions, JWT tokens in query, UUID-laden paths.
    private func isEphemeralURL(_ url: String) -> Bool {
        let lower = url.lowercased()
        // Stripe session URLs
        if lower.contains("stripe.com/p/session") { return true }
        if lower.contains("stripe.com/billing/portal/session") { return true }
        if lower.contains("/session_") || lower.contains("sess_") { return true }
        // Query-string tokens (sig=, token=, key=, jwt=, access_token=)
        if lower.contains("?sig=") || lower.contains("&sig=") { return true }
        if lower.contains("token=") || lower.contains("jwt=") { return true }
        if lower.contains("access_token=") { return true }
        if lower.contains("signature=") { return true }
        // Very long hash-like segments in path (>24 chars of hex/base64 between slashes)
        let segments = lower.components(separatedBy: "/")
        for seg in segments where seg.count >= 24 {
            let hexLike = seg.allSatisfy { $0.isHexDigit || $0 == "-" || $0 == "_" }
            if hexLike { return true }
        }
        return false
    }

    /// Record a confirmed login URL without a full success.
    func recordLoginURL(service: String, displayName: String, loginURL: String) {
        let key = normalise(service)
        if var route = routes[key] {
            route.loginURL = loginURL
            route.displayName = displayName
            routes[key] = route
        } else {
            routes[key] = LearnedRoute(
                serviceName: key,
                displayName: displayName,
                loginURL: loginURL,
                billingURLs: [],
                navigationSteps: [],
                successCount: 0,
                lastSuccessDate: Date()
            )
        }
        save()
    }

    /// Record multiple URLs found via AI resolution.
    func recordResolvedURLs(service: String, displayName: String, loginURL: String?, billingURL: String?) {
        let key = normalise(service)
        var route = routes[key] ?? LearnedRoute(
            serviceName: key,
            displayName: displayName,
            loginURL: loginURL ?? "",
            billingURLs: [],
            navigationSteps: [],
            successCount: 0,
            lastSuccessDate: Date()
        )

        route.displayName = displayName
        if let lu = loginURL { route.loginURL = lu }
        
        if let bu = billingURL, !bu.isEmpty {
            // Add to the list of known billing URLs if not already there
            let norm = bu.lowercased()
            if !route.billingURLs.contains(where: { $0.lowercased() == norm }) {
                route.billingURLs.insert(bu, at: 0)
            }
        }

        routes[key] = route
        save()
    }

    // MARK: - Clear (for testing / reset)

    func clearAll() {
        routes = [:]
        save()
    }

    func clear(service: String) {
        routes.removeValue(forKey: normalise(service))
        save()
    }

    // MARK: - Private

    private func normalise(_ s: String) -> String {
        s.lowercased()
         .trimmingCharacters(in: .whitespaces)
         .replacingOccurrences(of: " ", with: "")
    }

    private func load() {
        guard
            let data = try? Data(contentsOf: fileURL)
        else { return }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([String: LearnedRoute].self, from: data) {
            routes = decoded
        }
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(routes) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
