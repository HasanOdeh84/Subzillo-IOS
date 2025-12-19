//
//  VoiceCommandView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 18/09/25.
//
import SwiftUI
import Vision
import Speech
import AVFoundation

struct VoiceCommandView: View {
    
    //MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject var voiceCommandVM         = VoiceCommandViewModel()
    @State private var showPermissionAlert  = false
    @State var showDiscardPopup             : Bool = false
    @StateObject private var audioManager   = AudioRecorderManager()
    @State private var isPlaying            = false
    
    //Missing details
//    @State var missingDetailsList           : [MissingDetails] = []
    @State var showMissingDetailsPopup      : Bool = false

    //MARK: - body
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            
            // MARK: - Header
            HStack(spacing: 8) {
                // MARK: - back
                Button(action: goBack) {
                    HStack {
                        Image("back_gray")
                    }
                    .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // MARK: - Title
                    Text("Add by Voice")
                        .font(.appRegular(24))
                        .foregroundColor(Color.neutralMain700)
                        .padding(.top, 20)
                    
                    // MARK: - SubTitle
                    Text("Add your subscriptions using simple voice commands")
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutral500)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 0)
            
            ScrollView {
                
                // MARK: - How It Works
                GradienCustomeView(title    : "How it work?",
                                   subTitle : "Tap the button below to start recording your subscription details, submit when you finish.")
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
                
                // MARK: - Start Button
                
                //             Show player only if recording exists
                if audioManager.hasRecording && !audioManager.isRecording{
                    VStack{
                        
                        // Optional: slider for seeking
                        //                                                Slider(value: Binding(
                        //                                                    get: { audioManager.currentTime },
                        //                                                    set: { newValue in
                        //                                                        audioManager.audioPlayer?.currentTime = newValue
                        //                                                        audioManager.currentTime = newValue
                        //                                                    }
                        //                                                ), in: 0...audioManager.duration)
                        //                                                .tint(Color.navyBlueCTA700)
                        
                        LottieViewPlayPause(name: "soundWave",isAspectFit: false, play: $isPlaying)
                            .frame(height: 176)
                            .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .trailing) {
                            
                            // Your custom slider
                            GradientThumbSlider(
                                value: Binding(
                                    get: { audioManager.currentTime },
                                    set: { newValue in
                                        audioManager.audioPlayer?.currentTime = newValue
                                        audioManager.currentTime = newValue
                                    }
                                ),
                                range: 0...audioManager.duration,
                                thumbImage: "sliderThumb"
                            )
                            .frame(height: 40)
                            
                            // Playback progress
                            Text("\(formatTime(Int(audioManager.currentTime))) / \(formatTime(Int(audioManager.duration)))")
                                .font(.appRegular(14))
                                .foregroundStyle(Color.whiteBlackBGnoPic)
                                .frame(alignment: .trailing)
                                .padding(.top, -22)
                        }
                        
                        // Play/Pause button
                        Button(action: {
                            isPlaying.toggle()
                            if audioManager.isPlaying {
                                audioManager.pausePlayback()
                            } else {
                                audioManager.playRecording()
                            }
                        }) {
                            Image(audioManager.isPlaying ? "Pause" : "Play")
                                .frame(width: 72,height: 72)
                                .frame(alignment: .center)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }else{
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [Color.linearGradient3,
                                                        Color.linearGradient4,
                                                        Color.navyBlueCTA700],
                                               startPoint: .top,
                                               endPoint: .bottom)
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(audioManager.isRecording ? "Recording" : "mic-01")
                            .font(.system(size: 63))
                            .foregroundColor(.white)
                    }
                    .frame(width: 137, height: 137)
                    .background(
                        RoundedRectangle(cornerRadius: 137/2)
                            .fill(Color.white)
                    )
                    .cornerRadius(137/2)
                    .shadow(color: Color.dropShadow, radius: 2, x: 0, y: 2)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onTapGesture {
                        if !audioManager.isRecording{
                            audioManager.startRecording()
                        } //audioManager.isRecording ? audioManager.stopRecording() : audioManager.startRecording()
                    }
                }
                
                if !audioManager.hasRecording || audioManager.isRecording {
                    Text("\(formatTime(Int(audioManager.recordTime)))")
                        .font(.appSemiBold(28))
                        .foregroundColor(Color.navyBlueCTA700)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                }
                
                if audioManager.hasRecording && !audioManager.isRecording{
                    CustomButton(
                        title       : "Submit",
                        background  : .navyBlueCTA700,
                        textColor   : .neutralDisabled200White,
                        action      : submitAction
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }else{
                    CustomButton(
                        title       : "Stop",
                        //                        background  : audioManager.isRecording ? .systemError : Color.neutralDisabled200,
                        //                        textColor   : audioManager.isRecording ? .disCardRed : Color.neutral500,
                        background  : .systemError,
                        textColor   : .disCardRed,
                        action      : stopBtn
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                Color("redColor"),
                                lineWidth: 1
                            )
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .opacity(!audioManager.isRecording ? 0.5 : 1.0)
                    .disabled(!audioManager.isRecording)
                }
                
                // MARK: - Reset Button
                GradientBorderButton(title: "Discard",isBtn:true, buttonImage: "discardIcon", action:{
                    audioManager.pausePlayback()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showDiscardPopup = true
                    }
                })
                .opacity(audioManager.hasRecording && !audioManager.isRecording ? 1.0 : 0.5)
                .disabled(audioManager.hasRecording && !audioManager.isRecording ? false : true)
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .padding(.top, 10)
        .background(Color.neutralBg100)
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
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(350)])
        }
        .sheet(isPresented: $voiceCommandVM.showMissingDetailsBottomSheet, onDismiss: {
        }) {
            VoiceMissingDetailsSheet(missingDetailsList : voiceCommandVM.missingDetailsList,
                                     onSubmit           : {
                submitAction()
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
        dismiss()
    }
    
    //MARK: - Submit action
    private func submitAction() {
        audioManager.pausePlayback()
        let voiceData:Data = try! Data(contentsOf: audioManager.audioURL)
        voiceCommandVM.voiceSubscription(input: VoiceSubscriptionRequest(userId: Constants.getUserId()), fileData: [MultiPartFileInput(
            fieldName   : "audio",
            fileName    : "recording.m4a",
            mimeType    : "audio/x-m4a",
            fileData    : voiceData
        )], audioUrl: audioManager.audioURL)
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
    VoiceCommandView()
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

