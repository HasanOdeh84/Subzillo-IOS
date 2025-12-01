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
    @StateObject private var viewModel      = VoiceCommandViewModel()
    @State private var permissionType       = ""
    @State private var previousText         = ""
    @State private var recognizedText       = ""//"Hello, i have taken Netflix premium auto renuwal subscription for quarterly using my moms debit card and i have paid 12.99 USD on 1st November 2025 also i have taken another subscription for monthly using my dads credit card and i have paid 11.99"
    @State private var isRecording          = false
    @State private var countdown            = 0
    @StateObject var voiceCommandVM         = VoiceCommandViewModel()
    @State private var showPermissionAlert  = false
    @State private var speechRecognizer     = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var recognitionRequest   : SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask      : SFSpeechRecognitionTask?
    @State private var audioEngine          = AVAudioEngine()
    @State private var timer                : Timer?
    @State var showDiscardPopup             : Bool = false
    //    @GestureState private var isPressing    = false
    @GestureState private var longPressActivated = false
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPressing = false
    @State private var hasPerformedAction = false
    
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
                // MARK: - Transcript TextBox
                /*
                 VStack(alignment: .leading) {
                 if recognizedText.isEmpty {
                 Text("Transcript will be appeared here")
                 .foregroundColor(Color.neutral400)
                 .frame(maxWidth: .infinity, alignment: .leading)
                 .padding(16)
                 } else {
                 ScrollView(showsIndicators: false) {
                 Text(recognizedText)
                 .foregroundColor(Color.neutralMain700)
                 .frame(maxWidth: .infinity, alignment: .leading)
                 .padding(16)
                 }
                 }
                 Spacer(minLength: 0)
                 }
                 .frame(height: 115)
                 .frame(maxWidth: .infinity)
                 .font(.appRegular(16))
                 .overlay(
                 RoundedRectangle(cornerRadius: 12)
                 .stroke(Color.neutral300Border, lineWidth: 1)
                 )
                 .background(Color.whiteNeutralCardBG)
                 .cornerRadius(12)
                 .padding(.horizontal, 20)
                 .padding(.top, 24)
                 */
                
                // MARK: - How It Works
                GradienCustomeView(title    : "How it work?",
                                   subTitle : "Tap the button below to start recording your subscription details, submit when you finish.")
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)
                
                // MARK: - Start Button
                
                //             Show player only if recording exists
                if FileManager.default.fileExists(atPath: audioManager.audioURL.path()) && !audioManager.isRecording{
                    
                    // Play/Pause button
                    Button(action: {
                        if !audioManager.isRecording{
                            if audioManager.isPlaying {
                                audioManager.pausePlayback()
                            } else {
                                audioManager.playRecording()
                            }
                        }
                    }) {
                        Text(audioManager.isPlaying ? "Pause" : "Play")
                            .padding()
                            .background(audioManager.isPlaying ? Color.orange : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    VStack(alignment: .leading,spacing: 15) {
                        
                        // Optional: slider for seeking
                        Slider(value: Binding(
                            get: { audioManager.currentTime },
                            set: { newValue in
                                audioManager.audioPlayer?.currentTime = newValue
                                audioManager.currentTime = newValue
                            }
                        ), in: 0...audioManager.duration)
                        
                        // Playback progress
                        Text("\(formatTime(Int(audioManager.currentTime))) / \(formatTime(Int(audioManager.duration)))")
                            .font(.subheadline)
                        
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
//                    Button(action: {
//                        let voiceData:Data = try! Data(contentsOf: audioManager.audioURL)
//                        viewModel.voiceSubscription(input: VoiceSubscriptionRequest(userId: Constants.getUserId()), fileData: [MultiPartFileInput(
//                            fieldName   : "audio",
//                            fileName    : "recording.m4a",
//                            mimeType    : "audio/m4a",
//                            fileData    : voiceData
//                        )])
//                    }) {
//                        Text("Submit")
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
                }else{
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.navyBlueCTA700],
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
                    //                .simultaneousGesture(
                    //                    DragGesture(minimumDistance: 0)
                    //                        .onChanged { _ in startListening() }
                    //                        .onEnded { _ in stopListening() }
                    //                )
                    //                .gesture(
                    //                    LongPressGesture(minimumDuration: 0.4)
                    //                        .sequenced(before: DragGesture(minimumDistance: 0))
                    //                        .onChanged { value in
                    //                            switch value {
                    //                            case .first(true):       // long press recognised
                    //                                startListening()
                    //                            default:
                    //                                break
                    //                            }
                    //                        }
                    //                        .onEnded { value in
                    //                            stopListening()
                    //                        }
                    //                )
                    //                .gesture(longPressThenTrackDrag)
                    .onTapGesture {
                        if audioManager.isRecording {
                            audioManager.stopRecording()
                        } else {
                            audioManager.startRecording()
                        }
                    }
                }
                
                // MARK: - Countdown Label
                VStack(spacing: 0) {
                    Text("\(formatTime(countdown))")
                        .font(.appSemiBold(28))
                        .foregroundColor(Color.navyBlueCTA700)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                }
                
                // MARK: - Submit Button
//                if recognizedText.isEmpty {
                if FileManager.default.fileExists(atPath: audioManager.audioURL.path()) && !audioManager.isRecording {
                    CustomButton(title: "Submit", background:Color.neutralDisabled200, textColor:Color.neutral500, action: submitAction)
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                }
                else{
                    CustomButton(title: "Submit", action: submitAction)
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                }
                
                // MARK: - Reset Button
                GradientBorderButton(title: "Discard",isBtn:true, buttonImage: "discardIcon", action:{
                    showDiscardPopup = true})
                .opacity(countdown == 0 ? 0.5 : 1.0)
                .disabled(countdown == 0 ? true : false)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .padding(.top, 10)
        .background(Color.neutralBg100)
        .onAppear {
            print(countdown)
            requestSpeechPermission()
            audioManager.deleteRecordingFile()
        }
        .animation(.easeInOut, value: isRecording)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $voiceCommandVM.showErrorPopup) {
            InfoVoiceAlertSheet(
                onDelegate: {
                    voiceCommandVM.showErrorPopup = false
                    self.resetAll()
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
            if permissionType == "Speech Recognition"
            {
                PermissionSheet(onDelegate: {
                    //dismiss()
                }, title: "We need speech recognition access to add subscriptions by voice", type: "voice", value: "Tap Speech Recognition")
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(580)])
            }
            else{
                PermissionSheet(onDelegate: {
                    //dismiss()
                }, title: "We need microphone access to add subscriptions by voice", type: "voice", value: "Tap Microphone")
                .presentationDragIndicator(.hidden)
                .presentationDetents([.height(580)])
            }
        }
        .sheet(isPresented: $showDiscardPopup) {
            InfoAlertSheet(
                onDelegate: {
                    resetAll()
                }, title    : "Are you sure you want to discard the recording?",
                subTitle    : "",
                imageName   : "infoIcon",
                buttonIcon  : "deleteIcon",
                buttonTitle : "Discard"
            )
            .presentationDragIndicator(.hidden)
            .presentationDetents([.height(350)])
        }
        .modifier(LoaderModifier())
        .onReceive(NotificationCenter.default.publisher(for: .closeAllBottomSheets)) { _ in
            voiceCommandVM.showErrorPopup = false
            showPermissionAlert = false
            showDiscardPopup = false
        }
    }
    
    // Combined gestures: long press starts, simultaneous drag detects lift
    private var longPressThenTrackDrag: some Gesture {
        let longPress = LongPressGesture(minimumDuration: 0.35)
            .updating($longPressActivated) { current, state, _ in
                // called when the long-press requirement is satisfied (finger still down)
                if current && !state {
                    state = true
                }
            }
            .onEnded { _ in
                // onEnded of LongPressGesture fires when the long-press succeeded,
                // but we don't stop here — stop will be handled by the drag's onEnded.
                // We use this to set isRecording if not already set (defensive).
                startListening()
            }
        
        // This DragGesture runs simultaneously and its onEnded fires when finger lifts.
        let drag = DragGesture(minimumDistance: 0)
            .onChanged { _ in
                // nothing needed here — movement while holding should not stop recording
            }
            .onEnded { _ in
                // finger lifted — stop only if we were recording
                stopListening()
            }
        
        // Important: use simultaneous so drag doesn't cancel the long-press
        return longPress.simultaneously(with: drag)
    }
    
    private func clickOnHowItWorks() {
    }
    
    //MARK: - Back action
    private func goBack() {
        dismiss()
    }
    
    //MARK: - Submit action
    private func submitAction() {
        if recognizedText.isEmpty {
        }
        else{
            stopListening()
            let input = VoiceSubscriptionRequest(userId: Constants.getUserId(), text: recognizedText)
            voiceCommandVM.voiceSubscription(input: input)
        }
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
    
    // MARK: - Permissions
    private func requestSpeechPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { micGranted in
            
            guard micGranted else {
                return
            }
            
        }
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Speech recognition authorized")
            default:
                print("Speech recognition permission denied")
            }
        }
    }
    
    private func requestSpeechAndMicPermissions(completion: @escaping (Bool) -> Void) {
        // Check microphone permission first
        AVAudioSession.sharedInstance().requestRecordPermission { micGranted in
            guard micGranted else {
                DispatchQueue.main.async {
                    self.permissionType = "Microphone"
                    //ToastManager.shared.showToast(message: "Microphone access is denied. Enable it in Settings.", style: .error)
                    self.showPermissionAlert = true
                }
                completion(false)
                return
            }
            
            // Then check speech recognition permission
            SFSpeechRecognizer.requestAuthorization { authStatus in
                DispatchQueue.main.async {
                    switch authStatus {
                    case .authorized:
                        completion(true)
                    case .denied:
                        self.permissionType = "Speech Recognition"
                        // ToastManager.shared.showToast(message: "Speech Recognition access is denied. Enable it in Settings.", style: .error)
                        self.showPermissionAlert = true
                        completion(false)
                    case .restricted, .notDetermined:
                        self.permissionType = "Speech Recognition"
                        //ToastManager.shared.showToast(message: "Speech Recognition is not available or permission not granted.", style: .error)
                        self.showPermissionAlert = true
                        completion(false)
                    @unknown default:
                        completion(false)
                    }
                }
            }
        }
    }
    
    // MARK: - Start Listening
    private func startListening()
    {
        requestSpeechAndMicPermissions { granted in
            guard granted else { return }
            if countdown > 119
            {
                ToastManager.shared.showToast(message: "You can't record more then 2mins",style:ToastStyle.error)
                return
            }
            guard !isRecording else { return }
            isRecording = true
            // recognizedText = ""
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } catch {
                print("Audio session setup failed: \(error)")
            }
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            let inputNode = audioEngine.inputNode
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    if self.timer != nil {
                        let newSegment = result.bestTranscription.formattedString
                        recognizedText = [self.previousText, newSegment]
                            .filter { !$0.isEmpty }
                            .joined(separator: " ")
                    }
                }
                if error != nil {
                    self.stopListening()
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
                buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch {
                print("AudioEngine start failed: \(error)")
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                countdown += 1
                if countdown > 119
                {
                    stopListening()
                    ToastManager.shared.showToast(message: "You can't record more then 2mins",style:ToastStyle.error)
                }
            }
        }
    }
    
    // MARK: - Stop Listening
    private func stopListening() {
        guard isRecording else { return }
        isRecording = false
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        
        timer?.invalidate()
        timer = nil
        
        previousText = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error deactivating session: \(error)")
        }
    }
    
    private func resetAll() {
        stopListening()
        recognizedText = ""
        previousText = ""
        countdown = 0
    }
}
#Preview {
    VoiceCommandView()
}
