//
//  AudioRecorderView.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//

import SwiftUI
import AVFoundation

class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var audioURL: URL?
    @Published var recordingTime: TimeInterval = 0
    @Published var soundSamples: [Float] = []
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var meterTimer: Timer?
    
    override init() {
        super.init()
        requestMicrophonePermission()
    }
    
    func requestMicrophonePermission() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission(completionHandler: { granted in
                DispatchQueue.main.async {
                    if !granted {
                        print("Mikrofonzugriff nicht erlaubt")
                    }
                }
            })
        } else {
            // Fallback für ältere iOS-Versionen
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if !granted {
                        print("Mikrofonzugriff nicht erlaubt")
                    }
                }
            }
        }
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            audioURL = audioFilename
            isRecording = true
            recordingTime = 0
            soundSamples = []
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.recordingTime += 1
            }
            
            meterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let recorder = self.audioRecorder else { return }
                recorder.updateMeters()
                self.soundSamples.append(self.normalizeSoundLevel(recorder.averagePower(forChannel: 0)))
                // Begrenze die Anzahl der Samples für die Anzeige
                if self.soundSamples.count > 50 {
                    self.soundSamples.removeFirst()
                }
            }
        } catch {
            print("Aufnahme konnte nicht gestartet werden: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        timer?.invalidate()
        meterTimer?.invalidate()
    }
    
    func startPlayback() {
        guard let url = audioURL else { return }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Wiedergabe konnte nicht gestartet werden: \(error.localizedDescription)")
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        isPlaying = false
    }
    
    func deleteRecording() {
        if let url = audioURL {
            do {
                try FileManager.default.removeItem(at: url)
                audioURL = nil
                soundSamples = []
                recordingTime = 0
            } catch {
                print("Fehler beim Löschen der Aufnahme: \(error.localizedDescription)")
            }
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopRecording()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
    
    private func normalizeSoundLevel(_ power: Float) -> Float {
        // Konvertiere dB zu einem normalisierten Wert zwischen 0 und 1
        let minDb: Float = -60
        if power < minDb {
            return 0
        } else if power >= 0 {
            return 1
        } else {
            return (power - minDb) / abs(minDb)
        }
    }
}

struct AudioRecorderView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @Binding var audioURL: URL?
    
    // Hilfsfunktion für die Waveform-Visualisierung
    @ViewBuilder
    private func waveformContent() -> some View {
        HStack(alignment: .center, spacing: 2) {
            if !audioRecorder.soundSamples.isEmpty {
                sampleVisualization()
            } else if audioURL != nil {
                baselineVisualization()
            }
        }
        .frame(height: 50)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    // Visualisierung der aufgenommenen Samples
    @ViewBuilder
    private func sampleVisualization() -> some View {
        ForEach(0..<audioRecorder.soundSamples.count, id: \.self) { index in
            let sample = audioRecorder.soundSamples[index]
            let height = max(3, sample * 50)
            
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.blue.opacity(0.8))
                .frame(width: 3, height: CGFloat(height))
        }
    }
    
    // Basislinie für vorhandene Aufnahmen ohne Samples
    @ViewBuilder
    private func baselineVisualization() -> some View {
        ForEach(0..<20, id: \.self) { _ in
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.blue.opacity(0.5))
                .frame(width: 3, height: 10)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Waveform-Visualisierung
            waveformContent()
            
            // Steuerelemente
            HStack(spacing: 20) {
                // Aufnahme-Button
                Button(action: {
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                    } else {
                        audioRecorder.startRecording()
                    }
                }) {
                    Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(audioRecorder.isRecording ? .red : .blue)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if audioRecorder.isRecording {
                                audioRecorder.stopRecording()
                            } else {
                                audioRecorder.startRecording()
                            }
                        }
                }
                
                // Wiedergabe-Button (nur anzeigen, wenn eine Aufnahme vorhanden ist)
                if audioRecorder.audioURL != nil || audioURL != nil {
                    Button(action: {
                        if audioRecorder.isPlaying {
                            audioRecorder.stopPlayback()
                        } else {
                            audioRecorder.startPlayback()
                        }
                    }) {
                        Image(systemName: audioRecorder.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if audioRecorder.isPlaying {
                                    audioRecorder.stopPlayback()
                                } else {
                                    audioRecorder.startPlayback()
                                }
                            }
                    }
                    
                    // Löschen-Button
                    Button(action: {
                        audioRecorder.deleteRecording()
                        audioURL = nil
                    }) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.red)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                audioRecorder.deleteRecording()
                                audioURL = nil
                            }
                    }
                }
            }
            
            // Aufnahmezeit anzeigen
            if audioRecorder.isRecording {
                Text("\(Int(audioRecorder.recordingTime)) Sekunden")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .onChange(of: audioRecorder.audioURL) { oldValue, newValue in
            audioURL = newValue
        }
        .onAppear {
            if let existingURL = audioURL {
                audioRecorder.audioURL = existingURL
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var url: URL? = nil
        
        var body: some View {
            AudioRecorderView(audioURL: $url)
        }
    }
    
    return PreviewWrapper()
}
