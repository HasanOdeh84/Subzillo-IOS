import SwiftUI
import WebKit

import SDWebImageSwiftUI

struct AgentChatView: View {
    @StateObject var viewModel          = AgentViewModel()
    var autoMessage: String? = nil
    @State private var hasAutoSent      : Bool = false
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
    @EnvironmentObject var themeManager : ThemeManager
    @State private var selectedSegment  : Segment? = .first
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            VStack(alignment: .leading, spacing: 0) {
                messagesScrollView
                inputAreaView
            }
            .overlay(Rectangle().frame(height: 1).foregroundColor(.textPrimary0E101AF4F1FB.opacity(0.08)), alignment: .top)
            .padding(.bottom, 100)
        }
        .padding(.top, AppIntentRouter.shared.path.count > 1 ? 0 : 50)
        .navigationBarHidden(true)
        .keyboardAdaptive()
        .applyAppBackground()
        .onAppear {
            // Auto-send upgrade message if navigated from SubscriptionMatchView
            if let message = autoMessage, !hasAutoSent {
                hasAutoSent = true
                viewModel.isAgenticMode = true
                selectedSegment = .first
                viewModel.pendingAutoMessage = message
            } else {
                if viewModel.isAgenticMode == true {
                    selectedSegment = .first
                } else {
                    selectedSegment = .second
                }
            }
        }
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
            .presentationDetents([.height(430)])
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
        .onChange(of: selectedSegment) { newValue in
            if newValue == .first {
                viewModel.isAgenticMode = true
            } else {
                viewModel.isAgenticMode = false
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            if AppIntentRouter.shared.path.count > 1 {
                CircleBackButton {
                    viewModel.clearPendingSession()
                    AppIntentRouter.shared.pop()
                }
            }
            
            ZStack {
                
                // Gradient Icon Box
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        themeManager.accentGradient
                    )
                    .frame(width: 40, height: 40)
                    .shadow(
                        color: themeManager.accentTextColor
                            .opacity(0.55),
                        radius: 12,
                        y: 0
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("BGPrimary_ F7F7F9_0A0612").opacity(0.3), lineWidth: 1)
                    )
                
                Image("sparkles")
                    .frame(width: 22, height: 22)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text("Subzi")
                    .font(.geistSemiBold(15))
                    .tracking(-0.4)
                    .foregroundStyle(
                        Color.textPrimary0E101AF4F1FB
                    )
                HStack {
                    
                    Text("")
                        .font(.geistBold(11))
                        .foregroundColor(.white)
                        .frame(width: 9, height: 9)
                        .background(Color.successLight0EA870.opacity(0.80))
                        .clipShape(Circle())
                        .shadow(color: Color.successLight0EA870, radius: 5, x: 0, y: 0)
                    
                    Text("Online")
                        .font(.jetBrainsBold(11))
                        .foregroundStyle(
                            Color.successLight0EA870
                        )
                }
            }
            Spacer()
            
            HStack(spacing: 8) {
                Text("AGENTIC")
                    .font(.geistBold(15))
                    .foregroundStyle(themeManager.accentGradient)
                
                Button {
                    
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.isAgenticMode.toggle()
                    }
                    
                } label: {
                    ZStack(alignment: viewModel.isAgenticMode ? .trailing : .leading) {
                        
                        RoundedRectangle(cornerRadius: 999)
                            .fill(
                                viewModel.isAgenticMode
                                ? themeManager.accentGradient
                                : LinearGradient(
                                    colors: [
                                        themeManager.black_white.opacity(0.08)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 44, height: 26)
                            .shadow(
                                color: viewModel.isAgenticMode
                                ? themeManager.selectedAccent.senColor
                                    .opacity(0.55)
                                : .clear,
                                radius: 10
                            )
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 20, height: 20)
                            .padding(3)
                            .shadow(
                                color: themeManager.black_white.opacity(0.3),
                                radius: 3,
                                y: 1
                            )
                    }
                }
            }
            
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 16)
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
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
            }
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
            if viewModel.isRecordingAudio {
                HStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Button {
                            viewModel.cancelAudioRecording()
                        } label: {
                            HStack {
                                Image("crossicon")
                                    .renderingMode(.template)
                                    .foregroundStyle(.dangerE43C5CFF5A7A)
                                    .frame(width: 16, height: 16)
                            }
                            .frame(width: 36, height: 36)
                            .background(Color.dangerE43C5CFF5A7A.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 36/2)
                                    .stroke(
                                        Color.dangerE43C5CFF5A7A.opacity(0.5),
                                        lineWidth: 1
                                    )
                            )
                            .cornerRadius(36/2)
                        }
                        
                        Spacer(minLength: 4)
                        
                        ModernWaveformView(power: viewModel.audioPower)
                            .frame(height: 40)
                            .clipped()
                        
                        Spacer(minLength: 4)
                        
                        Text(formatTime(viewModel.recordTime))
                            .font(.geistRegular(14))
                            .foregroundColor(.textPrimary0E101AF4F1FB)
                            .monospacedDigit()
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Button {
                            viewModel.stopAudioRecording()
                        } label: {
                            HStack {
                                Image("tickicon")
                                    .frame(width: 16, height: 16)
                            }
                            .frame(width: 36, height: 36)
                            .background(themeManager.accentGradient)
                            .cornerRadius(24)
                        }
                    }
                    .padding(.horizontal, 6)
                    .frame(height: 48)
                    .background(themeManager.white_white4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                colorScheme == .light ? .textPrimaryLight0E101A.opacity(0.14) : .textPrimaryDarkF4F1FB.opacity(0.10),
                                //                                Color.textPrimary0E101AF4F1FB
                                //                                    .opacity(0.08),
                                lineWidth: 1
                            )
                    )
                    .cornerRadius(24)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .padding(.top, 12)
            } else {
                HStack(spacing: 10) {
                    if !viewModel.isAgenticMode {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showPlusMenu.toggle()
                            }
                        } label: {
                            HStack {
                                Image(showPlusMenu ? "crossiconnew" : "plusicon")
                                    .renderingMode(.template)
                                    .foregroundStyle(themeManager.accentTextColor)
                                    .frame(width: 18, height: 18)
                            }
                            .frame(width: 48, height: 48)
                            .background(themeManager.white_white4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(
                                        showPlusMenu ? themeManager.selectedAccent.senColor : (colorScheme == .light ? .textPrimaryLight0E101A.opacity(0.14) : .textPrimaryDarkF4F1FB.opacity(0.10)),
                                        lineWidth: 1
                                    )
                            )
                            .cornerRadius(24)
                        }
                    }
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
                    }
                    else {
                        // Text Input
                        HStack {
                            ZStack(alignment: .leading) {
                                if inputText == "" {
                                    Text(showPlusMenu ? "While typing" : (viewModel.isAgenticMode ? "Ask the agent..." : "Message Subzi..."))
                                        .foregroundColor(Color.textPrimary0E101AF4F1FB.opacity(0.6))
                                        .font(.geistMedium(12))
                                }
                                TextField("", text: $inputText)
                                    .font(.geistMedium(12))
                                    .foregroundColor(Color.textPrimary0E101AF4F1FB)
                            }
                            .padding(.leading, 12)
                            
                            Button {
                                viewModel.sendMessage(inputText)
                                inputText = ""
                                showPlusMenu = false
                            } label: {
                                HStack {
                                    Image(inputText == "" ? "sendIcon" : "send_white")
                                        .renderingMode(.template)
                                        .foregroundStyle(inputText == "" ? (colorScheme == .light ? .textPrimaryLight0E101A.opacity(0.50) : .textPrimaryDarkF4F1FB) : .white)
                                        .frame(width: 16, height: 16)
                                }
                                .frame(width: 36, height: 36)
                                .background(inputText == "" ? LinearGradient(colors: [themeManager.textPrimaryDark_white07], startPoint: .leading, endPoint: .trailing) : themeManager.accentGradient)
                                
                                .overlay(
                                    RoundedRectangle(cornerRadius: 36/2)
                                        .stroke(
                                            Color.textPrimary0E101AF4F1FB
                                                .opacity(0.08),
                                            lineWidth: 1
                                        )
                                )
                                .cornerRadius(36/2)
                            }
                            .disabled(inputText.isEmpty || viewModel.isAgentRunning)
                        }
                        .padding(.horizontal, 6)
                        .frame(height: 48)
                        .background(themeManager.white_white4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    colorScheme == .light ? .textPrimaryLight0E101A.opacity(0.14) : .textPrimaryDarkF4F1FB.opacity(0.10),
                                    //                                    Color.textPrimary0E101AF4F1FB
                                    //                                        .opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                        .cornerRadius(24)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .padding(.top, 12)
            }
        }
        .overlay(Rectangle().frame(height: 1).foregroundColor(.textPrimary0E101AF4F1FB.opacity(0.08)), alignment: .top)
    }
}

// MARK: - Browser View Modal

struct AgentBrowserView: View {
    @ObservedObject var viewModel       : AgentViewModel
    @EnvironmentObject var themeManager : ThemeManager
    @State private var showPopup        : Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
    private var displayTitle: String {
        viewModel.displayMessage.split(separator: "\n").first.map(String.init) ?? viewModel.displayMessage
    }
    
    private var displaySubtitle: String {
        let lines = viewModel.displayMessage.split(separator: "\n").map(String.init)
        if lines.count > 1 {
            return lines.dropFirst().joined(separator: " ")
        }
        return viewModel.currentStatus.isEmpty ? "Navigating..." : viewModel.currentStatus
    }
    
    private var headerIcon: some View {
        Group {
            if viewModel.needsIntervention {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("yellow_FFB547").opacity(0.16))
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("yellow_FFB547"), lineWidth: 1)
                        )
                    
                    Image("lock_yellow")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(viewModel.showSuccessScreen ? LinearGradient(colors: [Color.green1DD07B.opacity(0.18)], startPoint: .leading, endPoint: .trailing)  : themeManager.accentGradient)
                        .frame(width: 32, height: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.showSuccessScreen ? Color.green1DD07B.opacity(0.45) : themeManager.accentTextColor.opacity(0.5), lineWidth: 1)
                        )
                    
                    Image(viewModel.showSuccessScreen ? "tickicon" : "sparkles")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(viewModel.showSuccessScreen ? Color.green1DD07B : .white)
                        .frame(width: 16, height: 16)
                }
            }
        }
    }
    
    private var headerTextView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(displayTitle)
                .font(.geistSemiBold(14))
                .foregroundColor(.textPrimary0E101AF4F1FB)
                .lineLimit(1)
            
            Text(displaySubtitle)
                .font(.jetBrainsBold(10))
                .foregroundColor(themeManager.textPrimaryLight6_dark62)
                .lineLimit(1)
        }
    }
    
    private var headerCloseButton: some View {
        Button {
            viewModel.cancel()
        } label: {
            Image("crossiconnew")
                .resizable()
                .renderingMode(.template)
                .frame(width: 24, height: 24)
                .padding(5)
                .foregroundColor(
                    colorScheme == .light
                    ? Color("TextPrimary_Light_0E101A").opacity(0.60)
                    : Color.white.opacity(0.60)
                )
                .background(
                    colorScheme == .light
                    ? .textPrimaryDarkF4F1FB
                    : Color.white.opacity(0.10)
                )
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(
                            colorScheme == .light
                            ? Color("TextPrimary_Light_0E101A").opacity(0.10)
                            : Color.white.opacity(0.10),
                            lineWidth: 1
                        )
                )
        }
    }
    
    private var headerPillArea: some View {
        HStack {
            Spacer()
            if viewModel.needsIntervention {
                Button {
                    viewModel.resume()
                } label: {
                    HStack(spacing: 6) {
                        Image("subzi_icon")
                            .frame(width: 12, height: 12)
                        Text("HAND BACK TO SUBZI")
                            .font(.geistExtraBold(10))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(themeManager.selectedAccent.senColor)
                    .clipShape(Capsule())
                    .shadow(color: themeManager.accentTextColor.opacity(0.50), radius: 9, x: 0, y: 6)
                }
            } else {
                HStack(spacing: 6) {
                    Circle()
                        .fill(themeManager.selectedAccent.senColor)
                        .frame(width: 6, height: 6)
                    Text("SUBZI CONTROLLING")
                        .font(.geistBold(10))
                        .foregroundColor(.textPrimary0E101AF4F1FB)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(themeManager.white_white4)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(themeManager.selectedAccent.senColor.opacity(0.3), lineWidth: 1))
                .shadow(color: themeManager.accentTextColor.opacity(0.50), radius: 7, x: 0, y: 4)
            }
        }
    }
    
    private var browserHeader: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                headerIcon
                headerTextView
                Spacer()
                headerCloseButton
            }
            .padding(16)
            
            AnimatedGradientDivider(isLoading: viewModel.browser.isLoading)
            
            headerPillArea
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
        .background(.bottomBGFFFFFF120A1F)
        .background(
            VStack {
                themeManager.selectedAccent.senColor.opacity(0.15)
                    .blur(radius: 40)
                    .frame(height: 100)
                Spacer()
            }
        )
    }
    
    private var webViewArea: some View {
        ZStack {
            if viewModel.showSuccessScreen {
                AgentSuccessView(viewModel: viewModel)
                    .ignoresSafeArea(edges: .bottom)
            } else {
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
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                browserHeader
                webViewArea
            }
            .overlay(
                Group {
                    if !viewModel.needsIntervention {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(themeManager.selectedAccent.senColor, lineWidth: 2)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(themeManager.selectedAccent.senColor.opacity(0.8), lineWidth: 8)
                                    .blur(radius: 20)
                                    .mask(
                                        RoundedRectangle(cornerRadius: 0)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.white],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            )
                                    )
                            }
                            .ignoresSafeArea()
                    }
                }
                    .allowsHitTesting(false)
            )
            .overlay(
                Group {
                    if viewModel.showSuccessScreen {
                        LottieView(name: "onboarding_celebration", loopMode: .loop, isAspectFit: false)
                            .ignoresSafeArea()
                    }
                }
                    .allowsHitTesting(false)
            )
            .navigationBarHidden(true)
            .onReceive(viewModel.browser.$popupWebView) { popup in
                showPopup = (popup != nil)
            }
            .sheet(isPresented: $showPopup, onDismiss: {
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

// MARK: - Success View
struct AgentSuccessView: View {
    @ObservedObject var viewModel: AgentViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Checkmark Circle
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.green1DD07B, Color.green00A862], startPoint: .top, endPoint: .bottom))
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.green1DD07B.opacity(0.55), radius: 15, x: 0, y: 0)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Texts
                VStack(spacing: 12) {
                    Text(viewModel.successIntent == .cancelSubscription ? "Membership canceled" : "Plan changed")
                        .font(.geistBold(19))
                        .foregroundColor(.textPrimary0E101AF4F1FB)
                    
                    let dateText = viewModel.completedFields?.billingDate ?? "the end of your billing cycle"
                    //                let email = Constants.getUserDefaultsValue(for: Constants.userEmail) ?? "your email"
                    
                    Text("You'll keep streaming until **\(dateText)**.")// Confirmation sent to **\(email)**")
                        .font(.geistRegular(12))
                        .foregroundColor(.textPrimary0E101AF4F1FB.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .lineSpacing(4)
                    
                    if let price = viewModel.completedFields?.price, !price.isEmpty {
                        HStack(spacing: 6) {
                            Image("sparkle_green")
                            //                            .resizable()
                            //                            .renderingMode(.template)
                                .frame(width: 11, height: 11)
                            Text("You Saved \(price)")
                                .font(.geistBold(11))
                        }
                        .foregroundColor(Color.success0EA8705CE4A8)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.success0EA8705CE4A8.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.success0EA8705CE4A8.opacity(0.3), lineWidth: 1))
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.bottomBGFFFFFF120A1F)
        }
    }
}

// MARK: - Animated Gradient Divider
struct AnimatedGradientDivider: View {
    var isLoading: Bool
    @EnvironmentObject var themeManager: ThemeManager
    @State private var start = UnitPoint(x: 1, y: 0.5)
    @State private var end = UnitPoint(x: 2, y: 0.5)
    
    var body: some View {
        if isLoading {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(red: 167/255, green: 25/255, blue: 221/255),
                            Color(red: 124/255, green: 92/255, blue: 255/255),
                            Color(red: 68/255, green: 137/255, blue: 235/255),
                            Color.clear
                        ],
                        startPoint: start,
                        endPoint: end
                    )
                )
                .frame(height: 2)
                .onAppear {
                    // Reset state before animating to ensure it starts from the right
                    start = UnitPoint(x: 1, y: 0.5)
                    end = UnitPoint(x: 2, y: 0.5)
                    withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                        start = UnitPoint(x: -1, y: 0.5)
                        end = UnitPoint(x: 0, y: 0.5)
                    }
                }
        } else {
            Divider()
                .background(Color.white.opacity(0.05))
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
    @EnvironmentObject var themeManager : ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    
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
            .font(.geistRegular(14))
            .foregroundColor(Color.textPrimary0E101AF4F1FB)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(colorScheme == .light ? .surfaceLightFFFFFF : .white.opacity(0.0392))
            .cornerRadius(12)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    func botMessageView(message: ChatMessage) -> some View {
        HStack(alignment: .top, spacing: 5) {
            
            // Text Bubble and Data Card Combined
            VStack(alignment: .leading, spacing: 10) {
                // Data Card (Integrated inside bubble)
                // Only show if we don't have structured content already
                if let fields = message.extractedFields, shouldShowCard(fields), !message.text.contains("Provider:") && !message.text.contains("Service:") {
                    let service = fields.serviceName ?? "Service"
                    let planName = fields.plan ?? "Premium"
                    
                    Text("Your \(service) plan is \(planName)\nHere are the subscription details:")
                        .font(.geistRegular(14))
                        .foregroundStyle(Color.textPrimary0E101AF4F1FB)
                        .lineSpacing(4)
                    
                    VStack(spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(service)
                                    .font(.geistBold(13))
                                    .foregroundColor(.textPrimary0E101AF4F1FB)
                                
                                let billing = fields.billingCycle ?? "monthly"
                                Text("\(planName) · \(billing)")
                                    .font(.jetBrainsMedium(10))
                                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            Text("\(fields.currency ?? "")\(fields.price ?? "0")")
                                .font(.geistBold(15))
                                .foregroundColor(.textPrimary0E101AF4F1FB)
                        }
                        .padding(16)
                        
                        Divider()
                            .background(colorScheme == .light ? Color.textPrimaryLight0E101A.opacity(0.14) : .textPrimaryDarkF4F1FB.opacity(0.10))
                        
                        HStack {
                            Text("Renewal Date: \(fields.billingDate ?? "N/A")")
                                .font(.geistMedium(10))
                                .foregroundColor(themeManager.textPrimaryLight6_dark62)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .background(colorScheme == .light ? .surfaceLightFFFFFF : .white.opacity(0.0392))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colorScheme == .light ? Color.textPrimaryLight0E101A.opacity(0.14) : .textPrimaryDarkF4F1FB.opacity(0.10), lineWidth: 1)
                    )
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
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(
                colorScheme == .light ? .surfaceLightFFFFFF : .white.opacity(0.0392)
                //                themeManager.white_white4
            )
            .overlay {
                
                MessageBubbleShape(
                    topLeft: 12,
                    topRight: 12,
                    bottomLeft: 3,
                    bottomRight: 12
                )
                .stroke(
                    //                    Color.textPrimary0E101AF4F1FB
                    //                        .opacity(0.08),
                    colorScheme == .light ? .E_2_E_8_F_0 : .textPrimaryDarkF4F1FB.opacity(0.10),
                    lineWidth: 1
                )
            }
            .clipShape(
                MessageBubbleShape(
                    topLeft: 12,
                    topRight: 12,
                    bottomLeft: 3,
                    bottomRight: 12
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
                        .font(.geistSemiBold(14))
                        .foregroundColor(Color.textPrimaryDarkF4F1FB)
                        .lineSpacing(4)
                }
                
                if let data = message.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            //.padding(.leading, (message.imageData != nil ? 8 : 16))
            // .padding(.trailing, (message.imageData != nil ? 16 : 24))
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(
                themeManager.gradient(style: .horizontal)
            )
            .clipShape(
                MessageBubbleShape(
                    topLeft: 12,
                    topRight: 12,
                    bottomLeft: 12,
                    bottomRight: 3
                )
            )
            .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .trailing)
            
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
                .font(.geistBold(16))
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
                    .font(.geistRegular(14))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
                Spacer()
                Text(value)
                    .font(.geistMedium(14))
                    .foregroundColor(color.opacity(0.6))
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
    @EnvironmentObject var themeManager : ThemeManager
    var body: some View {
        
        HStack {
            
            Button {
                onVoice()
            } label: {
                HStack {
                    Image("voiceBotNew")
                        .frame(width: 16, height: 16)
                }
                .frame(width: 36, height: 36)
                .background(themeManager.textPrimaryDark_white07)
                .overlay(
                    RoundedRectangle(cornerRadius: 36/2)
                        .stroke(
                            Color.textPrimary0E101AF4F1FB
                                .opacity(0.08),
                            lineWidth: 1
                        )
                )
                .cornerRadius(36/2)
            }
            
            Button {
                onCamera()
            } label: {
                HStack {
                    Image("camerBotNew")
                        .frame(width: 16, height: 16)
                }
                .frame(width: 36, height: 36)
                .background(themeManager.textPrimaryDark_white07)
                .overlay(
                    RoundedRectangle(cornerRadius: 36/2)
                        .stroke(
                            Color.textPrimary0E101AF4F1FB
                                .opacity(0.08),
                            lineWidth: 1
                        )
                )
                .cornerRadius(36/2)
            }
            
            Spacer()
        }
        .padding(.horizontal, 6)
        .frame(height: 48)
        .background(themeManager.white_white4)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    Color.textPrimary0E101AF4F1FB
                        .opacity(0.08),
                    lineWidth: 1
                )
        )
        .cornerRadius(24)
        
        /* VStack(spacing: 20) {
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
         .shadow(color: Color.black.opacity(0.05), radius: 10, y: -5)*/
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
    @EnvironmentObject var themeManager : ThemeManager
    var body: some View {
        HStack(spacing: 2) {
            ForEach(history.indices, id: \.self) { i in
                Capsule()
                    .fill(
                        themeManager.accentGradient
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
    @EnvironmentObject var themeManager : ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            HStack(alignment: .top, spacing: 5) {
                
                HStack(spacing: 4) {
                    Text("Thinking")
                        .font(.geistRegular(14))
                        .foregroundColor(Color.textPrimary0E101AF4F1FB)
                    
                    AnimatedDots()
                }
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .background(
                    colorScheme == .light ? .surfaceLightFFFFFF : .white.opacity(0.0392)
                    //                    themeManager.white_white4
                )
                .overlay {
                    MessageBubbleShape(
                        topLeft: 12,
                        topRight: 12,
                        bottomLeft: 3,
                        bottomRight: 12
                    )
                    .stroke(
                        //                        Color.textPrimary0E101AF4F1FB
                        //                            .opacity(0.08),
                        colorScheme == .light ? .E_2_E_8_F_0 : .textPrimaryDarkF4F1FB.opacity(0.10),
                        lineWidth: 1
                    )
                }
                .clipShape(
                    MessageBubbleShape(
                        topLeft: 12,
                        topRight: 12,
                        bottomLeft: 3,
                        bottomRight: 12
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
                    .fill(Color.textPrimary0E101AF4F1FB)
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
                        .font(.geistRegular(12))
                        .foregroundStyle(
                            Color.textPrimary0E101AF4F1FB
                        )
                        .lineSpacing(4)
                }
                
                ForEach(0..<layout.sections.count, id: \.self) { i in
                    let section = layout.sections[i]
                    VStack(alignment: .leading, spacing: 10) {
                        if let title = section.title {
                            Text(renderInline(title))
                                .font(.geistBold(14))
                                .foregroundColor(.textPrimary0E101AF4F1FB)
                                .lineSpacing(4)
                        }
                        
                        VStack(spacing: 8) {
                            ForEach(0..<section.rows.count, id: \.self) { j in
                                let row = section.rows[j]
                                if row.value.isEmpty {
                                    Text(renderInline(row.rawLine))
                                        .font(.geistRegular(14))
                                        .foregroundColor(.textPrimary0E101AF4F1FB)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, 4)
                                        .lineSpacing(4)
                                } else {
                                    HStack(alignment: .top) {
                                        Text(renderInline("\(row.label):"))
                                            .font(.geistMedium(14))
                                            .foregroundColor(.textPrimary0E101AF4F1FB)
                                            .lineSpacing(4)
                                            .padding(.top, 4)
                                        Spacer()
                                        Text(renderInline(row.value))
                                            .font(.geistBold(14))
                                            .foregroundColor(.textPrimary0E101AF4F1FB)
                                            .multilineTextAlignment(.trailing)
                                            .lineSpacing(4)
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
                            .lineSpacing(4)
                    }
                    .font(.geistRegular(14))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
                    .padding(.leading, 8)
                } else if let _ = line.range(of: #"^\d+\.\s"#, options: .regularExpression) {
                    Text(renderInline(line))
                        .font(.geistRegular(14))
                        .foregroundColor(.textPrimary0E101AF4F1FB)
                        .padding(.leading, 4)
                        .lineSpacing(4)
                } else {
                    Text(renderInline(line))
                        .font(.geistRegular(14))
                        .foregroundColor(.textPrimary0E101AF4F1FB)
                        .lineSpacing(4)
                }
            }
        }
    }
}

struct QuickRepliesRow: View {
    let replies: [String]
    let onReplyClick: (String) -> Void
    @EnvironmentObject var themeManager : ThemeManager
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(replies, id: \.self) { reply in
                    Button {
                        onReplyClick(reply)
                    } label: {
                        Text(reply)
                            .font(.geistSemiBold(13))
                            .foregroundColor(themeManager.accentTextColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.clear)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(themeManager.accentTextColor, lineWidth: 1)
                            )
                            .shadow(color: themeManager.accentTextColor.opacity(0.55), radius: 10, x: 0, y: 4)
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
struct MessageBubbleShape: Shape {
    
    var topLeft: CGFloat = 0
    var topRight: CGFloat = 0
    var bottomLeft: CGFloat = 0
    var bottomRight: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        
        path.addArc(
            center: CGPoint(x: rect.maxX - topRight, y: rect.minY + topRight),
            radius: topRight,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        
        path.addArc(
            center: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight),
            radius: bottomRight,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        
        path.addArc(
            center: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY - bottomLeft),
            radius: bottomLeft,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        
        path.addArc(
            center: CGPoint(x: rect.minX + topLeft, y: rect.minY + topLeft),
            radius: topLeft,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        path.closeSubpath()
        
        return path
    }
}
