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
                    HStack(spacing: 5){
                        // Play/Pause button
                        Button(action: {
                            if audioManager.isPlaying {
                                audioManager.pausePlayback()
                            } else {
                                audioManager.playRecording()
                            }
                        }) {
                            Image(audioManager.isPlaying ? "Pause" : "Play")
                                .frame(width: 40,height: 40)
                        }
                        // Optional: slider for seeking
                        Slider(value: Binding(
                            get: { audioManager.currentTime },
                            set: { newValue in
                                audioManager.audioPlayer?.currentTime = newValue
                                audioManager.currentTime = newValue
                            }
                        ), in: 0...audioManager.duration)
                        .tint(Color.navyBlueCTA700)
                        
                        // Playback progress
                        Text("\(formatTime(Int(audioManager.currentTime))) / \(formatTime(Int(audioManager.duration)))")
                            .font(.appRegular(14))
                            .foregroundStyle(Color.whiteBlackBGnoPic)
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
                        audioManager.isRecording ? audioManager.stopRecording() : audioManager.startRecording()
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
             
                CustomButton(
                    title       : "Submit",
                    background  : audioManager.hasRecording ? .navyBlueCTA700 : Color.neutralDisabled200,
                    textColor   : audioManager.hasRecording ? .neutralDisabled200White : Color.neutral500,
                    action      : submitAction
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .disabled(!audioManager.hasRecording)
                
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
