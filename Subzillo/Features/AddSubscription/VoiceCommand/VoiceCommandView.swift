//
//  VoiceCommandView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 18/09/25.
//
import SwiftUI
import AVFoundation

struct VoiceCommandView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject var voiceCommandVM         = VoiceCommandViewModel()
    @State private var showPermissionAlert  = false
    @State var showDiscardPopup             : Bool = false
    @StateObject private var audioManager   = AudioRecorderManager()
    @State private var isPlaying            = false
    @State var showMissingDetailsPopup      : Bool = false
    @State private var deleteSheetHeight    : CGFloat = .zero
    @EnvironmentObject var themeManager     : ThemeManager
    
    //MARK: - body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // MARK: - Header
            HStack {
                CircleBackButton(action: goBack)
                
                Spacer()
                
                // Timer
                if audioManager.isRecording{
                    HStack(spacing: 6) {
                        Circle()
                            .fill(.dangerE43C5CFF5A7A)
                            .frame(width: 8, height: 8)
                        //                            .opacity(audioManager.isRecording ? 1.0 : 0.0)
                            .shadow(color: .dangerE43C5CFF5A7A.opacity(0.3), radius: 5, x: 0, y: 0)
                        
                        Text(audioManager.isRecording ? "REC \(formatTime(Int(audioManager.recordTime)))" : "0:00")
                            .font(.jetBrainsBold(11))
                            .foregroundColor(.dangerE43C5CFF5A7A)
                            .tracking(2)
                    }
                    .padding(.trailing, 40)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            
            if voiceCommandVM.isLoading {
                ValidatingLoaderView()
            } else {
                Spacer()
                
                // MARK: - Mic Button
                ZStack {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(
                                themeManager.accentTextColor.opacity(0.50),
                                lineWidth: 1
                            )
                            .scaleEffect(1)
                            .opacity(0.8)
                            .frame(width: 180, height: 180)
                            .modifier(
                                SuccessRingAnimation(delay: Double(index) * 0.4)
                            )
                    }
                    
                    ZStack {
                        Circle()
                            .fill(
                                themeManager.gradient(style: .diagonal)
                            )
                            .frame(width: 140, height: 140)
                            .shadow(
                                color: themeManager.accentTextColor.opacity(0.70),
                                radius: 20,
                                x: 0,
                                y: 10
                            )
                        
                        Image("voice_new")
                            .frame(width: 42, height: 42)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
                
                // MARK: - Listening and Waveform
                if audioManager.isRecording {
                    HStack{
                        Spacer()
                        VStack(spacing: 16) {
                            Text("Listening...")
                                .font(.geistSemiBold(26))
                                .foregroundColor(Color.textPrimary0E101AF4F1FB)
                            
                            PlaybackWaveformView(isPlaying: audioManager.isRecording)
                                .frame(height: 80)
                                .padding(.top, 10)
                        }
                        .transition(.opacity)
                        Spacer()
                    }
                }
                
                Spacer()
                
                // MARK: - Bottom Buttons
                if audioManager.isRecording {
                    HStack(spacing: 16) {
                        // Cancel Button
                        CustomBorderButton(
                            title       : "Cancel",
                            background  : Color.clear,
                            action      : {
                                audioManager.stopRecording()
                                audioManager.discardAll()
                                voiceCommandVM.resetVoiceFlow()
                            }
                        )
                        
                        // Stop & validate Button
                        GradientBgButton(
                            title       : "Stop & validate",
                            isSolid     : true,
                            showChevron : false
                        ) {
                            audioManager.stopRecording()
                            if let url = audioManager.audioURL {
                                submitAction(url: url)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                } else {
                    VStack(spacing: 32){
                        Text("Tap the Start button to begin recording")
                            .font(.geistBold(16))
                            .foregroundColor(.textPrimary0E101AF4F1FB)
                        
                        // Initial Start Button
                        GradientBgButton(
                            title       : "Start",
                            isSolid     : true,
                            showChevron : false
                        ) {
                            audioManager.startRecording()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                    }
                }
            }
        }
        .padding(.top, 10)
        .applyAppBackground()
        .onAppear {
            audioManager.discardAll()
            showMissingDetailsPopup = true
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $voiceCommandVM.showErrorPopup) {
            InfoVoiceAlertSheet(
                onDelegate: {
                    voiceCommandVM.showErrorPopup = false
                    audioManager.discardAll()
                },
                title       : "I'm Not Sure I Heard That Right",
                imageName   : "earIcon",
                buttonIcon  : "tryIcon",
                buttonTitle : "Try Again",
                titleFont   : .appSemiBold(24),
                imageSize   : 84
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(300)])
        }
        .sheet(isPresented: $showPermissionAlert) {
            PermissionSheet(onDelegate: {
                //dismiss()
            }, title: "We need microphone access to add subscriptions by voice", type: "voice", value: "Tap Microphone")
            .id(UUID())
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(580)])
        }
        .sheet(isPresented: $showDiscardPopup) {
            InfoAlertSheet(
                onDelegate: {
                    audioManager.discardAll()
                }, title    : "Are you sure you want to discard the recording?",
                subTitle    : "",
                imageName   : "infoIcon",
                buttonIcon  : "deleteIcon",
                buttonTitle : "Discard"
            )
            .id(UUID())
            .onPreferenceChange(InnerHeightPreferenceKey.self) { height in
                if height > 0 {
                    deleteSheetHeight = height
                }
            }
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(deleteSheetHeight)])
        }
        .sheet(isPresented: $voiceCommandVM.showMissingDetailsBottomSheet, onDismiss: {
        }) {
            VoiceMissingDetailsSheet(missingDetailsList : voiceCommandVM.missingDetailsList,
                                     onSubmit           : {url in
                submitAction(url: url)
            },
                                     onSkipToContinue   : {
                reviewScreen()
            })
            .presentationDragIndicator(.hidden)
            .presentationDetents([.large])
        }
        .modifier(LoaderModifier())
        .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
            voiceCommandVM.showErrorPopup = false
            showPermissionAlert = false
            showDiscardPopup = false
        }
        .onChange(of: audioManager.requiredPermission) { _ in
            if audioManager.requiredPermission{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showPermissionAlert = true
                }
            }
        }
        .onChange(of: audioManager.isPlaying) { _ in
            if !audioManager.isPlaying{
                isPlaying = false
            }
        }
        .onDisappear {
            voiceCommandVM.resetVoiceFlow()
        }
    }
    
    private func clickOnHowItWorks() {
    }
    
    //MARK: - Back action
    private func goBack() {
        audioManager.discardAll()
        AppIntentRouter.shared.pop()
    }
    
    //MARK: - Submit action
    private func submitAction(url:URL) {
        audioManager.pausePlayback()
        let voiceData = try! Data(contentsOf: url)
        //        let voiceData:Data = try! Data(contentsOf: audioManager.audioURL)
        voiceCommandVM.voiceSubscription(input: VoiceSubscriptionRequest(userId: Constants.getUserId()), fileData: [MultiPartFileInput(
            fieldName   : "audio",
            fileName    : "recording.m4a",
            mimeType    : "audio/x-m4a",
            fileData    : voiceData
        )], audioUrl: url)
    }
    
    func stopBtn(){
        audioManager.stopRecording()
    }
    
    func reviewScreen(){
        AppIntentRouter.shared.navigate(
            to: .subscriptionPreviewView(
                subscriptionsData   : voiceCommandVM.storedSubscriptions,
                content             : "",
                isFromImage         : false,
                audioUrl            : voiceCommandVM.mergedAudioURL
            )
        )
    }
    
    // MARK: - Format Time
    private func formatTime(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        else
        {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    //    VoiceCommandView()
}

//MARK: - GradientThumbSlider
struct GradientThumbSlider: View {
    
    //MARK: - Properties
    @Binding var value  : Double
    var range           : ClosedRange<Double>
    var thumbImage      : String
    
    var body: some View {
        GeometryReader { geo in
            
            let width = geo.size.width
            
            // 👉 ADD THIS HERE (before using progress)
            let progressRaw = (value - range.lowerBound) /
            (range.upperBound - range.lowerBound)
            
            let progress = progressRaw.isFinite
            ? max(0, min(1, progressRaw))
            : 0
            
            ZStack(alignment: .leading) {
                
                // Background track
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
                
                // Filled gradient track
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.linearGradient3,
                                Color.linearGradient4,
                                Color.blueMain700
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(0, min(width, width * progress)),
                        height: 6
                    )
                
                // Thumb image
                //                Image(thumbImage)
                //                    .resizable()
                //                    .frame(width: 24, height: 24)
                //                    .offset(x: max(0, min(width - 24, width * progress - 12)))
                //                    .gesture(
                //                        DragGesture()
                //                            .onChanged { gesture in
                //                                let location = gesture.location.x
                //                                let percent = min(max(location / width, 0), 1)
                //                                value = Double(percent) *
                //                                (range.upperBound - range.lowerBound) +
                //                                range.lowerBound
                //                            }
                //                    )
                //                    .shadow(color: .shadow, radius: 4)
                
                GradientThumb()
                    .frame(width: 24, height: 24)
                    .offset(x: max(0, min(width - 28, width * progress - 14)))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let location = gesture.location.x
                                let percent = min(max(location / width, 0), 1)
                                value = Double(percent) *
                                (range.upperBound - range.lowerBound) +
                                range.lowerBound
                            }
                    )
                
            }
        }
    }
}

//MARK: - GradientThumb
struct GradientThumb: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.linearGradient3,
                            Color.linearGradient4,
                            Color.blueMain700
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Circle()
                .stroke(Color.white, lineWidth: 2)
        }
        .shadow(color: .shadow, radius: 4, x: 0, y: 2)
    }
}

//MARK: - PlaybackWaveformView

//struct PlaybackWaveformView: View {
//
//    var isPlaying: Bool
//
//    @EnvironmentObject var themeManager: ThemeManager
//
//    var body: some View {
//
//        HStack(alignment: .center, spacing: 4) {
//
//            ForEach(0..<35, id: \.self) { index in
//                WaveBar(
//                    delay: Double(index) * 0.05,
//                    isPlaying: isPlaying
//                )
//            }
//        }
//        .frame(height: 100)
//    }
//}
//
//struct WaveBar: View {
//
//    let delay: Double
//    let isPlaying: Bool
//
//    @State private var height: CGFloat = 12
//
//    @EnvironmentObject var themeManager: ThemeManager
//
//    var body: some View {
//
//        Capsule()
//            .fill(
//                themeManager.gradient(style: .vertical)
//            )
//            .frame(width: 4, height: height)
//            .shadow(
//                color: themeManager.accentLastColor.opacity(0.55),
//                radius: 3,
//                x: 0,
//                y: 0
//            )
//            .onAppear {
//                animateWave()
//            }
//            .onChange(of: isPlaying) { _ in
//                animateWave()
//            }
//    }
//
//    private func animateWave() {
//
//        guard isPlaying else {
//
//            withAnimation(.easeOut(duration: 0.2)) {
//                height = 12
//            }
//
//            return
//        }
//
//        withAnimation(
//            .easeInOut(duration: 0.5)
//            .repeatForever(autoreverses: true)
//            .delay(delay)
//        ) {
//            height = CGFloat.random(in: 14...100)
//        }
//    }
//}

struct PlaybackWaveformView: View {
    
    var isPlaying: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(0..<35, id: \.self) { _ in
                RandomWaveBar(isPlaying: isPlaying)
            }
        }
        .frame(height: 100)
    }
}

struct RandomWaveBar: View {
    
    var isPlaying               : Bool
    @State private var height   : CGFloat = CGFloat.random(in: 14...100)
    @EnvironmentObject var themeManager : ThemeManager
    let timer = Timer.publish(
        every: Double.random(in: 0.25...0.45),
        on: .main,
        in: .common
    ).autoconnect()
    
    var body: some View {
        Capsule()
            .fill(
                themeManager.gradient(style: .vertical)
            )
            .frame(width: 4, height: height)
            .shadow(
                color: themeManager.accentLastColor.opacity(0.55),
                radius: 3,
                x: 0,
                y: 0
            )
            .onReceive(timer) { _ in
                withAnimation(
                    .easeInOut(
                        duration: Double.random(in: 0.35...0.6)
                    )
                ) {
                    height = CGFloat.random(in: 14...100)
                    //                    height = isPlaying
                    //                    ? CGFloat.random(in: 14...100)
                    //                    : 12
                }
            }
            .onAppear {
                guard isPlaying else { return }
                withAnimation(
                    .easeInOut(
                        duration: Double.random(in: 0.35...0.6)
                    )
                ) {
                    height = CGFloat.random(in: 14...100)
                }
            }
    }
}

// MARK: - ValidatingLoaderView
struct ValidatingLoaderView: View {
    @State private var dotScales: [CGFloat] = [0.5, 0.5, 0.5]
    @State private var dotOpacities: [Double] = [0.5, 0.5, 0.5]
    @EnvironmentObject var themeManager : ThemeManager
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(themeManager.accentTextColor)
                        .frame(width: 16, height: 16)
                        .scaleEffect(dotScales[index])
                        .opacity(dotOpacities[index])
                }
            }
            .onAppear {
                animateDots()
            }
            
            VStack(spacing: 8) {
                Text("Validating...")
                    .font(.geistBold(18))
                    .foregroundColor(.textPrimary0E101AF4F1FB)
                
                Text("matching against 500+ providers")
                    .font(.jetBrainsSemiBold(12))
                    .foregroundColor(themeManager.textPrimaryLight6_dark62)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func animateDots() {
        for index in 0..<3 {
            withAnimation(
                .easeInOut(duration: 0.6)
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.2)
            ) {
                dotScales[index] = 1.2
                dotOpacities[index] = 1.0
            }
        }
    }
}
