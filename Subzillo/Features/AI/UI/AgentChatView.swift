import SwiftUI
import WebKit

struct AgentChatView: View {
    @StateObject var viewModel = AgentViewModel()
    @State private var inputText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: Aligned with Subzillo style
            HStack {
                Text("AI Agent")
                    .font(.appBold(24))
                    .foregroundColor(.navyBlueCTA700)
                
                Spacer()
                
                Button {
                    withAnimation { viewModel.showBrowser.toggle() }
                } label: {
                    Image("safari_icon") // Assuming this exists or using a standard icon
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.navyBlueCTA700)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
            .padding(.bottom, 16)
            .background(Color.white)
            
            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let last = viewModel.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            
            // Input Area: Aligned with App Inputs
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    TextField("Ask me something...", text: $inputText)
                        .font(.appRegular(16))
                        .padding()
                        .background(Color.neutralBg100)
                        .cornerRadius(12)
                    
                    Button {
                        viewModel.sendMessage(inputText)
                        inputText = ""
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.navyBlueCTA700)
                            .clipShape(Circle())
                    }
                    .disabled(inputText.isEmpty || viewModel.isAgentRunning)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showBrowser, onDismiss: {
            viewModel.cancel()
        }) {
            AgentBrowserView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Browser View Modal

struct AgentBrowserView: View {
    @ObservedObject var viewModel: AgentViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                AgentWebViewRepresentable(controller: viewModel.browser)
                    .ignoresSafeArea(edges: .bottom)
                
                // POPUP OVERLAY: This shows the OAuth/Google window on top
                if let popup = viewModel.browser.popupWebView {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        VStack(spacing: 0) {
                            HStack {
                                Text("Secure Login")
                                    .font(.appBold(16))
                                Spacer()
                                Button {
                                    viewModel.browser.popupWebView = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            
                            AgentPopupWebViewRepresentable(webView: popup)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding()
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
                
                if viewModel.isInitialLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(1.5)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Leading: Status Message
                ToolbarItem(placement: .principal) {
                    Text(viewModel.displayMessage)
                        .font(.appMedium(14))
                        .foregroundColor(.neutral800)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Trailing: Controls
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        if viewModel.needsIntervention {
                            Button {
                                viewModel.resume()
                            } label: {
                                Text("Reautomate")
                                    .font(.appBold(12))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.navyBlueCTA700)
                                    .cornerRadius(8)
                            }
                        }
                        
                        Button {
                            viewModel.cancel()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.neutral800)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Chat UI Components

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.sender == .user { Spacer() }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 8) {
                if message.sender == .system {
                    Text(message.text)
                        .font(.appMedium(13))
                        .foregroundColor(.secondary)
                        .padding(14)
                        .background(Color.neutralBg100.opacity(0.5))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.neutral800.opacity(0.1), lineWidth: 1)
                        )
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                } else {
                    Text(message.text)
                        .padding(14)
                        .font(.appRegular(15))
                        .background(bubbleColor)
                        .foregroundColor(textColor)
                        .cornerRadius(16, corners: bubbleCorners)
                        .overlay(
                            RoundedCorner(radius: 16, corners: bubbleCorners)
                                .stroke(message.sender == .user ? Color.clear : Color.neutral800.opacity(0.1), lineWidth: 1)
                        )
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.sender == .user ? .trailing : .leading)
                }
                
                if let fields = message.extractedFields, shouldShowCard(fields) {
                    ExtractedDataCard(fields: fields)
                }
            }
            
            if message.sender != .user { Spacer() }
        }
    }
    
    private func shouldShowCard(_ fields: ExtractedFields) -> Bool {
        let plan = fields.plan?.lowercased() ?? ""
        let price = fields.price?.lowercased() ?? ""
        
        // Don't show card if plan/price are missing, N/A, or clearly indicate "none"
        let hasPlan = !plan.isEmpty && plan != "n/a" && plan != "unknown" && !plan.contains("no active")
        let hasPrice = !price.isEmpty && price != "n/a" && price != "unknown"
        
        // Return true if we have any valid plan data
        return hasPlan || hasPrice
    }
    
    private var bubbleColor: Color {
        switch message.sender {
        case .user: return .navyBlueCTA700
        case .agent: return message.isError ? Color.red.opacity(0.1) : .neutralBg100
        case .system: return .clear
        }
    }
    
    private var textColor: Color {
        message.sender == .user ? .white : .neutral800
    }
    
    private var bubbleCorners: UIRectCorner {
        switch message.sender {
        case .user: return [.topLeft, .topRight, .bottomLeft]
        case .agent: return [.topLeft, .topRight, .bottomRight]
        case .system: return []
        }
    }
}

struct ExtractedDataCard: View {
    let fields: ExtractedFields
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(fields.serviceName ?? "Subscription Details")
                .font(.appBold(16))
                .foregroundColor(.navyBlueCTA700)
            
            Divider()
            
            VStack(spacing: 8) {
                row(label: "Plan", value: fields.plan)
                row(label: "Price", value: fields.price)
                row(label: "Bill Date", value: fields.billingDate)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.neutral800.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func row(label: String, value: String?) -> some View {
        if let value = value, !value.isEmpty, value.lowercased() != "n/a", value.lowercased() != "unknown" {
            HStack {
                Text(label)
                    .font(.appRegular(13))
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.appMedium(13))
                    .foregroundColor(.neutral800)
            }
        }
    }
}

// MARK: - Popup WebView Representable
struct AgentPopupWebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
