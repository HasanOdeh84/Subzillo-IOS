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
    @StateObject private var audioManager   = AudioRecorderManager()
    @StateObject private var viewModel      = VoiceCommandViewModel()
    
    @State private var previousText = ""
    @State private var recognizedText = ""
    @State private var isRecording = false
    @State private var countdown = 0
    
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var timer: Timer?
    
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            
            // MARK: - Header
            HStack(spacing: 0) {
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
                    Text("in Ut laoreet porta at, nec facilisi")
                        .font(.appRegular(18))
                        .foregroundColor(Color.neutral500)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 0)
            
            ScrollView {
                // MARK: - Transcript TextBox
                VStack(alignment: .leading) {
                    if recognizedText.isEmpty {
                        Text("Transcript will be appeared here")
                            .foregroundColor(Color.neutral400)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                    } else {
                        Text(recognizedText)
                            .foregroundColor(Color.neutralMain700)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                    }
                    Spacer(minLength: 0)
                }
                .frame(height: 115)
                .frame(maxWidth: .infinity)
                .font(.appRegular(16))
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neutral300Border, lineWidth: 1)
                )
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                
                // MARK: - How It Works
                GradienCustomeView(title: "How it work?", subTitle: "Press & Hold to Speak, remove finger to pause, submit when you finish.", action: clickOnHowItWorks, isBtn: false)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                
                // MARK: - Start Button
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: [Color.linearGradient3, Color.linearGradient4, Color.navyBlueCTA700],
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(isRecording ? "Recording" : "mic-01")
                        .font(.system(size: 63))
                        .foregroundColor(.white)
                }
                .frame(width: 137, height: 137)
                .background(
                    RoundedRectangle(cornerRadius: 137/2)
                        .fill(Color.white)
                )
                .cornerRadius(137/2)
                .shadow(color: Color.dropShadowColor, radius: 2, x: 0, y: 2)
                .frame(maxWidth: .infinity, alignment: .center)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in startListening() }
                        .onEnded { _ in stopListening() }
                )
                
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
                if recognizedText.isEmpty {
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
                GradientBorderButton(title: "Discard",isBtn:true, buttonImage: "cancel", action:resetAll)
                    .padding(.horizontal)
                
                Spacer()
            }
        }
        .padding(.top, 10)
        .background(Color.neutralBg100)
        .onAppear {
            requestSpeechPermission()
        }
        .animation(.easeInOut, value: isRecording)
    }
    
    private func clickOnHowItWorks() {
    }
    
    //MARK: - Back action
    private func goBack() {
    }
    
    //MARK: - Submit action
    private func submitAction() {
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
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Speech recognition authorized")
            default:
                print("Speech recognition permission denied")
            }
        }
    }
    
    // MARK: - Start Listening
    private func startListening() {
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
