//
//  AudioManager.swift
//  Subzillo
//
//  Created by KSMACMINI-019 on 18/09/25.
//

import SwiftUI
import AVFoundation

class AudioRecorderManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    //MARK: - Properties
    @Published var isRecording          = false
    @Published var isPlaying            = false
    @Published var currentTime          : TimeInterval = 0
    @Published var duration             : TimeInterval = 0
    @Published var hasRecording         : Bool = false
    @Published var requiredPermission   = false
    
    var audioRecorder                   : AVAudioRecorder!
    var audioPlayer                     : AVAudioPlayer?
    var timer                           : Timer?
    
    var audioURL                = FileManager.default.temporaryDirectory.appendingPathComponent("recording.m4a")
    var audioData               = Data()
    
    @Published var recordTime   : TimeInterval = 0
    let maxRecordDuration       : TimeInterval = 120 // 2 minutes
    var recordTimer             : Timer?
    
    var pausedTime              : TimeInterval = 0
    var isPaused                : Bool = false
    
    func startRecording() {
        self.requiredPermission = false
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            guard let self = self else { return }
            if granted {
                DispatchQueue.main.async { self.beginRecording() }
            } else {
                DispatchQueue.main.async {
                    self.requiredPermission = true
                }
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
            guard audioRecorder?.record() == true else {
                print("❌ Failed to start recording — audio file invalid")
                isRecording = false
                return
            }
            audioRecorder?.record()
            isRecording = true
            startRecordTimer()
            print("🎙 Recording started")
        } catch {
            print("⚠️ Failed to start recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        stopRecordTimer()
//        recordTime = 0
        hasRecording = FileManager.default.fileExists(atPath: audioURL.path)
        // Update duration for UI
        //        let asset = AVURLAsset(url: audioURL)
        //        getAudioDuration(from: audioURL) { duration in
        //            if let duration = duration {
        //                DispatchQueue.main.async{
        //                    self.duration = duration
        //                }
        //            } else {
        //                print("❌ Could not get audio duration")
        //            }
        //        }
        currentTime = 0
        print("🛑 Recording stopped")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.loadDurationSafely()
        }
    }
    
    private func loadDurationSafely() {
        getAudioDuration(from: audioURL) { duration in
            guard let duration = duration else {
                print("❌ Could not get audio duration (file not finalized)")
                return
            }
            DispatchQueue.main.async { self.duration = duration }
        }
    }
    
    private func startRecordTimer() {
        guard audioRecorder != nil else { return }
        recordTime = 0
        recordTimer?.invalidate()
        recordTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if !self.isRecording {
                timer.invalidate()
                return
            }
            self.recordTime += 1
            if self.recordTime >= self.maxRecordDuration {
                timer.invalidate()
                self.stopRecording()
                ToastManager.shared.showToast(message: "You can't record more then 2mins",style:ToastStyle.error)
            }
        }
    }
    
    private func stopRecordTimer() {
        recordTimer?.invalidate()
        recordTimer = nil
    }
    
    // MARK: Playback
    //    func playRecording() {
    //        guard FileManager.default.fileExists(atPath: audioURL.path) else { return }
    //        do {
    //            if audioPlayer == nil {
    //                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
    //                audioPlayer?.delegate = self
    //                audioPlayer?.prepareToPlay()
    //                duration = audioPlayer?.duration ?? 0
    //            }
    //            if isPaused {
    //                audioPlayer?.currentTime = pausedTime
    //                isPaused = false
    //            }
    //            audioPlayer?.play()
    //            isPlaying = true
    //            startTimer()
    //        } catch {
    //            print("⚠️ Failed to play recording: \(error.localizedDescription)")
    //        }
    //    }
    
    func playRecording() {
        guard FileManager.default.fileExists(atPath: audioURL.path) else { return }
        do {
            if audioPlayer == nil {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.delegate = self
                audioPlayer?.prepareToPlay()
                duration = audioPlayer?.duration ?? 0
            }
            if isPaused {
                isPaused = false
            }
            audioPlayer?.play()
            isPlaying = true
            startTimer()
        } catch {
            print("⚠️ Failed to play recording: \(error.localizedDescription)")
        }
    }
    
    func pausePlayback() {
        guard let player = audioPlayer else { return }
        pausedTime = player.currentTime
        isPaused = true
        player.pause()
        isPlaying = false
        stopTimer()
    }
    
    func stopPlayback() {
        if audioPlayer?.isPlaying == true{
            audioPlayer?.stop()
        }
        audioPlayer = nil
        pausedTime  = 0
        isPaused    = false
        currentTime = 0
        isPlaying   = false
        stopTimer()
    }
    
    func load(url: URL) {
        audioURL = url
        preparePlayer()   // create AVAudioPlayer (but do not start)
    }
    
    private func preparePlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            duration = audioPlayer?.duration ?? 0
        } catch {
            print("Failed to prepare player: \(error)")
        }
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
            hasRecording = false
        } catch {
            print("⚠️ Failed to delete recording: \(error.localizedDescription)")
        }
    }
    
    func discardAll() {
        stopPlayback()
        deleteRecordingFile()
        pausedTime = 0
        isPaused = false
        recordTime = 0
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

