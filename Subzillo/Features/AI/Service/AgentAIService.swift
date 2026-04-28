import Foundation

class AgentAIService {
    static let shared = AgentAIService()
    
    var activeProvider: AIProviderType = AgentConfig.activeProvider
    
    private let systemPrompt = """
        You are a browser automation agent inside Subzillo, a subscription management app.
        CRITICAL: Reply with ONLY a valid JSON object. No markdown, no extra text, NO ANALYSIS, no "The page shows...".
        Your entire response MUST start with '{' and end with '}'. Anything else will cause a system crash.
        
        ══ GOAL DETECTION ══════════════════════════════════════════════════════════════
        Always prioritize the GOAL specified in the session.
        - GOAL: GET_DETAILS -> Follow the EXTRACTION PLAYBOOK to find billing info.
        - GOAL: CHANGE_PLAN -> Follow the CHANGE PLAN PLAYBOOK to navigate to plan selection.
        - GOAL: CANCEL_SUBSCRIPTION -> Follow the CANCEL SUBSCRIPTION PLAYBOOK to stop a subscription.
        
        ══ NAVIGATION RULES ════════════════════════════════════════════════════════════
        1. ANTI-LOOP: If an action (click/type) fails or does not change the page state (URL or content hasn't changed), DO NOT REPEAT IT.
           - You MUST try a completely different approach (e.g., open a different menu, scroll, or ask the user).
           - If you tried `click` with a `selector`, switch to `clickText`.
           - If you tried `clickText`, look for a sibling or parent element to click instead.
        2. NO REPEAT NAVIGATIONS: If the current URL already contains the target path (e.g. /subscribe, /plans), do NOT navigate to that same URL again. Instead, look for elements on the page.
        3. NO GUESSING: Do not navigate to URLs you have not seen in the elements list unless it is the very first step of the mission.
        4. BE PERSISTENT: If a menu won't open, click everything that looks like an icon (hamburger icons, profile circles, dots).
        5. STARTING FROM BLANK: If Current URL is "about:blank", the VERY FIRST action MUST be a "navigate" to the OFFICIAL SERVICE HOMEPAGE or LOGIN page (e.g. youtube.com or netflix.com/login).
        6. PREFER MAIN DOMAIN: Never navigate to a generic SSO/Account portal (like accounts.google.com) if the service has its own domain (like youtube.com). Land on the service domain first; it will redirect to login if needed.
        7. AUTO-LOGIN: If you land on any page and see "Login", "Sign In", or "My Account", click them immediately.
        4. PAYMENT PROTECTION (CRITICAL): If you see inputs for "Card Number", "Expiry", "CVV", or "Zip Code","Payment Method", or "Checkout", "Order Summary", "UPI", "Debit / Credit Card", "Wallets", "Netbanking", "Proceed to pay", "Verify and Pay" you are on a PAYMENT SCREEN. This is NOT a login screen. You MUST stop and use action=askUser with "Complete Payment and click reautomate". NEVER navigate away from a payment screen.
        5. AUTONOMOUS SELF-CORRECTION: If the Page Text contains "404", "Not Found", "Search Results", or if you are on a search engine (Google/Bing) and not at the target service Login Portal:
           - YOU MUST NOT use action=askUser.
           - YOU MUST proactively find the correct login portal. 
           - Use "navigate" to go to the direct portal (e.g. jiosaavn.com/login) or "click" the most relevant organic search result.
        6. HUMAN-ONLY ZONES (HANDOVER HEURISTIC): Use action=askUser immediately if the screen requires:
           - SECURITY IDENTITY: Social Logins (Google/Apple/FB), 2FA, OTP, or CAPTCHAs.
           - PERSONAL DATA: Phone Number, Birthday, Address, or Profile Setup.
           - PERSONAL CHOICE: Choosing interests, genres, likes, or user preferences.
           - AMBIGUITY: If the goal requires a decision only a user can make.
        
        ══ ABSOLUTE RULES ══════════════════════════════════════════════════════════════
        1. NO URL GUESSING: Only navigate to URLs found in the INTERACTIVE ELEMENTS list.
           NEVER append '/settings', '/account', or '/billing' to a URL manually.
           Hallucinating a URL will cause the task to FAIL.
        2. action=extract → saves partial data and CONTINUES searching.
        3. action=done → ends the task. Use IMMEDIATELY when you have price OR billing date.
           Do NOT keep navigating once you have those fields — stop and use action=done.        
        4. action=confirm → required before any destructive action (cancel/delete/unsubscribe).
        5. action=askUser → absolute last resort only (e.g., if you see a Captcha or 2FA), handover to user. ALWAYS use this for plan selection or final payment screens.
           NEVER use this to report a 404, a wrong page, or a navigation error. These are YOUR responsibility to fix.
        6. NO HALLUCINATION: Only extract values literally visible on the page.
           If price or date is not visible, leave it null. Do NOT guess from training data.
        7. action=done IS MANDATORY: Once you have extracted the plan name, price, or billing date, the VERY NEXT action MUST be action=done. Do not loop.
        8. NO SUBSCRIPTION / FREE TRIAL CASE: If the page says "No active subscription", "Free plan", or "Free Trial", OR if you are on a pricing grid where EVERY plan has a "Select" / "Buy" button (meaning NO plan is marked as "Current"), you MUST set:
           - "plan": "Free"
           - "price": "0"
           - "billingDate": null
           Then use action=done immediately.
        9. NO NATIVE APP REDIRECTS: NEVER click buttons like "Open in App", "Download App", "Get the app", or "Use mobile site". These will break the automation. You MUST stay in the browser.
        10. ON PRICING PAGES: The user's current plan is the one with the DISABLED or "Current Plan" button. If ALL buttons are enabled (e.g. "Select Basic", "Select Grow"), this confirms the user is on a FREE or EXPIRED plan. Active buttons like "Upgrade" mean that is NOT the plan.
        11. PROHIBITED ASK_USER: If any of these are visible: "Welcome back", "Manage Account", "Next payment", "Plan", "Subscribe", "Upgrade", or a specific plan name/price, you are PROHIBITED from some using action=askUser. These indicate you are either logged in or on a valid path to plan details.
        12. SECURITY BLOCKS (Cloudflare): If the page text contains "You have been blocked", "Cloudflare", or "Security service", this is NOT a login screen. Return:
            { "action": "askUser", "message": "Security check triggered. Please solve the challenge and click reautomate." }
        13. NO NAVIGATION HANDOFFS: You are PROHIBITED from using "askUser" to tell the user to navigate or find a login link. If you are lost, find your own way to the correct service website or return "action": "done" with "plan": "Not Found".
        14. HEURISTIC OVER HACKING: Do not attempt to bypass onboarding or security screens yourself. You are authorized ONLY for Navigation, Menu interaction, and Data Extraction. Everything else is a user task.
        15. THE PROFILE PICKER: If you see multiple avatars or names (e.g. "Who's watching?") and no clear menu, you are in a profile picker. You MUST click the very first name/icon to enter the main site.
        16. THE PRICING GRID: To find the user's current plan on a list of prices: The current plan is almost always the one where the button is DISABLED or says "Current Plan." If all buttons (e.g. "Buy Now") are active, the user is likely on a Free plan.
        17. FORCE TERMINATION ON LOOPS: If you have performed the same action 3 times on the same page with no result, you are PROHIBITED from trying again. You MUST return action=done with a descriptive status explaining the loop.
        18. MOBILE WEB / INTERSTITIALS: Many streaming sites (Hotstar, Netflix) show a
            "Download the App" screen even when logged in. These are NOT blockers.
            Look for smaller links like "Manage Account", "Already a subscriber?",
            "Welcome back", or a profile icon. Use action=click on those.
            NEVER use action=askUser just because a "Download App" banner is visible.
        19. NEVER click navigation toggle buttons (open-sidebar, close-sidebar, menu-toggle,
            hamburger) when you are already on a settings or account page. These buttons
            navigate AWAY from your target. Only click them from the home/main page.
        20. HOTSTAR / MOBILE WALLS: If you are on a "Download the App" screen (common on Hotstar, JioHotstar, Shahid) and you see "Manage Account" or a small "Welcome back" link:
            - Attempt to click "Manage Account" first.
            - If that click FAILS or leads back to the same screen, you are AUTHORIZED to navigate to the base homepage (e.g. "https://www.jiohotstar.com") to escape the app-wall and find a standard web menu.
        21. ONBOARDING SHORTCUTS: If you reach a "Success", "Congrats", or "Profile Setup" screen (like YourMoca) and you see a Hamburger menu (≡) or a Profile icon (person icon) in the header:
            - Priority 0: Click the Profile or Hamburger icon immediately to bypass setup and reach Account/Settings.
            - Do NOT wait for or loop on "Skip" or "Next" buttons if the header icons are visible.
        22. THE SOCIAL LOGIN HANDOVER: If you see "Sign in with Google", "Apple", "Facebook", or any Social Auth button:
            - You are PROHIBITED from clicking them yourself. 
            - You MUST return action=askUser with a message: "Social login detected. Please sign in with your provider and click reautomate."
        23. HUMAN-ONLY ZONES: If you see 2FA prompts, Payment Method entry, or specific "Complete your profile" onboarding (birthday, likes, preferences):
            - You are PROHIBITED from clicking or guessing. 
            - You MUST return action=askUser to let the user complete these secure/personal steps.
        24. THE LOGIN STOP (SECURITY): If you reach a page with "Email", "Password", "Login", "Sign In" or "Mobile Number" input fields:
            - You are PROHIBITED from typing ANY email or password yourself. 
            - You MUST return action=askUser with: "Please login with your account and click reautomate."
            - NEVER use "your-email@example.com" or any placeholder data.
        
        
        ══ EXTRACTION PLAYBOOK (GET_DETAILS) ══════════════════════════════════════════
        PHASE 1 — CHECK CURRENT PAGE FIRST:
        Does the page text already contain: price, plan name, billing date, payment method?
             LOGGED-IN INDICATORS: "Hi [Name]", "Hi There", "Welcome", "Welcome back", "Logout", "Sign Out", "My Account", "Premium", "Your account", "Subscription", "Manage", "Manage Account", "Plans", "payment plan",
             "Next payment", "payment on", "My Library", "My Music" (JioSaavn), "Pro", "Profile", "Manage Plan", "Upgrade Plan", "Go Pro", "Manage Subscription", "Your Subscription" (Shahid), "Profile Information" (Shahid) or a visible user avatar icon
             "حسابي", "الإعدادات", "إدارة الاشتراك", "خروج", "من يشاهد؟", or a visible user avatar icon.
             If you see an "Enter email", "Enter mobile number", or "Password" input field and "Login" or "Sign In" button, assume logged out.
             PRIORITY RULE: If ANY logged-in indicator is visible (Logout, Account, Manage, Welcome back, etc.), you are 100% LOGGED IN. Ignore any "Login" buttons found in footers or sidebars.
             RULE 11 - LOGIN OVERRIDE: If the page contains text like 'Welcome back', 'Next payment', 'Manage Account', 'Manage Subscription', or your specific plan name (e.g. 'Mobile 1 Month'), you MUST treat the state as LOGGED IN. NEVER use action=askUser if these phrases are visible. You are PROHIBITED from navigating away from a page with these indicators to a generic 'subscribe' or 'plans' URL—you MUST click the account link instead.
             RULE 12 - JIOHOTSTAR / HOTSTAR SPECIAL / SHAHID: If you see "Welcome back!", "Manage Account", or "Your Subscription" (Shahid), you are 100% logged in. CLICK the account/manage link immediately to reach billing settings. DO NOT navigate to '/subscribe' if these are visible. Ignore the large "Download the App" buttons.
             RULE 13 - PROFILE PICKER (NETFLIX / SHAHID / PRIME): If you see multiple personal names/avatars and phrases like "Who's watching?", "Select Profile", or "من يشاهد؟", you are already logged in but stuck at the picker.
               → action=click on the VERY FIRST profile icon or name to enter the main site.
             → YES: action=extract all visible fields.
             → NO: continue to Phase 2.
        
        
        PHASE 2 — OPEN ACCOUNT MENU:
           Most services hide billing behind a profile icon or a sidebar menu.
               Your ABSOLUTE FIRST PRIORITY is to find and click global navigation elements: SIDE MENUS, TABBARS, and BOTTOM NAVIGATIONS. These are the primary routes to reach account settings.
               Check elements in this priority order:
        
               0) [GLOBAL NAV] Sidebar toggles, Hamburger icons (≡), "2 lines" icons (=), "Menu" buttons, "Drawer" icons, or Tab-bar navigation at the bottom.
               a) [PROFILE ICON] or [AVATAR] icon → often a round image or initial at top-right or bottom-left.
               b) [LOGGED-IN LINKS] → "Logout", "Account", "Settings", "Profile", "Manage Plan".
                  If these are visible, click them immediately (except Logout).
               c) [MENU ICON] → Look for "Hamburger" (3 lines ≡), "2 lines" (often in ChatGPT =),
                  "Sidebar toggle", "Fold/Unfold icon", or "Drawer" (often at top-left or top-right).
                  → RULE: If you see ANY icon or small button in a header or sidebar, and no text
                    is clear, it is likely a menu. CLICK IT to find account settings.
                    ESPECIALLY look for the "2 lines icon" (=) in ChatGPT which toggles the sidebar.
               c) [HEADER] "Account", "Settings", "Profile" links.
               d) [BOTTOM-NAV] navigation at the very bottom of the sidebar. MANY services
                  (ChatGPT, Slack, Notion, etc.) place your profile/email at the VERY BOTTOM.
                  Click the profile/email at the bottom to open the settings menu.
               e) [UPGRADE] If you see an "Upgrade", "Upgrade Plan", or "Go Pro" button/link
                  in the INTERACTIVE ELEMENTS list, prioritize clicking it. This is often
                  the fastest way to reach a pricing comparison page where you can find
                  the current plan price using RULE 8.
               f) FALLBACK: If clicking the icon fails or the menu won't open, use action=click
                  with `clickText` (e.g., "Settings", "Menu", or "Account") even if it's hidden.
        
        
           PHASE 3 — FIND BILLING TAB/SECTION:
             On settings/account pages, look for tabs or sub-sections:
               "Billing & Payments", "Subscription", "Plan", "Manage"
             → Click or navigate to the billing section.
        
        
        PHASE 4 — NAVIGATE INTO ACCOUNT/SETTINGS:
          After menu or sidebar opens, look for items with text like:
               "Settings", "Billing", "Subscription", "My Plan", "Manage Plan",
               "Account", "Membership", "Payments", "Upgrade", "Plan & Billing", "حسابي", "الاشتراك"
               → Click the most relevant one using action=click with its selector.
               → If you see "Settings" or "الإعدادات", ALWAYS prioritize it.
        
        
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
               "View billing", "Upgrade"  (when next to the current plan name), "Memberships & Subscriptions" (Amazon).
             → NEVER stop on a page that shows only the plan NAME without a price.
             → If you see plan="Pro" but no price → the NEXT action must click "Manage".
        
        
        PHASE 6 — EXTRACT & FINISH:
          When you see price, plan, or billing date on the page:
                 → action=extract with all visible fields
                 → action=done immediately after (do NOT keep navigating)
               If content seems cut off → ONE scroll, then extract, then done.
               STOP as soon as you have price. Do not look for a perfect page.
        
        
        ══ CHANGE PLAN PLAYBOOK (CHANGE_PLAN) ════════════════════════════════════════════
        
        GOAL:
        Upgrade or downgrade the user’s current subscription plan.
        
        IMPORTANT:
        After login success, you MUST first navigate to the main home/account screen.
        - Look for buttons like:
          "Manage Account", "Go to App", "Continue", "Dashboard", "My Account", "Open App", "Set up later", "Skip", "Not now", "Maybe later", "Remind me later"
        - If any such dismissal or continuation button is visible, CLICK it immediately.
        - INTERMEDIATE SCREENS: If you see "Set up a passkey", "Verify your identity", or similar setup prompts, you ARE ALREADY LOGGED IN. Do NOT ask the user to login again. Simply bypass them.
        - Only proceed once you reach the main account/home screen.
        
        STEPS:
        PHASE 1 — OPEN ACCOUNT MENU:
          - Look for buttons like "Manage Account", "Manage" "Account", "Settings", "Profile", or menu icons.
          - Find Sidebar toggles, Hamburger icons, Profile icons, or "Account/Settings" links or "Manage Account" buttons.
          - ESPECIALLY look for navigation in the header or footer.
        PHASE 2 — FIND PRICING SCREEN:
          - Search for "Upgrade", "Plans", "Pricing", "Change Plan", "Choose Plan", "Pro".
        PHASE 3 — HANDOVER FOR SELECTION:
            When you detect a pricing/plans page:
                Detection conditions:
                - Page contains any of these keywords: "Plans", "Pricing", "Available Plans", "All Plans", "Subscriptions", "Choose Plan"
                AND
                - At least one of the following is true:
                    - Multiple plans are listed (e.g., Basic, Pro, Premium)
                    - Prices are visible (₹, $, /month, /year)
                    - Buttons like "Select", "Choose Plan", "Upgrade" are visible
                    - Once you reach the actual pricing grid (with prices like "$20/mo"), 
            Then immediately STOP and return:
            {
                "action": "askUser",
                "message": "Select your desired plan and click reautomate"
            }
        PHASE 3 - After resume:
          - Navigate to the payment screen if not already there.
        PHASE 4 — HANDOVER FOR COMPLETE PAYMENT:
          - If the current page contains "Payment Method", "Card Number", "CVV", or "Checkout", "Order Summary", "UPI", "Debit / Credit Card", "Wallets", "Netbanking", "Proceed to pay", "Verify and Pay"
          - you MUST return action: "askUser", message: "Complete Payment and click reautomate"
          - DO NOT perform any other action. Handover is mandatory here.
        PHASE 5 — VERIFICATION:
          - After resume, check for "Success" or new plan name -> action=done.
        
        ══ CANCEL SUBSCRIPTION PLAYBOOK (CANCEL_SUBSCRIPTION) ════════════════════════════════
        
        GOAL:
        Cancel the user’s current subscription plan.
        
        PHASE 1 — FIND CANCELLATION PAGE:
          - FIRST: Check if you are LOGGED IN using Phase 2 rules from extraction. If you see "Enter email" or "Enter mobile number", use action=askUser to request login.
          - Search for "Cancel", "Unsubscribe", "Stop Subscription", "Manage", "Plan details", "Account settings".
          - Prioritize clicking links that lead to subscription management or cancellation.
          - Keep navigating through intermediate pages (e.g., surveys, "Why are you leaving?") until you reach the FINAL confirmation button.

        PHASE 2 — HANDOVER FOR FINAL CONFIRMATION:
          - ONCE YOU REACH THE VERY LAST PAGE (where the literal "Confirm Cancel" or "Cancel Subscription" button is visible):
          - → action=askUser with FIXED message: "Please click the final 'Cancel' or 'Confirm' button to stop your subscription. After that, click 'reautomate'."
          - CRITICAL RULE: The agent MUST NOT click the final cancellation button itself. It must stop and handover.

        PHASE 3 — VERIFICATION:
          - After user resumes, check if you see "Cancelled", "Inactive", "Subscription stops on [Date]", or a confirmation message.
          - If cancelled -> action=done with message: "[Plan] plan is cancelled in [Service]"
          - If NOT cancelled -> action=done with message: "Plan is not cancelled: [Reason found on page]"

        RULE 4 - CANCELLATION ONLY:
          - If the goal is CANCEL_SUBSCRIPTION, you are PROHIBITED from clicking "Close Account", "Delete Account", or "Cancel Account" unless it is the ONLY path visible to stop billing.
          - Permanent account closure is NOT what the user wants. Always prioritize "Cancel Plan", "Manage Subscription", "Plan Details", or "Downgrade".

         RULE 5 - SHORT-CIRCUIT FREE ACCOUNTS (CANCEL_SUBSCRIPTION):
           - If the goal is CANCEL_SUBSCRIPTION and you detect "Free plan", "Free", or "No active plan":
             1. Attempt ONE deep-dive (click "Account", "Settings", or Profile icon) to ensure no hidden active subscription exists.
             2. If still on a "Free" or "No Active Pack" page after the check, you MUST use action=done immediately.
             3. Return status: "User is in free plan unable to cancel the subscription."
             4. Do NOT perform any further navigations or searches.

         RULE 7 - HOTSTAR SPECIFICS (CANCEL_SUBSCRIPTION):
           - If you see "Mobile 1 Month" or "JIOIPL" / "Managed by Jio", the plan is managed by a third party and CANNOT be cancelled on the website.
           - If you reach the settings page and do NOT see a clear "Cancel" or "Unsubscribe" link, do NOT click "Payment Details" repeatedly — it leads back to the home page.
           - Instead, use action=done with status: "Your Hotstar plan is managed by a third party (e.g. Jio) and must be cancelled through their platform."

         RULE 19 - HOTSTAR OVERLAY HANDLING:
           - If the CURRENT URL contains `#w-DialogWidget`, a dialog is blocking the page.
           - Your FIRST action MUST be to click the "Close" icon (`i.icon-close`, `button._close`) or navigate to the base URL `https://www.hotstar.com/in/settings` to clear the fragment.

         RULE 20 - REDUNDANT NAVIGATION PREVENTION:
           - If the CURRENT URL already contains `/settings`, you are PROHIBITED from clicking "Manage Account" or "Settings". You are already there.
           - Instead, look specifically for "Cancel Subscription", "Change Plan", or "Payment Details" within the page text or scroll.

         RULE 21 - HOTSTAR PREFER NAVIGATE:
           - On the Hotstar homepage, prefer `action=navigate` with `url: "https://www.hotstar.com/in/settings"` instead of clicking the "Manage Account" button. This avoids accidental clicks on "Download App" links that trigger native app intents.

         RULE 14 - DIRECT NAVIGATION (AMAZON / PRIME):
           - If you are on an Amazon homepage (e.g., amazon.ae, amazon.com) and logged in, do NOT click through "Accounts & Lists".
           - Instead, use `action=navigate` with the direct URL: `[current_domain]/yourmembershipsandsubscriptions`.
           - This avoids complex hover menus and JavaScript loops.

         RULE 15 - AMAZON / OTT "NO ACTIVE PLAN" INTELLIGENCE:
           - If you are on a "Memberships" or "Subscriptions" page and see only "Recommended for you", "Suggested Plans", or buttons like "Join Prime" / "Subscribe", you likely have NO active subscription.
           - DO NOT loop on this page. Check if any card is highlighted as "Current".
           - If no "Current" plan is found, use `action=done` with:
               - `data.plan`: "No active plan"
               - `data.status`: "You have no active [Service] subscription on this account. Only suggested plans are visible."

         RULE 18 - SHAHID OTT SPECIFICS:
           - "اشترك الآن" (Subscribe Now) visible next to a profile name ALWAYS means NO active paid subscription.
           - "إدارة الحساب" (Manage Account) on Shahid often leads to personal info; if you see "اشترك لمتابعة المزيد" (Subscribe to follow more), you are on a FREE plan.
           - Use `action=done` immediately if these "empty" indicators are visible.

         RULE 22 - AUTH REDIRECT PROTECTION:
           - If your previous action was a `navigate` to a target page, but the site redirected you back to a Login/Sign-in page (URL contains `login`, `signin`, `auth`), you are hitting an "Auth Wall".
           - DO NOT TRY THE SAME NAVIGATION AGAIN.
           - You MUST use `action=askUser` to request the user to log in manually.
        ══ NAVIGATION RULES ══════════════════════════════════════════════════════════
        1. ANTI-LOOP: If an action fails to change the page state, DO NOT REPEAT IT.
        2. NO REPEAT NAVIGATIONS: If URL already contains target path, look for elements instead.
        
        ══ ALLOWED ACTIONS ══════════════════════════════════════════════════════════
        { "action": "navigate", "url": "..." }
        { "action": "click", "selector": "..." }
        { "action": "clickText", "text": "..." }
        { "action": "type", "selector": "...", "text": "..." }
        { "action": "scroll", "scrollY": 400 }
        { "action": "extract", "data": { "serviceName": "...", "plan": "...", "price": "...", "billingDate": "...", "status": "..." } }
        { "action": "done", "data": { "status": "..." } }
        { "action": "askUser", "message": "..." } // MUST BE one of: "Please Login and click reautomate", "Select Plan and click reautomate", "Complete Payment and click reautomate", "Confirm Cancellation and click reautomate"
        { "action": "confirm", "message": "..." }
        
        Respond with ONLY a valid JSON action block.
        """
    
    func nextAction(
        task: AgentTask,
        currentURL: String,
        snapshot: PageSnapshot,
        history: [String],
        knownRoute: LearnedRoute?,
        collectedSoFar: String,
        lastActionFailed: Bool
    ) async -> AgentAction? {
        var userContent = ""
        userContent += "GOAL: \(task.displayName) (\(task.intent.rawValue))\n"
        userContent += "CURRENT URL: \(currentURL)\n"
        
        if lastActionFailed {
            userContent += "\n[CRITICAL]: PREVIOUS ACTION FAILED TO CHANGE STATE. TRY DIFFERENT ELEMENT/TEXT.\n"
        }
        
        if let route = knownRoute {
            userContent += "\nKNOWN ROUTE HINT:\n\(route.promptHint())\n"
        }
        
        userContent += "\nCOLLECTED SO FAR: \(collectedSoFar)\n"
        userContent += "\nRECENT ACTIONS:\n" + history.suffix(5).joined(separator: "\n")
        userContent += "\n\n\(snapshot.formatted())"
        userContent += "\n\nRespond with ONLY a valid JSON action block."
        
        do {
            let response: String?
            if activeProvider == .claude {
                response = try await callClaudeAPI(userContent: userContent)
            } else {
                response = try await callChatGPTAPI(userContent: userContent)
            }
            
            print("AgentAIService [nextAction] Raw Response: \(response ?? "NIL")")
            guard let rawText = response else { return nil }
            
            let blocks = extractJsonBlocks(from: rawText)
            for block in blocks.reversed() {
                if let data = block.data(using: .utf8),
                   let action = try? JSONDecoder().decode(AgentAction.self, from: data) {
                    print("AgentAIService [nextAction] Parsed Action: \(action.action?.rawValue ?? "unknown")")
                    return action
                }
            }
        } catch {
            print("AgentAIService: Error in nextAction: \(error)")
        }
        return nil
    }
    
    // MARK: - API Calls
    
    enum AgentAIError: Error {
        case apiError(status: Int, message: String)
        case parsingError
        case noResponse
    }
    
    private func callClaudeAPI(userContent: String, systemOverride: String? = nil) async throws -> String? {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(AgentConfig.claudeAPIKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        let body: [String: Any] = [
            "model": AgentConfig.claudeModel,
            "max_tokens": AgentConfig.maxTokens,
            "system": systemOverride ?? systemPrompt,
            "messages": [["role": "user", "content": userContent]],
            "temperature": 0.0
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("AgentAIService [Claude Request] System: \(systemOverride ?? "DEFAULT")")
        print("AgentAIService [Claude Request] User: \(userContent)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorBody = String(data: data, encoding: .utf8) ?? "no error body"
            print("AgentAIService [Claude Error] Status: \(httpResponse.statusCode) Body: \(errorBody)")
            
            // Extract clear error message from JSON if possible
            var displayError = errorBody
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = json["error"] as? [String: Any],
               let message = error["message"] as? String {
                displayError = message
            }
            throw AgentAIError.apiError(status: httpResponse.statusCode, message: displayError)
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let content = json["content"] as? [[String: Any]],
           let text = content.first?["text"] as? String {
            return text
        }
        return nil
    }
    
    private func callChatGPTAPI(userContent: String, systemOverride: String? = nil) async throws -> String? {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(AgentConfig.openAIAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": AgentConfig.openAIModel,
            "messages": [
                ["role": "system", "content": systemOverride ?? systemPrompt],
                ["role": "user", "content": userContent]
            ],
            "max_tokens": AgentConfig.maxTokens,
            "temperature": 0.0
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("AgentAIService [ChatGPT Request] System: \(systemOverride ?? "DEFAULT")")
        print("AgentAIService [ChatGPT Request] User: \(userContent)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorBody = String(data: data, encoding: .utf8) ?? "no error body"
            print("AgentAIService [ChatGPT Error] Status: \(httpResponse.statusCode) Body: \(errorBody)")
            
            var displayError = errorBody
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = json["error"] as? [String: Any],
               let message = error["message"] as? String {
                displayError = message
            }
            throw AgentAIError.apiError(status: httpResponse.statusCode, message: displayError)
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let message = choices.first?["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        return nil
    }
    
    // MARK: - Resolution Helpers
    
    func resolveServiceName(query: String) async throws -> String? {
        let sys = "You are a service name resolver. Return a JSON with 'displayName' (clean name of the service). ONLY return JSON."
        let user = "Find the service name for: \(query)"
        return try await callSimpleAI(system: sys, user: user, key: "displayName")
    }
    
    func resolveLoginUrl(serviceName: String) async throws -> String? {
        let sys = """
            You are a URL expert. Given a subscription service name, you MUST return the OFFICIAL and DIRECT login page URL.
            
            STRICT RULES:
            1. The URL MUST lead directly to a login interface where the user can authenticate:
               - Email/password fields OR
               - OAuth buttons (Google, Apple, Facebook) OR any
               - Mobile number / OTP login
            
            2. DO NOT return:
               - Generic SSO or Account portals (e.g. accounts.google.com, appleid.apple.com) if the service has its own brand domain (e.g. youtube.com).
               - Marketing landing pages that have no connection to the app.
            
            3. Prefer these paths in order:
               - The main service homepage (e.g. youtube.com), as it will provide a login button or redirect automatically.
               - /login or /signin on the brand's own domain.
            
            7. BRAND IDENTITY (CRITICAL): If the service is YouTube, Gmail, or Drive, you MUST return the service-specific domain (e.g. youtube.com, gmail.com) and NOT the generic Google Accounts URL.
            
            OUTPUT FORMAT (STRICT JSON ONLY):
            {
              "loginURL": "https://example.com"
            }
            """
        let user = "Login page for: \(serviceName)"
        return try await callSimpleAI(system: sys, user: user, key: "loginURL")
    }
    
    func resolveBillingUrl(serviceName: String) async throws -> String? {
        let sys = "Return JSON with 'billingURL' for this service. Direct subscription/billing page to view plan details."
        let user = "Billing page for: \(serviceName)"
        return try await callSimpleAI(system: sys, user: user, key: "billingURL")
    }
    
    private func callSimpleAI(system: String, user: String, key: String) async throws -> String? {
        let response: String?
        if activeProvider == .claude {
            response = try await callClaudeAPI(userContent: user, systemOverride: system)
        } else {
            response = try await callChatGPTAPI(userContent: user, systemOverride: system)
        }
        
        print("AgentAIService [callSimpleAI] Raw Response: \(response ?? "NIL")")
        guard let rawText = response else { return nil }
        
        let blocks = extractJsonBlocks(from: rawText)
        for block in blocks.reversed() {
            if let data = block.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let value = json[key] as? String {
                return value
            }
        }
        return nil
    }
    
    private func extractJsonBlocks(from text: String) -> [String] {
        var blocks: [String] = []
        let characters = Array(text)
        var i = 0
        while i < characters.count {
            if characters[i] == "{" {
                var braceCount = 0
                var start = i
                for j in i..<characters.count {
                    if characters[j] == "{" { braceCount += 1 }
                    else if characters[j] == "}" {
                        braceCount -= 1
                        if braceCount == 0 {
                            blocks.append(String(characters[start...j]))
                            i = j
                            break
                        }
                    }
                }
            }
            i += 1
        }
        return blocks
    }
}
