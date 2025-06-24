//
//  AudioRecorderView.swift
//  Dreams
//
//  Created by Felix Kircher on 24.06.25.
//

import SwiftUI
import AVFoundation
import Speech

// MARK: - Audio Recorder ObservableObject
@MainActor
class AudioRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordingTime: TimeInterval = 0
    @Published var audioURL: URL?
    @Published var soundSamples: [Float] = Array(repeating: 0.1, count: 50)
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var levelTimer: Timer?
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            Task { @MainActor in
                ToastManager.shared.showInfo("Audio-Session konfiguriert")
            }
        } catch {
            Task { @MainActor in
                ToastManager.shared.showError("Audio-Session Fehler", details: error.localizedDescription)
            }
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("recording_\(UUID().uuidString).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            audioURL = audioFilename
            recordingTime = 0
            
            startTimers()
            ToastManager.shared.showSuccess("Aufnahme gestartet")
        } catch {
            ToastManager.shared.showError("Aufnahme-Fehler", details: error.localizedDescription)
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioRecorder?.stop()
        isRecording = false
        stopTimers()
        
        ToastManager.shared.showSuccess("Aufnahme beendet", details: String(format: "%.1f Sekunden aufgenommen", recordingTime))
    }
    
    func startPlayback() {
        guard let url = audioURL, !isPlaying else { return }
        
        // Debug: Check file existence and print details
        let fileExists = FileManager.default.fileExists(atPath: url.path)
        ToastManager.shared.showInfo("Audio Debug", details: "File exists: \(fileExists)\nPath: \(url.path)\nAbsolute: \(url.absoluteString)")
        
        guard fileExists else {
            ToastManager.shared.showError("Audio-Datei nicht gefunden", details: url.path)
            return
        }
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            ToastManager.shared.showSuccess("Wiedergabe gestartet", details: "Dauer: \(audioPlayer?.duration ?? 0)s")
            
            // Check when playback finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + (audioPlayer?.duration ?? 0)) {
                if self.audioPlayer?.isPlaying == false {
                    self.isPlaying = false
                }
            }
        } catch {
            ToastManager.shared.showError("Wiedergabe-Fehler", details: "Error: \(error.localizedDescription)\nURL: \(url.path)")
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
        ToastManager.shared.showInfo("Wiedergabe gestoppt")
    }
    
    func deleteRecording() {
        stopPlayback()
        if let url = audioURL {
            try? FileManager.default.removeItem(at: url)
            ToastManager.shared.showWarning("Aufnahme gelöscht")
        }
        audioURL = nil
        recordingTime = 0
        soundSamples = Array(repeating: 0.1, count: 50)
    }
    
    private func startTimers() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                self.recordingTime += 0.1
            }
        }
        
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in
                self.updateSoundLevel()
            }
        }
    }
    
    private func stopTimers() {
        recordingTimer?.invalidate()
        levelTimer?.invalidate()
        recordingTimer = nil
        levelTimer = nil
    }
    
    private func updateSoundLevel() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        
        recorder.updateMeters()
        let level = recorder.averagePower(forChannel: 0)
        let normalizedLevel = max(0.0, (level + 80) / 80) // Normalize -80 to 0 dB to 0-1
        
        // Update samples array
        soundSamples.removeFirst()
        soundSamples.append(normalizedLevel)
    }
}

// MARK: - Speech Transcriber
class SpeechTranscriber {
    static func transcribe(url: URL, completion: @escaping (String?) -> Void) {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            Task { @MainActor in
                ToastManager.shared.showError("Spracherkennung nicht autorisiert")
            }
            completion(nil)
            return
        }
        
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        
        Task { @MainActor in
            ToastManager.shared.showInfo("Transkription gestartet...")
        }
        
        recognizer?.recognitionTask(with: request) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    Task { @MainActor in
                        ToastManager.shared.showError("Transkriptions-Fehler", details: error.localizedDescription)
                    }
                    completion(nil)
                } else if let result = result, result.isFinal {
                    let transcript = result.bestTranscription.formattedString
                    Task { @MainActor in
                        ToastManager.shared.showSuccess("Transkription erfolgreich", details: "Text: \"\(transcript)\"")
                    }
                    completion(transcript)
                }
            }
        }
    }
    
    static func requestPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                Task { @MainActor in
                    switch status {
                    case .authorized:
                        ToastManager.shared.showSuccess("Spracherkennung autorisiert")
                    case .denied:
                        ToastManager.shared.showError("Spracherkennung verweigert")
                    case .restricted:
                        ToastManager.shared.showWarning("Spracherkennung eingeschränkt")
                    case .notDetermined:
                        ToastManager.shared.showInfo("Spracherkennung noch nicht bestimmt")
                    @unknown default:
                        ToastManager.shared.showWarning("Unbekannter Spracherkennung-Status")
                    }
                }
            }
        }
    }
}

// MARK: - Audio Memo Components
struct AudioMemoRecorderView: View {
    @Binding var audioMemos: [AudioMemo]
    @StateObject private var recorder = AudioRecorder()
    @State private var isTranscribing = false
    @State private var currentTranscript: String?
    
    var body: some View {
        Group {
            // Visual waveform
            HStack(alignment: .center, spacing: 2) {
                ForEach(0..<recorder.soundSamples.count, id: \.self) { index in
                    let sample = recorder.soundSamples[index]
                    let height = max(3, sample * 40)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(recorder.isRecording ? Color.red.opacity(0.8) : Color.blue.opacity(0.6))
                        .frame(width: 3, height: CGFloat(height))
                        .animation(.easeInOut(duration: 0.1), value: sample)
                }
            }
            .frame(height: 50)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Recording controls
            HStack(spacing: 20) {
                Button(action: {
                    if recorder.isRecording {
                        recorder.stopRecording()
                        transcribeCurrentRecording()
                    } else {
                        recorder.startRecording()
                    }
                }) {
                    Image(systemName: recorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(recorder.isRecording ? .red : .blue)
                }
                .buttonStyle(.plain)
                
                if recorder.audioURL != nil {
                    Button(action: {
                        if recorder.isPlaying {
                            recorder.stopPlayback()
                        } else {
                            recorder.startPlayback()
                        }
                    }) {
                        Image(systemName: recorder.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        recorder.deleteRecording()
                        currentTranscript = nil
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Recording time
            if recorder.isRecording {
                Text(String(format: "%.1f Sekunden", recorder.recordingTime))
                    .font(.headline)
                    .foregroundColor(.red)
            }
            
            // Transcription status
            if isTranscribing {
                ProgressView("Transkribiere...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let transcript = currentTranscript {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transkript:")
                        .font(.headline)
                    Text(transcript)
                        .font(.body)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Save button
            if recorder.audioURL != nil {
                Button("Memo speichern") {
                    saveCurrentMemo()
                }
                .buttonStyle(.borderedProminent)
                .disabled(recorder.audioURL == nil)
            }
        }
        .onAppear {
            SpeechTranscriber.requestPermission()
        }
    }
    
    private func transcribeCurrentRecording() {
        guard let url = recorder.audioURL else { return }
        
        isTranscribing = true
        currentTranscript = nil
        
        SpeechTranscriber.transcribe(url: url) { transcript in
            self.currentTranscript = transcript
            self.isTranscribing = false
        }
    }
    
    private func saveCurrentMemo() {
        guard let url = recorder.audioURL else { return }
        
        let memo = AudioMemo(
            url: url,
            transcript: currentTranscript,
            duration: recorder.recordingTime
        )
        
        DispatchQueue.main.async {
            self.audioMemos.append(memo)
            
            Task { @MainActor in
                ToastManager.shared.showSuccess("Audio-Memo gespeichert", details: "Anzahl Memos: \(self.audioMemos.count), Dauer: \(String(format: "%.1f", memo.duration))s")
            }
            
            // Reset recorder
            self.recorder.audioURL = nil
            self.recorder.recordingTime = 0
            self.currentTranscript = nil
            self.recorder.soundSamples = Array(repeating: 0.1, count: 50)
        }
    }
}

struct AudioMemoCard: View {
    let memo: AudioMemo
    let onDelete: () -> Void
    @StateObject private var player = AudioRecorder()
    @State private var isTranscriptExpanded = false
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                if player.isPlaying {
                    player.stopPlayback()
                } else {
                    player.audioURL = memo.url
                    player.startPlayback()
                }
            }) {
                Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "waveform")
                        .foregroundColor(.purple)
                    Text(memo.createdAt, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1fs", memo.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let transcript = memo.transcript, !transcript.isEmpty {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            isTranscriptExpanded.toggle()
                        }
                    }) {
                        Text(transcript)
                            .font(.callout)
                            .lineLimit(isTranscriptExpanded ? nil : 3)
                            .multilineTextAlignment(.leading)
                            .padding(6)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
    }
}