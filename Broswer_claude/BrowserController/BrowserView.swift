// BrowserView.swift
// SwiftUI wrapper around WKWebView.
// Status / controls live in the navigation bar — NEVER overlaid on the web canvas.

import SwiftUI
import WebKit

// MARK: - UIViewRepresentable bridge

struct WebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView { webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Full browser sheet

struct BrowserView: View {

    @ObservedObject var viewModel: ChatViewModel

    private var agent: AgentOrchestrator { viewModel.agent }
    private var browser: BrowserController { agent.browser }

    // Observe the OAuth popup published property directly
    @State private var popupBinding: Bool = false

    var body: some View {
        ZStack {
            // The web view — fills content area below the nav bar.
            // Bottom edge ignores safe area so it reaches the home indicator,
            // but the TOP edge is NOT ignored — web content never goes under the nav bar.
            WebViewRepresentable(webView: agent.browser.webView)
                .ignoresSafeArea(edges: .bottom)

            // Manual mode banner — only shown in manualNavigation state
            // Anchored to the BOTTOM (above home indicator) so it never blocks page content
            if case .manualNavigation = agent.state {
                VStack {
                    Spacer()
                    manualModeBar
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // ── Principal: URL + live AI status text ────────────────────────
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    navBarTitle
                }
            }

            // ── Leading: "Navigate Manually" during AI run ───────────────────
            ToolbarItem(placement: .navigationBarLeading) {
                navBarLeadingButton
            }

            // ── Trailing: Cancel ─────────────────────────────────────────────
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") { viewModel.cancelTask() }
                    .foregroundColor(.red)
            }
        }
        // OAuth popup sheet — presented whenever the main webview spawns a popup
        // ("Login with Google", "Continue with Apple"). Auto-dismisses when the
        // popup calls window.close() after successful authentication.
        .onReceive(browser.$oauthPopup) { popup in
            popupBinding = (popup != nil)
        }
        .sheet(isPresented: $popupBinding, onDismiss: {
            // User swiped down or popup closed — clear and reload parent to pick up session
            if let current = browser.webView.url {
                browser.webView.load(URLRequest(url: current))
            }
            browser.oauthPopup = nil
        }) {
            if let popup = browser.oauthPopup {
                OAuthPopupView(webView: popup) {
                    popupBinding = false
                }
            }
        }
    }

    // MARK: - Navigation bar title area

    @ViewBuilder
    private var navBarTitle: some View {
        switch agent.state {
        case .parsingIntent:
            statusTitle("Finding your request…", icon: "magnifyingglass")
        case .resolvingURL(let service):
            statusTitle("Finding \(service) login URL…", icon: "magnifyingglass")
        case .waitingForLogin(let msg):
            loginTitle(msg)
        case .planning:
            statusTitle("AI is planning…", icon: "brain")
        case .running:
            runningTitle
        case .waitingForConfirmation(let msg, _):
            confirmTitle(msg)
        case .manualNavigation:
            VStack(spacing: 1) {
                Text("Manual Mode")
                    .font(.headline)
                    .foregroundColor(.orange)
                Text("Navigate to billing page")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        default:
            VStack(spacing: 1) {
                Text(agent.browser.pageTitle.isEmpty ? "Browser" : agent.browser.pageTitle)
                    .font(.headline)
                    .lineLimit(1)
                Text(agent.browser.currentURL)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }

    // Compact running status — two lines: AI status + page URL
    private var runningTitle: some View {
        VStack(spacing: 1) {
            HStack(spacing: 5) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.7)
                Text(agent.statusText.isEmpty ? "AI is working…" : agent.statusText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            Text(agent.browser.currentURL)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }

    private func statusTitle(_ text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }

    // Login title shows a compact prompt + inline "I'm Logged In" button
    private func loginTitle(_ msg: String) -> some View {
        VStack(spacing: 3) {
            Text(msg)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Button {
                viewModel.userDidLogin()
            } label: {
                Label("I'm Logged In", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(8)
            }
        }
    }

    // Confirmation title — compact inline approve / deny
    private func confirmTitle(_ msg: String) -> some View {
        VStack(spacing: 3) {
            Text("⚠️ \(msg)")
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            HStack(spacing: 8) {
                Button("Proceed") { viewModel.userConfirmed() }
                    .font(.caption).fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(8)
                Button("Cancel") { viewModel.userDenied() }
                    .font(.caption).fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
        }
    }

    // MARK: - Leading button

    @ViewBuilder
    private var navBarLeadingButton: some View {
        switch agent.state {
        case .running, .waitingForLogin, .planning:
            // Offer the user a manual escape hatch whenever AI is active/waiting
            Button {
                viewModel.enterManualMode()
            } label: {
                Label("Manual", systemImage: "hand.tap")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        default:
            EmptyView()
        }
    }

    // MARK: - Manual mode banner (bottom of screen, outside canvas)

    private var manualModeBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "hand.tap.fill")
                    .foregroundColor(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Manual Navigation Active")
                        .font(.subheadline).fontWeight(.semibold)
                    Text("Navigate to your billing / subscription page")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            Button {
                viewModel.extractNow()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                    Text("Extract Now — AI Learns This Path")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(14)
                .padding(.horizontal)
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 28)   // extra bottom padding above home indicator
        .background(.ultraThinMaterial)
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.18), radius: 10, y: -4)
    }
}

// MARK: - Corner radius helper

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - OAuth Popup Sheet

/// Presents a child WKWebView (created from window.open) as a sheet.
/// Shares cookies with the parent webview — after auth completes and the
/// sheet dismisses, the parent's session is already authenticated.
struct OAuthPopupView: View {
    let webView: WKWebView
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            WebViewRepresentable(webView: webView)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Sign in")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { onClose() }
                    }
                }
        }
    }
}
