//
//  VoiceCommandView.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 18/09/25.
//

import SwiftUI

struct VoiceCommandView: View {
    @StateObject private var audioManager   = AudioRecorderManager()
    @StateObject private var viewModel      = VoiceCommandViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            
            // Record button
            Button(action: {
                if audioManager.isRecording {
                    audioManager.stopRecording()
                } else {
                    audioManager.startRecording()
                }
            }) {
                Text(audioManager.isRecording ? "Stop Recording" : "Start Recording")
                    .padding()
                    .background(audioManager.isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
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
                    Text("\(formatTime(audioManager.currentTime)) / \(formatTime(audioManager.duration))")
                        .font(.subheadline)
                    
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                Button(action: {
                    let voiceData:Data = try! Data(contentsOf: audioManager.audioURL)
                    viewModel.voiceSubscription(input: VoiceSubscriptionRequest(userId: Constants.getUserId()), fileData: [MultiPartFileInput(
                        fieldName   : "audio",
                        fileName    : "recording.m4a",
                        mimeType    : "audio/m4a",
                        fileData    : voiceData
                    )])
                }) {
                    Text("Submit")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .onAppear {
            audioManager.deleteRecordingFile()
        }
    }
}

#Preview {
    VoiceCommandView()
}
