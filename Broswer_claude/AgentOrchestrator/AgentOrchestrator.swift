// AgentOrchestrator.swift
// Enterprise agent loop with:
//   • Memory-first fast path (skip exploration if we know the billing page)
//   • AI-driven exploration (no hardcoded URLs)
//   • Self-learning (saves successful paths for next time)
//   • Loop detection + recovery

import Foundation
import UIKit
import Combine

@MainActor
final class AgentOrchestrator: ObservableObject {

    let aiService = AIService()
    private let resolver = URLResolver()
    let browser          = BrowserController()

    @Published var state: AgentState = .idle
    @Published var statusText: String = ""

    var onTaskComplete: ((String, ExtractedFields?) -> Void)?
    var onTaskFailed:   ((String) -> Void)?

    private var actionHistory:  [String] = []
    private var collectedFields = ExtractedFields()
    private var maxSteps        = 30
    private var isRunning       = false
    private var resumeContinuation: CheckedContinuation<Bool, Never>?
    private var currentTask: AgentTask?

    // Loop detection
    private var visitedURLs:        [String: Int] = [:]
    private var recentActions:      [String]      = []
    private var clickedSelectors:   [String: Int] = [:]   // tracks click-action repetitions

    // The login URL actually used (for memory recording)
    private var usedLoginURL: String = ""

    // Billing-page detection keywords — any URL containing one of these is
    // treated as a page that may carry subscription details.
    // "stripe.com" is critical — "Manage subscription" buttons often redirect there.
    private let billingKeywords = ["subscription", "billing", "plan", "payment",
                                   "invoice", "membership", "account/settings",
                                   "settings/account", "manage", "pricing",
                                   "renewal", "youraccount", "settings",
                                   "account", "myaccount", "my-account",
                                   "stripe.com", "portal", "invoices"]

    // MARK: - Start

    func start(task: AgentTask) async {
        guard !isRunning else { return }
        isRunning       = true
        currentTask     = task
        actionHistory   = []
        collectedFields = ExtractedFields()
        visitedURLs     = [:]
        recentActions   = []
        clickedSelectors = [:]
        state           = .running

        // Clean slate — wipe cookies/storage from any previous task so stale auth
        // from one service can't collide with the login flow of another.
        status("Clearing previous session…")
        await browser.resetSession()
        try? await Task.sleep(nanoseconds: 300_000_000)

        // ── 1. Resolve login URL (memory → AI) ──────────────────────────────
        status("Finding \(task.rawServiceName) login page…")
        state = .resolvingURL(service: task.rawServiceName)

        var resolvedTask = task
        if let existing = task.resolvedURLs, let login = existing.loginURL, !login.isEmpty {
            status("Using pre-resolved URL for \(existing.displayName)…")
            usedLoginURL = login
            resolvedTask.resolvedURLs = existing
        } else {
            do {
                let urls = try await resolver.resolve(service: task.rawServiceName)
                resolvedTask.resolvedURLs = urls
                usedLoginURL = urls.loginURL ?? ""
                status("Opening \(urls.displayName)…")
            } catch {
                status("Using best-effort URL…")
                usedLoginURL = task.loginURL
            }
        }

        state = .running

        // ── 2. Open login page ───────────────────────────────────────────────
        let targetURL = resolvedTask.loginURL
        status("Loading: \(targetURL)")
        browser.navigate(to: targetURL)
        await waitForPageLoad()

        // Check for load errors
        if let error = browser.lastError {
            status("Page load error: \(error) — retrying…")
            // Retry once
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            browser.navigate(to: targetURL)
            await waitForPageLoad()
        }

        // ── 3. User logs in manually ─────────────────────────────────────────
        state = .waitingForLogin(service: resolvedTask.displayName)
        status("Log in to \(resolvedTask.displayName), then tap 'I'm Logged In'.")

        let loggedIn = await waitForUserSignal()
        guard loggedIn else { finish(failed: "Login cancelled."); return }

        state = .running
        await waitForPageLoad()

        // ── 3b. Proactive 3-step account navigation ──────────────────────────
        // Many SPAs (ChatGPT, Slack, Notion) collapse the sidebar on mobile.
        // The account button is hidden until the sidebar is opened.
        // We run a deterministic 3-step chain BEFORE the AI exploration loop:
        //   Step A: Open the collapsed sidebar (hamburger/toggle)
        //   Step B: Click the account/profile button at the bottom of the sidebar
        //   Step C: Click billing/settings from the opened dropdown

        try? await Task.sleep(nanoseconds: 2_500_000_000)   // let post-login redirects settle
        await browser.syncCurrentURL()

        let postLoginURL = browser.currentURL.lowercased()
        let onAuthPage = ["login", "signin", "sign-in", "sign_in", "auth",
                          "register", "password", "forgot", "verify", "otp",
                          "callback", "oauth", "sso"].contains { postLoginURL.contains($0) }

        var proactiveNavigationSucceeded = false

        if !onAuthPage {
            // ── Step A: Open sidebar if it's collapsed ───────────────────────
            status("Opening sidebar…")
            let sidebarOpened = await browser.tryOpenSidebar()
            if sidebarOpened {
                dlog("Sidebar opened — waiting for animation…", tag: "ACTION")
                try? await Task.sleep(nanoseconds: 1_500_000_000)   // sidebar slide animation
            } else {
                dlog("No collapsed sidebar found (may already be open)", tag: "ACTION")
            }

            // ── Step B: Click account/profile button ─────────────────────────
            status("Looking for account menu…")
            let menuOpened = await browser.tryClickAccountMenu()
            if menuOpened {
                dlog("Account menu clicked — waiting for dropdown…", tag: "ACTION")
                status("Account menu opened — looking for billing option…")
                try? await Task.sleep(nanoseconds: 1_200_000_000)   // dropdown animation

                // ── Step C: Click billing/settings from the dropdown ──────────
                let billingClicked = await browser.tryClickBillingFromMenu()
                if billingClicked {
                    dlog("Billing menu item clicked — waiting for page load…", tag: "ACTION")
                    status("Navigating to billing page…")
                    await waitForPageLoad()
                    await extraSPAWait()
                    await browser.syncCurrentURL()
                    dlog("After billing menu click — URL: \(browser.currentURL)", tag: "URL")
                    proactiveNavigationSucceeded = true
                } else {
                    dlog("No billing menu item found in dropdown", tag: "ACTION")
                    await dropdownWait()
                    await browser.syncCurrentURL()
                }
            } else {
                dlog("No account menu button found", tag: "ACTION")
            }
        } else {
            status("Still on auth page — skipping menu detection…")
        }

        /*
        // ── 4. FAST PATH: Try known billing URL from memory ──────────────────
        // Skip if proactive navigation already placed us on a billing page —
        // navigating away would discard the page we just proactively reached.
        if !proactiveNavigationSucceeded,
           let knownRoute = resolvedTask.knownRoute,
           let billingURL = knownRoute.bestBillingURL {
            dlog("[SOURCE: MEMORY] FAST PATH: known route → \(billingURL) (success count: \(knownRoute.successCount))", tag: "MEMORY")
            status("Known path found — navigating directly to billing page…")
            browser.navigate(to: billingURL)
            await waitForPageLoad()
            await extraSPAWait()
            await browser.syncCurrentURL()

            // Detect 404 / not-found pages — the saved URL is stale
            let pageText = await browser.extractPageText()
            let textLower = pageText.lowercased()
            let landed = browser.currentURL.lowercased()
            let is404 = textLower.contains("404") ||
                        textLower.contains("page could not be found") ||
                        textLower.contains("page not found") ||
                        textLower.contains("this page doesn't exist") ||
                        textLower.contains("not found") ||
                        landed.contains("/404") ||
                        landed.contains("error")
            if is404 {
                dlog("Saved URL returned 404 — purging from memory", tag: "MEMORY")
                // Remove the bad URL from memory so we don't try it again
                NavigationMemory.shared.removeBillingURL(
                    service: resolvedTask.rawServiceName,
                    badURL: billingURL
                )
                status("Saved path is stale (404) — exploring fresh…")
                // Navigate back to the login URL as a safe starting point
                browser.navigate(to: usedLoginURL)
                await waitForPageLoad()
                await extraSPAWait()
                collectedFields = ExtractedFields()
            } else if !pageText.isEmpty {
                let text = pageText
                // Merge regex-parsed fields (price, date, cycle, payment, status, etc.)
                let extracted = parseSubscriptionFromText(text, service: resolvedTask.displayName)
                collectedFields.merge(extracted)

                // Always run Claude regardless — it reads the page visually and
                // can extract structured fields even when regex misses them.
                let snapshot   = await browser.extractPageSnapshot()
                let screenshot = await browser.takeScreenshot()
                if let action = try? await aiService.nextAction(
                    task: resolvedTask,
                    currentURL: browser.currentURL,
                    snapshot: snapshot,
                    screenshot: screenshot,
                    history: ["[fast-path] Navigated directly to: \(billingURL)"],
                    knownRoute: knownRoute,
                    collectedSoFar: "FAST PATH — extract all billing fields visible now.",
                    stepNumber: 0
                ) {
                    if let d = action.data { collectedFields.merge(d) }
                }

                // Only exit fast path if we have a confirmed price.
                // Plan/date alone are not sufficient — they're easily mismatched.
                if collectedFields.price != nil {
                    NavigationMemory.shared.recordSuccess(
                        service: resolvedTask.rawServiceName,
                        displayName: resolvedTask.displayName,
                        loginURL: usedLoginURL,
                        billingURL: browser.currentURL,
                        steps: ["[fast-path] \(billingURL)"]
                    )
                    status("Subscription details extracted!")
                    finish(result: collectedFields.formatted(), fields: collectedFields)
                    return
                }
            }
            // Fast path didn't yield a price or billing date — explore normally
            collectedFields = ExtractedFields()   // reset partial noise
            status("Saved path didn't have data — exploring…")
        }
        */

        // ── 5. EXPLORATION LOOP: AI-driven navigation ────────────────────────
        dlog("Starting exploration loop. proactiveNav=\(proactiveNavigationSucceeded) URL=\(browser.currentURL)", tag: "STEP")
        status("AI is exploring the account pages…")

        var consecutiveBillingSteps = 0   // how many steps in a row we've been on a billing page

        for step in 1...maxSteps {
            guard isRunning else { break }

            await browser.syncCurrentURL()
            let currentURL = browser.currentURL
            recordVisit(currentURL)

            dlog("━━ Step \(step)/\(maxSteps) ━━ URL: \(currentURL)", tag: "STEP")
            dlog("Collected so far: \(collectedFields.summary())", tag: "STEP")

            // ── Billing page handler ───────────────────────────────────────────
            if isOnBillingPage(currentURL) {
                consecutiveBillingSteps += 1

                // Scroll to reveal dynamic content (billing info often below the fold)
                status("Step \(step): on billing/settings page — reading content…")
                await browser.scroll(byY: 400)
                await shortWait()

                // Extract FULL page text
                let fullText = await browser.extractPageText()
                dlog("Page text (\(fullText.count) chars): \(String(fullText.prefix(500)))", tag: "TEXT")
                if !fullText.isEmpty {
                    collectedFields.merge(parseSubscriptionFromText(fullText, service: resolvedTask.displayName))
                    dlog("After regex parse → \(collectedFields.summary())", tag: "TEXT")
                }

                // ✅ Price found — done
                if collectedFields.price != nil {
                    status("Price found — finishing…")
                    recordSuccessAndFinish(task: resolvedTask)
                    return
                }

                // ── Visual current-plan extractor ────────────────────────────
                // If we're on what looks like a pricing comparison page, look for
                // the card with a disabled button — that's the user's current plan.
                let (visualPlan, visualPrice) = await browser.extractCurrentPlanFromComparisonPage()
                if let price = visualPrice {
                    dlog("Visual extractor: plan=\(visualPlan ?? "?") price=\(price)", tag: "TEXT")
                    var d = ExtractedData()
                    d.plan = visualPlan
                    d.price = price
                    collectedFields.merge(d)
                    if collectedFields.price != nil {
                        status("Price found on pricing page — finishing…")
                        recordSuccessAndFinish(task: resolvedTask)
                        return
                    }
                }

                // ── Proactive 2-step chain: "Manage" → "Change Plan" ─────────
                // Run this on EVERY billing step until price is found.
                // If we have partial data (plan, status) but NO price, the price is
                // almost certainly behind a "Manage" button → opens a dropdown →
                // "Change Plan" / "See Plans" → pricing comparison page.
                if collectedFields.hasPartialData {
                    // Close sidebar first — on ChatGPT/similar apps the sidebar overlays
                    // the settings content, blocking access to "Manage subscription"
                    let sidebarClosed = await browser.tryCloseSidebar()
                    if sidebarClosed {
                        dlog("Sidebar closed before manage-subscription click", tag: "ACTION")
                        try? await Task.sleep(nanoseconds: 800_000_000)
                    }

                    status("Step \(step): clicking 'Manage' to reveal pricing…")
                    dlog("Proactive Manage click — consecutiveBillingSteps=\(consecutiveBillingSteps)", tag: "ACTION")
                    let clicked = await browser.tryClickManageSubscription()
                    if clicked {
                        dlog("Manage clicked — waiting 1.5s for dropdown / 4s for portal…", tag: "ACTION")
                        try? await Task.sleep(nanoseconds: 1_500_000_000)

                        // ── Try to click "Change Plan" from the dropdown ─────
                        let changePlanClicked = await browser.tryClickChangePlanFromDropdown()
                        if changePlanClicked {
                            dlog("Change Plan clicked — waiting for pricing page…", tag: "ACTION")
                            status("Step \(step): loading pricing comparison…")
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            await waitForPageLoad()
                            await browser.syncCurrentURL()
                            dlog("After Change Plan — URL: \(browser.currentURL)", tag: "URL")

                            // Extract directly from the comparison page using visual cues
                            let (visualPlan, visualPrice) = await browser.extractCurrentPlanFromComparisonPage()
                            if let price = visualPrice {
                                dlog("Visual extractor HIT: plan=\(visualPlan ?? "?") price=\(price)", tag: "TEXT")
                                var d = ExtractedData()
                                d.plan = visualPlan
                                d.price = price
                                collectedFields.merge(d)
                                if collectedFields.price != nil {
                                    recordSuccessAndFinish(task: resolvedTask)
                                    return
                                }
                            }
                            continue
                        }

                        // ── Or it may have redirected to a Stripe portal ──────
                        try? await Task.sleep(nanoseconds: 2_500_000_000)   // portal session creation
                        await waitForPageLoad()
                        await browser.syncCurrentURL()
                        dlog("After Manage click — URL: \(browser.currentURL)", tag: "URL")

                        if browser.currentURL != currentURL {
                            let portalText = await browser.extractPageText()
                            dlog("Portal page text: \(String(portalText.prefix(400)))", tag: "TEXT")
                            if !portalText.isEmpty {
                                collectedFields.merge(parseSubscriptionFromText(portalText, service: resolvedTask.displayName))
                            }
                            // Also try visual extractor on the new page
                            let (vp, vprice) = await browser.extractCurrentPlanFromComparisonPage()
                            if let price = vprice {
                                var d = ExtractedData()
                                d.plan = vp; d.price = price
                                collectedFields.merge(d)
                            }
                            if collectedFields.price != nil {
                                recordSuccessAndFinish(task: resolvedTask)
                                return
                            }
                            continue
                        }
                    } else {
                        dlog("No Manage/billing button found on this page", tag: "ACTION")
                    }
                }
                // NOTE: No 'continue' here — always falls through to normal AI navigation
            } else {
                consecutiveBillingSteps = 0
            }

            // ── Navigation/click loop detection ────────────────────────────────
            let urlVisitCount = visitedURLs[normaliseURL(currentURL)] ?? 0
            let loopWarning = urlVisitCount >= 3
                ? "\n⚠️ LOOP: This URL visited \(urlVisitCount)×. Use a DIFFERENT action — try profile icon or account menu."
                : ""

            if recentActions.count >= 4 && recentActions.suffix(4).allSatisfy({ $0 == "navigate" }) {
                actionHistory.append("[\(step)] Navigation loop — resetting")
                recentActions = []
                continue
            }

            status("Step \(step): reading page…")
            let snapshot   = await browser.extractPageSnapshot()
            let screenshot = await browser.takeScreenshot()

            // Log all elements Claude will see
            let elemSummary = snapshot.elements.prefix(20)
                .map { "'\($0.text)' sel=[\($0.selector)] area=\($0.area)" }
                .joined(separator: "\n  ")
            dlog("Elements visible (\(snapshot.elements.count)):\n  \(elemSummary)", tag: "ELEM")

            status("Step \(step): AI reasoning…")

            // Build collected summary + hint when price is still missing
            var collectedSoFar = collectedFields.summary() + loopWarning
            if collectedFields.price != nil && collectedFields.billingDate == nil {
                collectedSoFar += """

                ⚠️ PRICE FOUND but NEXT BILLING DATE is still missing. Click the
                "Billing", "Billing history", "Invoices", or "Payments" tab/link —
                the renewal date is usually on that sub-page.
                If no such tab exists on this page → action=done with what you have.
                """
            }
            if collectedFields.hasPartialData && collectedFields.price == nil {
                collectedSoFar += """

                ⚠️ PRICE NOT YET FOUND. You have the plan name but no price.
                NEXT STEP: click a button with text like "Manage", "Manage plan",
                "Change plan", "See plans", "View plans", or "Upgrade" next to the
                plan name. This reveals the pricing comparison page.
                → On that pricing page, apply RULE 8: the user's current plan is the
                  card with the DISABLED / greyed-out button (e.g. "Upgrade to Pro"
                  greyed out → Pro is the current plan). Extract its price.
                → Or it may redirect to a Stripe billing portal showing the price.
                Do NOT use action=done yet. Do NOT guess the price.
                """
            }

            dlog("Sending to AI. collectedSoFar: \(collectedSoFar)", tag: "CLAUDE")

            let action: AgentAction
            do {
                action = try await aiService.nextAction(
                    task: resolvedTask,
                    currentURL: currentURL,
                    snapshot: snapshot,
                    screenshot: screenshot,
                    history: actionHistory,
                    knownRoute: resolvedTask.knownRoute,
                    collectedSoFar: collectedSoFar,
                    stepNumber: step - 1
                )
            } catch {
                dlog("AI error at step \(step): \(error.localizedDescription)", tag: "ERROR")
                finish(failed: error.localizedDescription)
                return
            }

            // ── Skip repeated navigate URLs ────────────────────────────────────
            if action.action == .navigate,
               let targetURL = action.url,
               (visitedURLs[normaliseURL(targetURL)] ?? 0) >= 3 {
                actionHistory.append("[\(step)] SKIPPED navigate (visited \(visitedURLs[normaliseURL(targetURL)] ?? 0)×): \(targetURL)")
                recentActions.append("skip")
                continue
            }

            // ── Skip repeated click selectors + hard-block nav toggles ────────
            if action.action == .click {
                // Hard-block: never allow clicking a nav/sidebar toggle button.
                // tryClickAccountMenu() already opens menus before the loop starts.
                // Match both hyphen form ("open-sidebar") and space form ("open sidebar").
                let clickKey = (action.selector ?? action.clickText ?? "").lowercased()
                let normalizedKey = clickKey.replacingOccurrences(of: "-", with: " ")
                let navToggleWords = ["open sidebar","close sidebar","menu toggle",
                                      "hamburger","open nav","close nav","sidebar toggle",
                                      "show sidebar","hide sidebar","navtoggle",
                                      "toggle sidebar","toggle menu","toggle nav"]
                if navToggleWords.contains(where: { normalizedKey.contains($0) }) ||
                   clickKey.contains("open-sidebar") || clickKey.contains("close-sidebar") {
                    actionHistory.append("[\(step)] BLOCKED nav-toggle click: \(clickKey)")
                    dlog("BLOCKED nav-toggle click: \(clickKey)", tag: "ACTION")
                    recentActions.append("skip")
                    continue
                }

                // De-dup: block repeated clicks of the same element.
                // EXCEPTION: billing-related clicks (manage/subscription/billing/portal)
                // are whitelisted — they must be retried if navigation fails.
                let dedupeKey = action.selector ?? action.clickText ?? ""
                if !dedupeKey.isEmpty {
                    let isBillingClick = ["manage","subscription","billing","portal","plan","payment","invoice"]
                        .contains { dedupeKey.lowercased().contains($0) }
                    let maxClicks = isBillingClick ? 4 : 2
                    let clickCount = clickedSelectors[dedupeKey] ?? 0
                    if clickCount >= maxClicks {
                        actionHistory.append("[\(step)] SKIPPED repeated click(\(clickCount)×): \(dedupeKey)")
                        recentActions.append("skip")
                        continue
                    }
                    clickedSelectors[dedupeKey] = clickCount + 1
                    dlog("Click de-dup: '\(dedupeKey)' count=\(clickCount + 1)/\(maxClicks) billing=\(isBillingClick)", tag: "ACTION")
                }
            }

            let desc = "[\(step)] \(action.action.rawValue)" +
                (action.url.map      { " → \($0)" } ?? "") +
                (action.selector.map { " [\($0)]" } ?? "") +
                (action.message.map  { " \"\($0)\"" } ?? "")
            actionHistory.append(desc)
            recentActions.append(action.action.rawValue)
            status(desc)

            // Detailed Claude action log
            dlog("ACTION: \(action.action.rawValue)" +
                 (action.url.map        { " url=\($0)" }      ?? "") +
                 (action.selector.map   { " sel=[\($0)]" }    ?? "") +
                 (action.clickText.map  { " text='\($0)'" }   ?? "") +
                 (action.message.map    { " msg='\($0)'" }    ?? ""), tag: "ACTION")
            if let reasoning = action.reasoning {
                dlog("REASON: \(reasoning)", tag: "CLAUDE")
            }
            if let d = action.data {
                dlog("DATA: plan=\(d.plan ?? "-") price=\(d.price ?? "-") date=\(d.billingDate ?? "-") pay=\(d.paymentMethod ?? "-")", tag: "CLAUDE")
            }

            let shouldContinue = await execute(action: action)
            if !shouldContinue { break }

            // After any navigation/click, sync URL and give SPA time to render
            if action.action == .navigate || action.action == .click {
                await browser.syncCurrentURL()
                let landedURL = browser.currentURL
                dlog("Post-action URL: \(landedURL)", tag: "URL")
                if isOnBillingPage(landedURL) {
                    await extraSPAWait()   // 3s — let Stripe/billing portals fully render
                }
                // If a billing-related click didn't navigate yet, give extra time
                // for async portal session creation (ChatGPT→Stripe takes 2-4s)
                let wasBillingClick = ["manage","subscription","billing","portal"]
                    .contains { (action.selector ?? action.clickText ?? "").lowercased().contains($0) }
                if wasBillingClick && landedURL == currentURL {
                    dlog("Billing click didn't navigate yet — waiting 3s more…", tag: "URL")
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    await waitForPageLoad()
                    await browser.syncCurrentURL()
                    dlog("URL after extra wait: \(browser.currentURL)", tag: "URL")
                }
            }

            // ── Early exit after any action ────────────────────────────────────
            // Exit when we have BOTH price AND billing date (the two critical fields).
            // If we only have price, give the loop up to 3 more steps to hunt for
            // the billing date (Dropbox/Notion/etc. hide date on a separate Billing tab).
            if step >= 3 && collectedFields.price != nil && collectedFields.billingDate != nil {
                status("Subscription data found — finishing…")
                recordSuccessAndFinish(task: resolvedTask)
                return
            }
            // If price found but no date, exit after 5 more exploration steps max.
            if collectedFields.price != nil, collectedFields.billingDate == nil,
               step >= 3, actionHistory.count >= 3 {
                let stepsSincePrice = actionHistory.suffix(5).count
                if stepsSincePrice >= 5 && step >= 8 {
                    status("Price found, date unavailable — finishing…")
                    recordSuccessAndFinish(task: resolvedTask)
                    return
                }
            }
        }

        // ── 6. Final extraction if loop exhausted ────────────────────────────
        if isRunning {
            if collectedFields.price != nil {
                // We have a price — good enough to finish
                recordSuccessAndFinish(task: resolvedTask)
            } else if collectedFields.hasPartialData {
                // We have plan/date/status but no price — try the visual extractor
                // on whatever page we're on, as a last chance to catch the price.
                let (vp, vprice) = await browser.extractCurrentPlanFromComparisonPage()
                if let price = vprice {
                    var d = ExtractedData()
                    d.plan = vp; d.price = price
                    collectedFields.merge(d)
                }
                recordSuccessAndFinish(task: resolvedTask)
            } else {
                status("Final extraction attempt…")
                await extraSPAWait()

                if isOnBillingPage(browser.currentURL) {
                    let text = await browser.extractPageText()
                    let extracted = parseSubscriptionFromText(text, service: resolvedTask.displayName)
                    if extracted.hasAnyData { collectedFields.merge(extracted) }
                }

                // Visual extractor on pricing pages
                let (vp, vprice) = await browser.extractCurrentPlanFromComparisonPage()
                if let price = vprice {
                    var d = ExtractedData()
                    d.plan = vp; d.price = price
                    collectedFields.merge(d)
                }

                // One last Claude pass (step 99 = no screenshot to save tokens)
                if !collectedFields.hasAnyData {
                    let snapshot   = await browser.extractPageSnapshot()
                    let screenshot = await browser.takeScreenshot()
                    if let action = try? await aiService.nextAction(
                        task: resolvedTask,
                        currentURL: browser.currentURL,
                        snapshot: snapshot,
                        screenshot: screenshot,
                        history: actionHistory,
                        knownRoute: resolvedTask.knownRoute,
                        collectedSoFar: "FINAL PASS — extract only values literally visible on screen. NEVER guess or recall values from training data. Leave fields null if not visible.",
                        stepNumber: 99
                    ) {
                        if let d = action.data { collectedFields.merge(d) }
                        if let msg = action.message, !msg.isEmpty, msg.count < 300 {
                            collectedFields.addRaw(msg)
                        }
                    }
                }

                if collectedFields.hasAnyData {
                    recordSuccessAndFinish(task: resolvedTask)
                } else {
                    finish(failed: "Could not find subscription details automatically. Tap \"Manual\" in the top-left, navigate to your billing page yourself, then tap \"Extract Now\" — I'll learn the path for next time.")
                }
            }
        }
    }

    // MARK: - Learning — record success to NavigationMemory

    private func recordSuccessAndFinish(task: AgentTask) {
        collectedFields.fillFromExtras()

        // Only save to NavigationMemory when we actually HAVE a price.
        // Saving settings-only pages (no price) causes every future run to start
        // on the wrong page. Also skip Stripe session URLs — they expire immediately.
        let currentURL = browser.currentURL
        let isStripeSession = currentURL.contains("stripe.com/p/session") ||
                              currentURL.contains("stripe.com/billing/portal/session")
        let hasUsefulData  = collectedFields.price != nil

        if hasUsefulData && !isStripeSession {
            dlog("Saving billing URL to memory: \(currentURL)", tag: "MEMORY")
            NavigationMemory.shared.recordSuccess(
                service: task.rawServiceName,
                displayName: task.displayName,
                loginURL: usedLoginURL,
                billingURL: currentURL,
                steps: actionHistory
            )
        } else {
            dlog("Skipping memory save — price=\(collectedFields.price ?? "nil") isStripeSession=\(isStripeSession)", tag: "MEMORY")
        }

        finish(result: collectedFields.formatted(), fields: collectedFields)
    }

    // MARK: - Billing page detection

    private func isOnBillingPage(_ url: String) -> Bool {
        let lower = url.lowercased()
        return billingKeywords.contains { lower.contains($0) }
    }

    private func normaliseURL(_ url: String) -> String {
        url.lowercased()
           .replacingOccurrences(of: "https://", with: "")
           .replacingOccurrences(of: "http://", with: "")
           .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private func recordVisit(_ url: String) {
        let key = normaliseURL(url)
        visitedURLs[key] = (visitedURLs[key] ?? 0) + 1
    }

    // MARK: - Direct text parser (fast path, no API needed)

    private func parseSubscriptionFromText(_ text: String, service: String) -> ExtractedData {
        var data = ExtractedData()
        let lower = text.lowercased()

        data.serviceName = service

        // Price — supports symbol-based ($9.99/month) AND code-based (AED 71, SAR 50.00)
        // Stripe portal uses formats: "US$200.00/month", "$200.00 per month", "US$ 200"
        let pricePatterns: [String] = [
            // Stripe country-prefix format: US$200.00, CA$14.99, AU$19.99/month
            #"[A-Z]{2}[\$€£][\d,]+\.?\d*(?:\s*(?:/|per)\s*(?:month|mo|year|yr|week|wk|day))?"#,
            // Symbol first: $9.99/month, €12, £5.99/yr
            #"[\$€£¥₹][\d,]+\.?\d*\s*(?:/\s*(?:month|mo|year|yr|week|wk|day))?"#,
            // Code first: AED 71/month, USD 9.99, SAR 50.00/mo
            #"\b(AED|USD|EUR|GBP|SAR|QAR|KWD|BHD|OMR|JOD|EGP|MAD|TRY|INR|PKR|BRL|CAD|AUD|NZD|SGD|MYR|THB|PHP|IDR|KRW|JPY|CNY|HKD|TWD|ZAR|NGN|KES|GHS|CHF|SEK|NOK|DKK|PLN|CZK|HUF|RON|BGN|HRK|RUB|UAH|ILS|MXN|COP|ARS|CLP|PEN|VND)\s*[\d,]+\.?\d*\s*(?:/\s*(?:month|mo|year|yr|week|wk|day))?"#,
            // Number then code: 71 AED/month, 9.99 USD
            #"[\d,]+\.?\d*\s*(?:AED|USD|EUR|GBP|SAR|QAR|KWD|BHD|OMR|INR|CAD|AUD)\s*(?:/\s*(?:month|mo|year|yr|week|wk|day))?"#,
        ]
        for pattern in pricePatterns {
            if data.price == nil, let range = text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                data.price = String(text[range]).trimmingCharacters(in: .whitespaces)
            }
        }

        // Plan keywords — require billing/plan context nearby to avoid false matches
        // "free" is only detected when it appears as a plan (e.g. "free plan", "free tier")
        // NOT when it appears in phrases like "try for free" / "free trial" / "sign up free"
        let contextualPlanPatterns: [(regex: String, plan: String)] = [
            (#"\bfree\s+(?:plan|tier|subscription|account|member)"#,       "Free"),
            (#"(?:plan|subscription|tier|membership)\s*[:\-]?\s*free\b"#,  "Free"),
            (#"\byour\s+(?:current\s+)?plan\s+is\s+free\b"#,              "Free"),
        ]
        for entry in contextualPlanPatterns {
            if data.plan == nil,
               lower.range(of: entry.regex, options: [.regularExpression, .caseInsensitive]) != nil {
                data.plan = entry.plan
            }
        }

        let planKeywords = ["standard", "starter", "pro", "plus", "premium",
                            "enterprise", "team", "business", "growth", "basic",
                            "advanced", "individual", "family", "student", "creator",
                            "unlimited", "essentials", "core"]
        if data.plan == nil {
            for kw in planKeywords where lower.contains(kw) {
                data.plan = kw.capitalized
                break
            }
        }

        // Billing cycle
        if lower.contains("/month") || lower.contains("per month") || lower.contains("/mo") || lower.contains("monthly") {
            data.billingCycle = "Monthly"
        } else if lower.contains("/year") || lower.contains("per year") || lower.contains("/yr") || lower.contains("yearly") || lower.contains("annual") {
            data.billingCycle = "Yearly"
        } else if lower.contains("/week") || lower.contains("per week") || lower.contains("weekly") {
            data.billingCycle = "Weekly"
        }

        // Currency — symbol-based and code-based
        let currencyMap: [(pattern: String, code: String)] = [
            ("\\$",  "USD"), ("€",  "EUR"), ("£",  "GBP"), ("¥",  "JPY"), ("₹",  "INR"),
            ("\\bAED\\b", "AED"), ("\\bSAR\\b", "SAR"), ("\\bQAR\\b", "QAR"),
            ("\\bKWD\\b", "KWD"), ("\\bBHD\\b", "BHD"), ("\\bOMR\\b", "OMR"),
            ("\\bEGP\\b", "EGP"), ("\\bTRY\\b", "TRY"), ("\\bCAD\\b", "CAD"),
            ("\\bAUD\\b", "AUD"), ("\\bGBP\\b", "GBP"), ("\\bCHF\\b", "CHF"),
            ("\\bBRL\\b", "BRL"), ("\\bMXN\\b", "MXN"), ("\\bINR\\b", "INR"),
        ]
        for entry in currencyMap {
            if text.range(of: entry.pattern, options: [.regularExpression, .caseInsensitive]) != nil {
                data.currency = entry.code
                break
            }
        }

        // Billing date
        let datePattern = #"\b(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\.?\s+\d{1,2},?\s+\d{4}\b|\b\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}\b"#
        if let range = text.range(of: datePattern, options: [.regularExpression, .caseInsensitive]) {
            data.billingDate = String(text[range])
        }

        // Status
        if lower.contains("active") || lower.contains("subscribed") {
            data.status = "Active"
        } else if lower.contains("cancelled") || lower.contains("canceled") {
            data.status = "Cancelled"
        } else if lower.contains("expired") {
            data.status = "Expired"
        } else if lower.contains("trial") {
            data.status = "Trial"
        }

        // Payment method — with card last 4 digits
        let cardPattern = #"(?:ending\s*(?:in\s*)?|[•·*]{3,}\s*)(\d{4})"#
        let cardBrand: String? = {
            if lower.contains("visa") { return "Visa" }
            if lower.contains("mastercard") { return "Mastercard" }
            if lower.contains("amex") || lower.contains("american express") { return "Amex" }
            if lower.contains("paypal") { return "PayPal" }
            if lower.contains("apple pay") { return "Apple Pay" }
            if lower.contains("google pay") { return "Google Pay" }
            if lower.contains("credit card") || lower.contains("debit card") { return "Card" }
            return nil
        }()
        if let brand = cardBrand {
            if let match = text.range(of: cardPattern, options: [.regularExpression, .caseInsensitive]) {
                let last4 = String(text[match]).filter { $0.isNumber }
                data.paymentMethod = "\(brand) ending in \(last4)"
            } else {
                data.paymentMethod = brand
            }
        }

        return data
    }

    // MARK: - User controls

    func cancel() {
        isRunning = false
        resumeContinuation?.resume(returning: false)
        resumeContinuation = nil
        state      = .idle
        statusText = ""
    }

    // MARK: - Manual navigation mode
    // The user steers the browser to the right page; AI watches, extracts, and learns.

    func enterManualMode() {
        // Stop AI navigation immediately
        isRunning = false
        resumeContinuation?.resume(returning: false)
        resumeContinuation = nil
        state      = .manualNavigation
        statusText = "Navigate to your billing/subscription page, then tap Extract."
        dlog("Entered manual navigation mode. URL: \(browser.currentURL)", tag: "STEP")
    }

    /// Called when the user taps "Extract Now" in manual mode.
    /// Reads the current page, asks Claude to extract all visible billing fields,
    /// then saves the learned path so future runs go there automatically.
    func extractFromManualNavigation() async {
        guard case .manualNavigation = state, let task = currentTask else { return }

        isRunning  = true
        state      = .running
        collectedFields = ExtractedFields()

        await browser.syncCurrentURL()
        let billingURL = browser.currentURL
        dlog("Manual extract triggered. URL: \(billingURL)", tag: "STEP")

        status("Reading page…")
        await browser.scroll(byY: 400)
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Regex parse
        let text = await browser.extractPageText()
        dlog("Manual page text (\(text.count) chars): \(String(text.prefix(400)))", tag: "TEXT")
        if !text.isEmpty {
            collectedFields.merge(parseSubscriptionFromText(text, service: task.displayName))
        }

        // Visual extract via Claude (always with screenshot)
        status("Extracting billing details…")
        let snapshot   = await browser.extractPageSnapshot()
        let screenshot = await browser.takeScreenshot()

        if let action = try? await aiService.nextAction(
            task: task,
            currentURL: billingURL,
            snapshot: snapshot,
            screenshot: screenshot,
            history: ["[manual-navigation] User navigated here manually: \(billingURL)"],
            knownRoute: task.knownRoute,
            collectedSoFar: "MANUAL EXTRACT: The user navigated here. Extract EVERY billing field that is literally visible: plan, price, billing date, payment method, status. Do NOT guess — only extract what you can see.",
            stepNumber: 0   // always include screenshot
        ) {
            if let d = action.data { collectedFields.merge(d) }
            if let msg = action.message, !msg.isEmpty { collectedFields.addRaw(msg) }
        }

        collectedFields.fillFromExtras()
        dlog("Manual extract result: \(collectedFields.summary())", tag: "STEP")

        // ── Learn this path for future runs ──────────────────────────────────
        // Only save to memory if we actually got billing data AND not a Stripe session URL.
        let isStripeSession = billingURL.contains("stripe.com/p/session") ||
                              billingURL.contains("stripe.com/billing/portal/session")
        if collectedFields.hasAnyData && !isStripeSession {
            dlog("Saving learned path → \(billingURL)", tag: "MEMORY")
            NavigationMemory.shared.recordSuccess(
                service: task.rawServiceName,
                displayName: task.displayName,
                loginURL: usedLoginURL.isEmpty ? task.loginURL : usedLoginURL,
                billingURL: billingURL,
                steps: ["[learned-from-user] \(billingURL)"]
            )
            status("Path learned! Future runs will go here directly.")
        }

        isRunning = false
        if collectedFields.hasAnyData {
            finish(result: collectedFields.formatted(), fields: collectedFields)
        } else {
            finish(failed: "Could not extract billing details. Make sure you're on a page that shows your subscription price, billing date, or plan name.")
        }
    }

    func userDidLogin()             { signal(true) }
    func userDidConfirm(_ ok: Bool) { signal(ok) }

    private func signal(_ value: Bool) {
        resumeContinuation?.resume(returning: value)
        resumeContinuation = nil
    }

    // MARK: - Execute one action

    private func execute(action: AgentAction) async -> Bool {
        switch action.action {

        case .navigate:
            guard let url = action.url, !url.isEmpty else { break }
            status("Navigating to \(url)…")
            recordVisit(url)
            browser.navigate(to: url)
            await waitForPageLoad()
            await browser.syncCurrentURL()

        case .click:
            if let sel = action.selector, !sel.isEmpty {
                status("Clicking \(sel)…")
                await browser.click(selector: sel)
            } else if let txt = action.clickText, !txt.isEmpty {
                status("Clicking \"\(txt)\"…")
                await browser.clickByText(txt)
            } else if let x = action.x, let y = action.y {
                status("Tapping (\(Int(x)), \(Int(y)))…")
                await browser.clickAt(x: x, y: y)
            }
            await dropdownWait()
            await waitForPageLoad()
            await browser.syncCurrentURL()

        case .type:
            if let sel = action.selector, let text = action.text {
                await browser.type(selector: sel, text: text)
            }
            await shortWait()

        case .scroll:
            await browser.scroll(byY: action.scrollY ?? 400)
            await shortWait()

        case .askUser:
            let msg = action.message ?? "Please complete this step, then tap Continue."
            state = .waitingForLogin(service: msg)
            let ok = await waitForUserSignal()
            state  = .running
            if !ok { finish(failed: "Cancelled."); return false }
            await waitForPageLoad()

        case .confirm:
            let msg = action.message ?? "Are you sure you want to proceed?"
            state   = .waitingForConfirmation(message: msg, onConfirm: {})
            let ok  = await waitForUserSignal()
            state   = .running
            if !ok { finish(result: "Action cancelled by user.", fields: nil); return false }

        case .extract:
            if let d = action.data { collectedFields.merge(d) }
            if let msg = action.message, !msg.isEmpty { collectedFields.addRaw(msg) }
            status("Saved: \(collectedFields.summary()). Looking for more…")

        case .done:
            if let d = action.data { collectedFields.merge(d) }
            collectedFields.fillFromExtras()
            if collectedFields.hasAnyData, let task = currentTask {
                recordSuccessAndFinish(task: task)
            } else {
                finish(result: action.message ?? "Task complete.", fields: nil)
            }
            return false
        }

        return true
    }

    // MARK: - Finish

    private func finish(result: String, fields: ExtractedFields?) {
        isRunning  = false
        state      = .done(result: result)
        onTaskComplete?(result, fields)
    }

    private func finish(failed msg: String) {
        isRunning  = false
        state      = .failed(error: msg)
        onTaskFailed?(msg)
    }

    private func status(_ text: String) { statusText = text }

    // MARK: - Waits

    private func waitForPageLoad() async {
        guard browser.isLoading else {
            try? await Task.sleep(nanoseconds: 800_000_000)
            return
        }
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            final class Box: @unchecked Sendable { var token: NSObjectProtocol? }
            let box = Box()
            box.token = NotificationCenter.default.addObserver(
                forName: .browserPageLoaded, object: browser, queue: .main
            ) { [box] _ in
                if let t = box.token { NotificationCenter.default.removeObserver(t); box.token = nil }
                cont.resume()
            }
            Task { [box] in
                try? await Task.sleep(nanoseconds: 6_000_000_000)
                if let t = box.token { NotificationCenter.default.removeObserver(t); box.token = nil; cont.resume() }
            }
        }
    }

    private func extraSPAWait() async {
        try? await Task.sleep(nanoseconds: 3_000_000_000)
    }

    private func dropdownWait() async {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
    }

    private func shortWait() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
    }

    private func waitForUserSignal() async -> Bool {
        await withCheckedContinuation { cont in self.resumeContinuation = cont }
    }
}

// MARK: - Accumulated fields

struct ExtractedFields {
    var serviceName: String?
    var plan: String?
    var price: String?
    var billingDate: String?
    var billingCycle: String?
    var currency: String?
    var paymentMethod: String?
    var status: String?
    var extras: [String] = []

    /// True when at least one BILLING field is present.
    /// serviceName alone does NOT count — it is always set by the parser.
    var hasAnyData: Bool {
        plan != nil || price != nil || billingDate != nil ||
        billingCycle != nil || currency != nil || paymentMethod != nil ||
        status != nil || !extras.isEmpty
    }

    /// True when we have enough to show a meaningful result to the user.
    /// Requires at least a price OR a billing date — not just a plan name or status.
    var hasMeaningfulData: Bool {
        price != nil || billingDate != nil
    }

    /// True when we have PARTIAL billing data (plan, date, status, extras) but are
    /// still missing the price. Used for the slow-exit gate at step 15.
    var hasPartialData: Bool {
        plan != nil || billingDate != nil || status != nil || !extras.isEmpty
    }

    mutating func merge(_ d: ExtractedData) {
        if let s = d.serviceName,   !s.isEmpty { serviceName   = serviceName   ?? s }
        if let s = d.plan,          !s.isEmpty { plan          = plan          ?? s }
        if let s = d.price,         !s.isEmpty { price         = price         ?? s }
        if let s = d.billingDate,   !s.isEmpty { billingDate   = billingDate   ?? s }
        if let s = d.billingCycle,  !s.isEmpty { billingCycle  = billingCycle  ?? s }
        if let s = d.currency,      !s.isEmpty { currency      = currency      ?? s }
        if let s = d.paymentMethod, !s.isEmpty { paymentMethod = paymentMethod ?? s }
        if let s = d.status,        !s.isEmpty { status        = status        ?? s }
        if let r = d.raw, !r.isEmpty { extras.append(r) }
    }

    mutating func addRaw(_ text: String) { if !text.isEmpty { extras.append(text) } }

    /// Try to fill missing structured fields from raw/extras text
    mutating func fillFromExtras() {
        guard !extras.isEmpty else { return }
        let combined = extras.joined(separator: " ")
        let lower = combined.lowercased()

        // Fill price from raw if still missing
        if price == nil {
            let pricePatterns: [String] = [
                #"[\$€£¥₹][\d,]+\.?\d*"#,
                #"\b(AED|USD|EUR|GBP|SAR|QAR|KWD|BHD|OMR|INR|CAD|AUD|CHF|BRL|MXN)\s*[\d,]+\.?\d*"#,
                #"[\d,]+\.?\d*\s*(?:AED|USD|EUR|GBP|SAR|QAR|KWD|BHD|OMR|INR|CAD|AUD)"#,
            ]
            for pattern in pricePatterns {
                if let range = combined.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                    price = String(combined[range]).trimmingCharacters(in: .whitespaces)
                    break
                }
            }
        }

        // Fill billing cycle from raw
        if billingCycle == nil {
            if lower.contains("/month") || lower.contains("per month") || lower.contains("monthly") {
                billingCycle = "Monthly"
            } else if lower.contains("/year") || lower.contains("per year") || lower.contains("yearly") || lower.contains("annual") {
                billingCycle = "Yearly"
            }
        }

        // Fill currency from raw
        if currency == nil {
            let codes = ["AED","USD","EUR","GBP","SAR","QAR","KWD","BHD","OMR","INR","CAD","AUD","CHF","BRL","MXN","JPY"]
            for code in codes {
                if combined.range(of: "\\b\(code)\\b", options: [.regularExpression, .caseInsensitive]) != nil {
                    currency = code
                    break
                }
            }
            if currency == nil {
                if combined.contains("$") { currency = "USD" }
                else if combined.contains("€") { currency = "EUR" }
                else if combined.contains("£") { currency = "GBP" }
            }
        }
    }

    func summary() -> String {
        var p: [String] = []
        if let s = plan          { p.append("plan=\(s)") }
        if let s = price         { p.append("price=\(s)") }
        if let s = billingCycle  { p.append("cycle=\(s)") }
        if let s = currency      { p.append("currency=\(s)") }
        if let s = billingDate   { p.append("billingDate=\(s)") }
        if let s = paymentMethod { p.append("payment=\(s)") }
        if let s = status        { p.append("status=\(s)") }
        return p.isEmpty ? "nothing yet" : p.joined(separator: ", ")
    }

    func formatted() -> String {
        // Build the price line with cycle and currency combined
        var priceLine: String? = nil
        if let p = price {
            var parts = p
            if let cycle = billingCycle { parts += " / \(cycle.lowercased())" }
            // Only prepend the currency CODE if the price doesn't already have a
            // currency symbol ($, €, £, ¥, ₹, etc.) AND doesn't already contain the code.
            let hasSymbol = ["$","€","£","¥","₹","₩","₽","₺","₴","৳","฿","₫"].contains { p.contains($0) }
            if let curr = currency, !p.uppercased().contains(curr), !hasSymbol {
                parts = "\(curr) \(parts)"
            }
            priceLine = parts
        }

        // Responsive formatting that works on all device sizes
        var lines: [String] = []

        // Header
        lines.append("")
        lines.append("📱 SUBSCRIPTION DETAILS")
        lines.append("─" + String(repeating: "─", count: 35))
        lines.append("")

        // Service name (bold/emphasized)
        if let s = serviceName {
            lines.append("✓ \(s)")
            lines.append("")
        }

        // Plan section
        if let s = plan {
            lines.append("Plan: \(s)")
        }

        // Pricing section (price + cycle)
        if let p = priceLine {
            if plan != nil { lines.append("") }
            lines.append("Amount: \(p)")
        }

        // Payment section
        if billingDate != nil || paymentMethod != nil || status != nil {
            if priceLine != nil { lines.append("") }
            if let s = billingDate {
                lines.append("Next Payment: \(s)")
            }
            if let s = paymentMethod {
                lines.append("Payment: \(s)")
            }
            if let s = status {
                lines.append("Status: \(s)")
            }
        }

        // Footer
        lines.append("")
        lines.append("─" + String(repeating: "─", count: 35))
        lines.append("")

        return lines.joined(separator: "\n")
    }
}

extension Notification.Name {
    static let browserPageLoaded = Notification.Name("browserPageLoaded")
}
