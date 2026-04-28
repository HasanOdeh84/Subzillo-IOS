import SwiftUI
import WebKit

struct AgentChatView: View {
    @StateObject var viewModel = AgentViewModel()
    @State private var inputText: String = ""
    @State private var showPlusMenu: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: Smart Assistant (Matching Design)
            HStack {
                Button {
                    // Back action
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.navyBlueCTA700)
                }
                
                Spacer()
                
                Text("Smart Assistant")
                    .font(.appBold(24))
                    .foregroundColor(.navyBlueCTA700)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text("AGENTIC")
                        .font(.appBold(12))
                        .foregroundColor(.navyBlueCTA700)
                    
                    Toggle("", isOn: $viewModel.isAgenticMode)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .navyBlueCTA700))
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 16)
            .background(Color.white)
            
            Divider()
            
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
            
            // Input Area: Matching Design
            VStack(spacing: 0) {
                if showPlusMenu {
                    PlusMenuView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                HStack(spacing: 12) {
                    // Gradient Plus Button
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showPlusMenu.toggle()
                        }
                    } label: {
                        Image(systemName: showPlusMenu ? "xmark" : "plus")
                            .font(.title3)
                            .foregroundColor(.navyBlueCTA700)
                            .frame(width: 54, height: 54)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(colors: [Color(hex: "A719DD"), Color(hex: "623BD8"), Color(hex: "4489EB")], startPoint: .topLeading, endPoint: .bottomTrailing),
                                        lineWidth: 1
                                    )
                            )
                    }
                    
                    // Text Input
                    HStack {
                        TextField(showPlusMenu ? "While typing" : "Ask me something...", text: $inputText)
                            .font(.appRegular(16))
                        
                        Button {
                            viewModel.sendMessage(inputText)
                            inputText = ""
                            showPlusMenu = false
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .font(.title3)
                                .foregroundColor(.navyBlueCTA700)
                        }
                        .disabled(inputText.isEmpty || viewModel.isAgentRunning)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 54)
                    .background(Color.neutralBg100.opacity(0.5))
                    .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
                .padding(.top, 12)
                .background(Color.white)
            }
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
                    ZStack {
                        Color.white
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .scaleEffect(1.5)
                    }
                    .ignoresSafeArea()
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
                        .font(.appMedium(12))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.neutralBg100)
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    HStack(alignment: .top, spacing: 10) {
                        if message.sender == .agent {
                            // Bot Icon
                            Image("chatBotIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        
                        // Text Bubble and Data Card Combined
                        VStack(alignment: .leading, spacing: 10) {
                            Text(message.text)
                                .font(.appRegular(15))
                                .foregroundColor(message.sender == .user ? .navyBlueCTA700 : Color(hex: "364560"))
                            
                            // Data Card (Integrated inside bubble)
                            if let fields = message.extractedFields, shouldShowCard(fields) {
                                VStack(spacing: 8) {
                                    DataRow(label: "Service", value: fields.serviceName ?? "Unknown", color: Color(hex: "4489EB"))
                                    DataRow(label: "Price", value: fields.price ?? "N/A", color: Color(hex: "4489EB"))
                                    DataRow(label: "Renewal", value: fields.billingCycle ?? "Monthly", color: Color(hex: "4489EB"))
                                    DataRow(label: "Payment", value: fields.paymentMethod ?? "N/A", color: Color(hex: "4489EB"))
                                }
                            }
                        }
                        .padding(.leading, message.sender == .user ? 16 : 24)
                        .padding(.trailing, message.sender == .user ? 24 : 16)
                        .padding(.vertical, 12)
                        .background(
                            ChatBubbleShape(isUser: message.sender == .user)
                                .fill(message.sender == .user ? Color(hex: "D9E6FA") : Color.white)
                        )
                        .overlay(
                            ChatBubbleShape(isUser: message.sender == .user)
                                .stroke(
                                    message.sender == .user ? AnyShapeStyle(Color.clear) : AnyShapeStyle(LinearGradient(colors: [Color(hex: "A719DD"), Color(hex: "623BD8"), Color(hex: "4489EB")], startPoint: .topLeading, endPoint: .bottomTrailing)),
                                    lineWidth: 1
                                )
                        )
                        
                        if message.sender == .user {
                            // User Avatar Placeholder
                            Image("user_avatar_placeholder") // Or Circle with initial
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .background(Circle().fill(Color.gray.opacity(0.2)))
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.85, alignment: message.sender == .user ? .trailing : .leading)
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
                DataRow(label: "Plan", value: fields.plan, color: .navyBlueCTA700)
                DataRow(label: "Price", value: fields.price, color: .navyBlueCTA700)
                DataRow(label: "Bill Date", value: fields.billingDate, color: .navyBlueCTA700)
            }
        }
    }
}

struct DataRow: View {
    let label: String
    let value: String?
    let color: Color
    
    var body: some View {
        if let value = value, !value.isEmpty, value.lowercased() != "n/a", value.lowercased() != "unknown" {
            HStack {
                Text(label + ":")
                    .font(.appRegular(14))
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.appMedium(14))
                    .foregroundColor(color)
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

// MARK: - Chat Bubble Shape
struct ChatBubbleShape: Shape {
    var isUser: Bool

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()
        let radius: CGFloat = 12
        let tailSize: CGFloat = 8
        let tailOffset: CGFloat = 14
        
        if isUser {
            // Right tail
            path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - tailSize - radius, y: rect.minY))
            path.addArc(withCenter: CGPoint(x: rect.maxX - tailSize - radius, y: rect.minY + radius), radius: radius, startAngle: -.pi/2, endAngle: 0, clockwise: true)
            
            // Tail
            path.addLine(to: CGPoint(x: rect.maxX - tailSize, y: rect.minY + tailOffset))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + tailOffset + (tailSize/2)))
            path.addLine(to: CGPoint(x: rect.maxX - tailSize, y: rect.minY + tailOffset + tailSize))
            
            path.addLine(to: CGPoint(x: rect.maxX - tailSize, y: rect.maxY - radius))
            path.addArc(withCenter: CGPoint(x: rect.maxX - tailSize - radius, y: rect.maxY - radius), radius: radius, startAngle: 0, endAngle: .pi/2, clockwise: true)
            
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
            path.addArc(withCenter: CGPoint(x: rect.minX + radius, y: rect.maxY - radius), radius: radius, startAngle: .pi/2, endAngle: .pi, clockwise: true)
            
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addArc(withCenter: CGPoint(x: rect.minX + radius, y: rect.minY + radius), radius: radius, startAngle: .pi, endAngle: -.pi/2, clockwise: true)
        } else {
            // Left tail
            path.move(to: CGPoint(x: rect.minX + tailSize + radius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
            path.addArc(withCenter: CGPoint(x: rect.maxX - radius, y: rect.minY + radius), radius: radius, startAngle: -.pi/2, endAngle: 0, clockwise: true)
            
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
            path.addArc(withCenter: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius), radius: radius, startAngle: 0, endAngle: .pi/2, clockwise: true)
            
            path.addLine(to: CGPoint(x: rect.minX + tailSize + radius, y: rect.maxY))
            path.addArc(withCenter: CGPoint(x: rect.minX + tailSize + radius, y: rect.maxY - radius), radius: radius, startAngle: .pi/2, endAngle: .pi, clockwise: true)
            
            // Tail
            path.addLine(to: CGPoint(x: rect.minX + tailSize, y: rect.minY + tailOffset + tailSize))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tailOffset + (tailSize/2)))
            path.addLine(to: CGPoint(x: rect.minX + tailSize, y: rect.minY + tailOffset))
            
            path.addLine(to: CGPoint(x: rect.minX + tailSize, y: rect.minY + radius))
            path.addArc(withCenter: CGPoint(x: rect.minX + tailSize + radius, y: rect.minY + radius), radius: radius, startAngle: .pi, endAngle: -.pi/2, clockwise: true)
        }
        
        return Path(path.cgPath)
    }
}

// MARK: - Plus Menu View
struct PlusMenuView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Handle
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 4)
                .padding(.top, 12)
            
            HStack(spacing: 60) {
                PlusMenuButton(icon: "voiceBot")
                PlusMenuButton(icon: "camerBot")
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(24) // Simplified, usually enough for bottom sheet style
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)
    }
}

struct PlusMenuButton: View {
    let icon: String
    
    var body: some View {
        Button {
            // Action
        } label: {
               Image(icon) // Asset image
                .font(.system(size: 32))
                .foregroundColor(.navyBlueCTA700)
                .frame(width: 80, height: 80)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(colors: [Color(hex: "A719DD"), Color(hex: "623BD8"), Color(hex: "4489EB")], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                )
        }
    }
}

