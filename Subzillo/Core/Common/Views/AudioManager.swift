//
//  AudioManager.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 18/09/25.
//

import SwiftUI
import AVFoundation

class AudioRecorderManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?

    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    var audioURL = FileManager.default.temporaryDirectory.appendingPathComponent("recording.m4a")
    var audioData = Data()

    func startRecording() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            guard let self = self else { return }
            if granted {
                DispatchQueue.main.async { self.beginRecording() }
            } else {
                print("❌ Microphone access denied")
            }
        }
    }

    private func beginRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default,options: [.defaultToSpeaker])
            try session.setActive(true)

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.record()

            isRecording = true
            print("🎙 Recording started")
        } catch {
            print("⚠️ Failed to start recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false

        // Update duration for UI
        let asset = AVURLAsset(url: audioURL)
        getAudioDuration(from: audioURL) { duration in
            if let duration = duration {
                DispatchQueue.main.async{
                    self.duration = duration
                }
            } else {
                print("❌ Could not get audio duration")
            }
        }
        currentTime = 0

        print("🛑 Recording stopped")
    }

    // MARK: Playback
    func playRecording() {
        guard FileManager.default.fileExists(atPath: audioURL.path) else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            duration = audioPlayer?.duration ?? 0

            startTimer()
        } catch {
            print("⚠️ Failed to play recording: \(error.localizedDescription)")
        }
    }

    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }

    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        currentTime = 0
        stopTimer()
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentTime = 0
        stopTimer()
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.currentTime = self.audioPlayer?.currentTime ?? 0
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func deleteRecordingFile() {
        do {
            if FileManager.default.fileExists(atPath: audioURL.path) {
                try FileManager.default.removeItem(at: audioURL)
                print("🗑 Old recording deleted")
            }
            currentTime = 0
            duration = 0
            isPlaying = false
        } catch {
            print("⚠️ Failed to delete recording: \(error.localizedDescription)")
        }
    }
    
    func clearAll() {
        if isRecording {
            audioRecorder?.stop()
        }
        if isPlaying {
            audioPlayer?.stop()
        }

        audioRecorder = nil
        audioPlayer = nil
        isRecording = false
        isPlaying = false
        currentTime = 0
        duration = 0
        stopTimer()

        print("🧹 Audio manager cleared")
    }
    
    func getAudioDuration(from url: URL, completion: @escaping (Double?) -> Void) {
        let asset = AVURLAsset(url: url)
        
        Task {
            do {
                let duration = try await asset.load(.duration)   // async load
                completion(duration.seconds)
            } catch {
                print("⚠️ Failed to load duration: \(error)")
                completion(nil)
            }
        }
    }
}
