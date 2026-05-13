import SwiftUI
import WebKit

import SDWebImageSwiftUI

struct AgentChatView: View {
    @StateObject var viewModel          = AgentViewModel()
    @EnvironmentObject var commonApiVM  : CommonAPIViewModel
    @State private var inputText        : String = ""
    @State private var showPlusMenu     : Bool = false
    @State private var showImagePicker  : Bool = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage    : UIImage? = nil
    @State private var showCameraOptions: Bool = false
    @State private var showUploadPopup  = false
    @State private var isUploading      = false
    @Environment(\.dismiss) var dismiss
    private let bottomAnchor            = "BOTTOM_ANCHOR"
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            messagesScrollView
            inputAreaView
        }
        .padding(.top, AppIntentRouter.shared.path.count > 1 ? 0 : 50)
        .padding(.bottom, 90)
        .navigationBarHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ChatImagePicker(selectedImage: $selectedImage, sourceType: imagePickerSource)
        }
        .sheet(isPresented: $showUploadPopup, onDismiss: {
        }) {
            UploadImageSheet(isUploading: $isUploading, fromProfile: false, isChatBot: true, onDelegate: {
            }, onImageSelected: { image in
                viewModel.sendImage(image)
            })
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(470)])
            .interactiveDismissDisabled(isUploading)
        }
        .onChange(of: selectedImage) { newImage in
            if let image = newImage {
                viewModel.sendImage(image)
                selectedImage = nil
            }
        }
        .onChange(of: viewModel.transcribedText) { newText in
            if !newText.isEmpty {
                inputText = newText
                viewModel.transcribedText = ""
            }
        }
        .sheet(isPresented: $viewModel.showBrowser, onDismiss: {
            viewModel.cancel()
        }) {
            AgentBrowserView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onDisappear {
            viewModel.clearPendingSession()
        }
    }
    
    private var headerView: some View {
        HStack {
            if AppIntentRouter.shared.path.count > 1 {
                Button {
                    viewModel.clearPendingSession()
                    AppIntentRouter.shared.pop()
                } label: {
                    Image("back_gray")
                }
            }
            
            Text("Smart Assistant")
                .font(.appRegular(24))
                .foregroundColor(.neutralMain700)
                .padding(.leading, 8)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("AGENTIC")
                    .font(.appBold(12))
                    .foregroundColor(viewModel.isAgenticMode ? .linearGradient3 : .navyBlueCTA700)
                
                Toggle("", isOn: $viewModel.isAgenticMode)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .linearGradient3))
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .padding(.bottom, 16)
        .background(Color.white)
    }
    
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(message: message, viewModel: viewModel)
                            .id(message.id)
                    }
                    if viewModel.isThinking {
                        ThinkingBubble()
                            .id("thinking")
                    }
                    
                    Color.clear
                        .frame(height: 10) // Adjust spacing as needed
                        .id(bottomAnchor)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.neutralBg100)
            .onChange(of: viewModel.messages.count) { _ in
                withAnimation {
                    proxy.scrollTo(bottomAnchor, anchor: .bottom)
                }
            }
            .onChange(of: viewModel.isThinking) { thinking in
                if thinking {
                    withAnimation {
                        proxy.scrollTo(bottomAnchor, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private var inputAreaView: some View {
        VStack(spacing: 0) {
            if showPlusMenu {
                PlusMenuView(onVoice: {
                    withAnimation(.spring()) {
                        viewModel.startAudioRecording()
                        showPlusMenu = false
                    }
                }, onCamera: {
                    showUploadPopup = true
                    showPlusMenu = false
                })
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            if viewModel.isRecordingAudio {
                HStack(spacing: 8) {
                    Button {
                        viewModel.cancelAudioRecording()
                    } label: {
                        Text("Cancel")
                            .font(.appMedium(14))
                            .foregroundColor(.red)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    
                    Spacer(minLength: 4)
                    
                    ModernWaveformView(power: viewModel.audioPower)
                        .frame(height: 40)
                        .clipped()
                    
                    Spacer(minLength: 4)
                    
                    Text(formatTime(viewModel.recordTime))
                        .font(.appMedium(14))
                        .foregroundColor(.neutralMain700)
                        .monospacedDigit()
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    Button {
                        viewModel.stopAudioRecording()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.blueMain700)
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(Color.neutralBg100)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .padding(.top, 12)
                .background(Color.white)
            } else {
                HStack(spacing: 12) {
                    if !viewModel.isAgenticMode {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showPlusMenu.toggle()
                            }
                        } label: {
                            Image(systemName: showPlusMenu ? "xmark" : "plus")
                                .font(.title3)
                                .foregroundColor(.linearGradient3)
                                .frame(width: 52, height: 52)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            lineWidth: 1
                                        )
                                )
                        }
                    }
                    
                    // Text Input
                    HStack {
                        ZStack(alignment: .leading) {
                            if inputText == "" {
                                Text(showPlusMenu ? "While typing" : (viewModel.isAgenticMode ? "Ask the agent..." : "Ask the chatbot..."))
                                    .foregroundColor(Color.neutral400)
                                    .font(.appRegular(16))
                            }
                            TextField("", text: $inputText)
                                .font(.appRegular(16))
                        }
                        
                        Button {
                            viewModel.sendMessage(inputText)
                            inputText = ""
                            showPlusMenu = false
                        } label: {
                            Image(inputText == "" ? "send_gray" : "send_blue")
                                .frame(width: 24, height: 24)
                        }
                        .disabled(inputText.isEmpty || viewModel.isAgentRunning)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 54)
                    .background(Color.neutralBg100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                .neutral100,
                                lineWidth: 1
                            )
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .padding(.top, 12)
                .background(Color.white)
            }
        }
        .background(Color.white)
        .overlay(Rectangle().frame(height: 1).foregroundColor(.neutral100), alignment: .top)
    }
}

// MARK: - Browser View Modal

struct AgentBrowserView: View {
    @ObservedObject var viewModel: AgentViewModel

    @State private var showPopup: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AgentWebViewRepresentable(controller: viewModel.browser)
                    .ignoresSafeArea(edges: .bottom)
                

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

            .onReceive(viewModel.browser.$popupWebView) { popup in
                showPopup = (popup != nil)
            }
            .sheet(isPresented: $showPopup, onDismiss: {
                // User swiped down or popup closed — clear and reload parent to pick up session
                if let current = viewModel.browser.webView.url {
                    viewModel.browser.webView.load(URLRequest(url: current))
                }
                viewModel.browser.popupWebView = nil
            }) {
                if let popup = viewModel.browser.popupWebView {
                    AgentOAuthPopupView(webView: popup) {
                        showPopup = false
                    }
                }
            }
        }
    }
}

// MARK: - OAuth Popup Sheet
struct AgentOAuthPopupView: View {
    let webView: WKWebView
    let onClose: () -> Void
    
    var body: some View {
        NavigationStack {
            AgentPopupWebViewRepresentable(webView: webView)
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

// MARK: - Chat UI Components

struct MessageBubble: View {
    let message: ChatMessage

    @ObservedObject var viewModel: AgentViewModel
    @EnvironmentObject var commonApiVM: CommonAPIViewModel
    
    private var gradientPlaceholder: some View {
        Image("profile_pic")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
    }
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
                userMessageView
            } else if message.sender == .agent {
                botMessageView(message: message)
                Spacer()
            } else if message.sender == .system {
                systemMessageView
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var systemMessageView: some View {
        Text(message.text)
            .font(.appMedium(12))
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.neutralBg100)
            .cornerRadius(12)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    func botMessageView(message: ChatMessage) -> some View {
        HStack(alignment: .top, spacing: 5) {
            // Bot Icon
            Image("chatBotProfile")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Text Bubble and Data Card Combined
            VStack(alignment: .leading, spacing: 10) {
                // Data Card (Integrated inside bubble)
                // Only show if we don't have structured content already
                if let fields = message.extractedFields, shouldShowCard(fields), !message.text.contains("Provider:") && !message.text.contains("Service:") {
                    Text("Your current plan details:")
                        .font(.appMedium(14))
                        .foregroundColor(.blueMain700)
                    
                    VStack(spacing: 8) {
                        if let serviceName = fields.serviceName {
                            DataRow(label: "Service", value: serviceName, color: .blueMain700)
                        }
                        if let billing = fields.billingCycle {
                            DataRow(label: "Renewal", value: billing, color: .blueMain700)
                        }
                        if let plan = fields.plan {
                            DataRow(label: "Plan", value: plan, color: .blueMain700)
                        }
                        if let price = fields.price {
                            DataRow(label: "Price", value: "\(price) \(fields.currency ?? "")", color: .blueMain700)
                        }
                        if let nextDate = fields.billingDate {
                            DataRow(label: "Next Date", value: nextDate, color: .blueMain700)
                        }
                    }
                    .padding(.bottom, 8)
                }
                
                if !message.text.isEmpty {
                    ChatBotMarkdownContent(content: message.text)
                }
                
                if let data = message.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                if !message.suggestedReplies.isEmpty {
                    QuickRepliesRow(replies: message.suggestedReplies) { reply in
                        viewModel.sendMessage(reply)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.leading, 24)
            .padding(.trailing, 16)
            .padding(.vertical, 12)
            .background(
                ChatBubbleShape(isUser: false)
                    .fill(Color.white)
                    .overlay(
                        ChatBubbleShape(isUser: false)
                            .stroke(
                                AnyShapeStyle(LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700], startPoint: .topLeading, endPoint: .bottomTrailing)),
                                lineWidth: 1
                            )
                    )
            )
            .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .leading)
        }
    }
    
    var userMessageView: some View {
        HStack(alignment: .top, spacing: 5) {
            // Text Bubble and Data Card Combined
            VStack(alignment: .leading, spacing: 10) {
                if !message.text.isEmpty {
                    Text(renderInline(message.text))
                        .font(.appRegular(15))
                        .foregroundColor(Color.neutralMain700)
                        .lineSpacing(10)
                }
                
                if let data = message.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.leading, (message.imageData != nil ? 8 : 16))
            .padding(.trailing, (message.imageData != nil ? 16 : 24))
            .padding(.vertical, 12)
            .background(
                ChatBubbleShape(isUser: true)
                    .fill(Color.primaryBlue200)
            )
            .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .trailing)
            
            if let profileImage = commonApiVM.userInfoResponse?.profileImage, !profileImage.isEmpty, let url = URL(string: profileImage) {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            } else {
                gradientPlaceholder
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    func shouldShowCard(_ fields: ExtractedFields) -> Bool {
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
                    .foregroundColor(.neutralMain700)
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
    let onVoice: () -> Void
    let onCamera: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Handle
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 150, height: 5)
                .padding(.top, 16)
            
            HStack() {
                PlusMenuButton(icon: "voiceBot") { onVoice() }
                Spacer()
                PlusMenuButton(icon: "camerBot") { onCamera() }
            }
            .padding(.bottom, 16)
            .padding(.horizontal, 46)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(24)
        .overlay(Rectangle().frame(height: 1).foregroundColor(.neutral100), alignment: .top)
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)
    }
}

struct PlusMenuButton: View {
    var icon: String? = nil
    var systemIcon: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                if let icon = icon {
                    Image(icon)
                        .font(.system(size: 32))
                        .foregroundColor(.navyBlueCTA700)
                        .frame(width: 80, height: 80)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 1
                                )
                        )
                } else if let systemIcon = systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: 32))
                        .foregroundColor(.navyBlueCTA700)
                        .frame(width: 80, height: 80)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700], startPoint: .topLeading, endPoint: .bottomTrailing),
                                    lineWidth: 1
                                )
                        )
                }
            }
        }
    }
}

// MARK: - Voice UI Helpers

struct WaveformView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<12) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.navyBlueCTA700)
                    .frame(width: 3, height: isAnimating ? CGFloat.random(in: 15...35) : 10)
                    .animation(Animation.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.05), value: isAnimating)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct ModernWaveformView: View {
    var power: Float
    
    @State private var history: [CGFloat] = Array(repeating: 0.05, count: 40)
    
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(history.indices, id: \.self) { i in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.blueMain700, Color.linearGradient3],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2.5, height: max(1.5, history[i] * 40 + CGFloat.random(in: 0...0.5)))
                    .animation(
                        .spring(response: 0.2, dampingFraction: 0.7),
                        value: history[i]
                    )
            }
        }
        .onReceive(timer) { _ in
            history.removeFirst()
            history.append(CGFloat(power))
        }
    }
}

extension View {
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ThinkingBubble: View {
    var body: some View {
        HStack {
            HStack(alignment: .top, spacing: 5) {
                Image("chatBotProfile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                HStack(spacing: 4) {
                    Text("Thinking")
                        .font(.appMedium(15))
                        .foregroundColor(Color.neutralMain700)
                    
                    AnimatedDots()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    ChatBubbleShape(isUser: false)
                        .fill(Color.white)
                )
                .overlay(
                    ChatBubbleShape(isUser: false)
                        .stroke(
                            AnyShapeStyle(LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700], startPoint: .topLeading, endPoint: .bottomTrailing)),
                            lineWidth: 1
                        )
                )
            }
            Spacer()
        }
    }
}

struct AnimatedDots: View {
    @State private var opacities: [Double] = [0.2, 0.2, 0.2]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.navyBlueCTA700)
                    .frame(width: 4, height: 4)
                    .opacity(opacities[i])
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(Double(i) * 0.2)) {
                            opacities[i] = 1.0
                        }
                    }
            }
        }
    }
}

// MARK: - Markdown & Extraction UI

struct ChatBotMarkdownContent: View {
    let content: String
    
    var body: some View {
        if let layout = parseExtractionLayout(content) {
            VStack(alignment: .leading, spacing: 12) {
                if let intro = layout.intro, !intro.isEmpty {
                    Text(renderInline(intro))
                        .font(.appMedium(14))
                        .foregroundColor(.neutralMain700)
                        .lineSpacing(10)
                }
                
                ForEach(0..<layout.sections.count, id: \.self) { i in
                    let section = layout.sections[i]
                    VStack(alignment: .leading, spacing: 10) {
                        if let title = section.title {
                            Text(renderInline(title))
                                .font(.appBold(14))
                                .foregroundColor(.neutralMain700)
                                .lineSpacing(10)
                        }
                        
                        VStack(spacing: 8) {
                            ForEach(0..<section.rows.count, id: \.self) { j in
                                let row = section.rows[j]
                                if row.value.isEmpty {
                                    Text(renderInline(row.rawLine))
                                        .font(.appRegular(14))
                                        .foregroundColor(.neutralMain700)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 4)
                                        .lineSpacing(10)
                                } else {
                                    HStack(alignment: .top) {
                                        Text(renderInline("\(row.label):"))
                                            .font(.appMedium(14))
                                            .foregroundColor(.neutralMain700)
                                            .lineSpacing(10)
                                            .padding(.top, 4)
                                        Spacer()
                                        Text(renderInline(row.value))
                                            .font(.appBold(14))
                                            .foregroundColor(.blueMain700)
                                            .multilineTextAlignment(.trailing)
                                            .lineSpacing(10)
                                            .padding(.top, 4)
                                    }
                                }
                            }
                        }
                        
                        if i < layout.sections.count - 1 {
                            Divider()
                                .opacity(0.3)
                        }
                    }
                }
            }
        } else {
            renderStandardMarkdown(content)
        }
    }
    
    private func renderStandardMarkdown(_ content: String) -> some View {
        let lines = content.components(separatedBy: "\n")
        return VStack(alignment: .leading, spacing: 4) {
            ForEach(0..<lines.count, id: \.self) { i in
                let line = lines[i].trimmingCharacters(in: .whitespaces)
                if line.isEmpty {
                    Spacer().frame(height: 8)
                } else if line.hasPrefix("- ") {
                    HStack(alignment: .top) {
                        Text("•")
                        Text(renderInline(String(line.dropFirst(2))))
                            .lineSpacing(10)
                    }
                    .font(.appRegular(14))
                    .foregroundColor(.neutralMain700)
                    .padding(.leading, 8)
                } else if let _ = line.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                    Text(renderInline(line))
                        .font(.appRegular(14))
                        .foregroundColor(.neutralMain700)
                        .padding(.leading, 4)
                        .lineSpacing(10)
                } else {
                    Text(renderInline(line))
                        .font(.appRegular(14))
                        .foregroundColor(.neutralMain700)
                        .lineSpacing(10)
                }
            }
        }
    }
}

struct QuickRepliesRow: View {
    let replies: [String]
    let onReplyClick: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(replies, id: \.self) { reply in
                    Button {
                        onReplyClick(reply)
                    } label: {
                        Text(reply)
                            .font(.appMedium(12))
                            .foregroundColor(.linearGradient4)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.blueMain700], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                            )
                    }
                    .padding(.vertical, 5)
                    .padding(.leading, 5)
                }
            }
            .padding(.trailing, 16)
        }
    }
}

// MARK: - Parsing Logic

struct KeyValueItem {
    let label: String
    let value: String
    let rawLine: String
}

struct ExtractionSection {
    let title: String?
    let rows: [KeyValueItem]
}

struct ExtractionLayout {
    let intro: String?
    let sections: [ExtractionSection]
}

private let PROVIDER_DETAIL_LABELS: Set<String> = [
    "provider", "service", "plan", "plan name", "price",
    "billing cycle", "renewal", "renewal date", "payment",
    "payment method", "category", "currency"
]

func parseExtractionLayout(_ content: String) -> ExtractionLayout? {
    let lines = content.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
    var sections: [ExtractionSection] = []
    var introLines: [String] = []
    var currentRows: [KeyValueItem] = []
    var currentTitle: String? = nil
    var seenStructuredData = false
    
    func pushCurrentSection() {
        if !currentRows.isEmpty {
            sections.append(ExtractionSection(title: currentTitle, rows: currentRows))
        }
        currentRows = []
        currentTitle = nil
    }
    
    for line in lines {
        if line.isEmpty { continue }
        
        if line.range(of: #"^[-_]{3,}$"#, options: .regularExpression) != nil {
            pushCurrentSection()
            continue
        }
        
        if let match = line.range(of: #"^(\d+\.\s+.+)$"#, options: .regularExpression) {
            pushCurrentSection()
            currentTitle = String(line[match])
            seenStructuredData = true
            continue
        }
        
        if let colonIndex = line.firstIndex(of: ":") {
            let label = String(line[..<colonIndex]).trimmingCharacters(in: .whitespaces)
            let value = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
            currentRows.append(KeyValueItem(label: label, value: value, rawLine: line))
            seenStructuredData = true
            continue
        }
        
        if !seenStructuredData {
            introLines.append(line)
            continue
        }
        
        currentRows.append(KeyValueItem(label: line, value: "", rawLine: line))
    }
    pushCurrentSection()
    
    if !seenStructuredData || sections.isEmpty { return nil }
    if !isProviderDetailsLayout(sections) { return nil }
    
    return ExtractionLayout(intro: introLines.joined(separator: " "), sections: sections)
}

func isProviderDetailsLayout(_ sections: [ExtractionSection]) -> Bool {
    var recognizedCount = 0
    var hasProviderOrService = false
    
    for section in sections {
        for row in section.rows {
            let normalizedLabel = row.label.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespaces).lowercased()
            if PROVIDER_DETAIL_LABELS.contains(normalizedLabel) { recognizedCount += 1 }
            if normalizedLabel == "provider" || normalizedLabel == "service" { hasProviderOrService = true }
        }
    }
    return recognizedCount >= 3 || (hasProviderOrService && recognizedCount >= 2)
}

func renderInline(_ text: String) -> AttributedString {
    var attributedString = AttributedString(text)
    
    // Pattern to match **bold text**
    let pattern = #"(\*\*)(.*?)(\*\*)"#
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        return attributedString
    }
    
    let nsText = text as NSString
    let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))
    
    // Process matches in reverse to maintain string indices during replacement
    for match in matches.reversed() {
        if match.numberOfRanges > 2,
           let fullRange = Range(match.range(at: 0), in: text),
           let contentRange = Range(match.range(at: 2), in: text) {
            
            let boldPart = text[contentRange]
            
            if let start = AttributedString.Index(fullRange.lowerBound, within: attributedString),
               let end = AttributedString.Index(fullRange.upperBound, within: attributedString) {
                let attrRange = start..<end
                var boldAttr = AttributedString(boldPart)
                boldAttr.inlinePresentationIntent = .stronglyEmphasized
                attributedString.replaceSubrange(attrRange, with: boldAttr)
            }
        }
    }
    
    return attributedString
}
