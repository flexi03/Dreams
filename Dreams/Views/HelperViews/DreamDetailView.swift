//
//  DreamDetailView.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//

import SwiftUI
import AVFoundation
import NaturalLanguage

struct DreamDetailView: View {
    @EnvironmentObject private var store: DreamStoreSampleData
    @State private var showEdit = false
    @State private var editableDream: DreamEntry
    @State private var currentlyPlayingAudio: AudioMemo?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var playbackProgress: Double = 0
    @State private var playbackTimer: Timer?
    @State private var cachedKeywords: [String] = []
    @State private var cachedMoodAnalysis: String = ""
    let dream: DreamEntry
    
    init(dream: DreamEntry) {
        self.dream = dream
        self._editableDream = State(initialValue: dream)
        self._cachedKeywords = State(initialValue: [])
        self._cachedMoodAnalysis = State(initialValue: "")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                VStack(spacing: 16) {
                    HStack {
                        Text(dream.mood.rawValue)
                            .font(.system(size: 60))
                        
                        Spacer()
                        
                        Button {
                            showEdit = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dream.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                            Text(dream.date.formatted(date: .complete, time: .omitted))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "bed.double")
                                    .foregroundColor(.purple)
                                ForEach(1...5, id: \.self) { index in
                                    Image(systemName: index <= dream.sleepQuality ? "star.fill" : "star")
                                        .foregroundColor(index <= dream.sleepQuality ? .yellow : .gray)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10)
                )
                
                // Manual Content Card (only if there's written content)
                if hasManualContent {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                            Text("Geschriebener Trauminhalt")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        Text(dream.content)
                            .font(.body)
                            .lineSpacing(4)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.regularMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10)
                    )
                }
                
                // Transcribed Content Cards
                ForEach(Array(editableDream.audioMemos.enumerated()), id: \.element.id) { index, memo in
                    if let transcript = memo.transcript, !transcript.isEmpty {
                        TranscriptCard(
                            memo: memo,
                            index: index + 1,
                            isPlaying: currentlyPlayingAudio?.id == memo.id,
                            playbackProgress: currentlyPlayingAudio?.id == memo.id ? playbackProgress : 0,
                            onPlayToggle: { toggleAudioPlayback(memo) }
                        )
                    }
                }
                
                // Tags Card
                if !dream.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        FlowLayout(data: dream.tags) { tag in
                            Text(tag)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.purple.opacity(0.2))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.regularMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10)
                    )
                }
                
                // Audio Memos Card
                if !editableDream.audioMemos.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "waveform")
                                .foregroundColor(.purple)
                            Text("Sprachmemos")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(editableDream.audioMemos.indices, id: \.self) { index in
                                AudioMemoCard(memo: editableDream.audioMemos[index]) {
                                    // Delete audio memo
                                    editableDream.audioMemos.remove(at: index)
                                    // Update the store
                                    if let storeIndex = store.dreams.firstIndex(where: { $0.id == dream.id }) {
                                        store.dreams[storeIndex].audioMemos.remove(at: index)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.regularMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10)
                    )
                }
                
                // AI Analysis Card (optional future feature)
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.cyan)
                        Text("Traumanalyse")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Erkannte Muster:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 8) {
                            ForEach(cachedKeywords, id: \.self) { keyword in
                                Text(keyword)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.cyan.opacity(0.2))
                                    )
                            }
                        }
                        
                        Text("Zusammenfassung: \(cachedMoodAnalysis)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10)
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Design.backgroundGradient)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showEdit) {
            EditDreamView(dream: $editableDream) { updatedDream in
                if let idx = store.dreams.firstIndex(where: { $0.id == updatedDream.id }) {
                    store.dreams[idx] = updatedDream
                    // Update local dream reference
                    editableDream = updatedDream
                }
                showEdit = false
            }
        }
        .onAppear {
            generateAIAnalysis()
        }
        .onDisappear {
            stopAudioPlayback()
        }
    }
    
    // Check if there's manual written content (not from transcription)
    private var hasManualContent: Bool {
        let trimmedContent = dream.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedContent.isEmpty { return false }
        
        // Check if content matches any transcript
        for memo in editableDream.audioMemos {
            if let transcript = memo.transcript, 
               trimmedContent == transcript.trimmingCharacters(in: .whitespacesAndNewlines) {
                return false
            }
        }
        return true
    }
    
    // Audio playback functions
    private func toggleAudioPlayback(_ memo: AudioMemo) {
        if currentlyPlayingAudio?.id == memo.id {
            stopAudioPlayback()
        } else {
            playAudio(memo)
        }
    }
    
    private func playAudio(_ memo: AudioMemo) {
        stopAudioPlayback()
        
        do {
            // Configure audio session for playback with higher volume
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: memo.url)
            audioPlayer?.volume = 1.0  // Maximum volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            currentlyPlayingAudio = memo
            startPlaybackTimer()
            
            ToastManager.shared.showInfo("Wiedergabe gestartet", details: "Sprachmemo \(getIndexOfMemo(memo) + 1) • Lautstärke: Max")
        } catch {
            ToastManager.shared.showError("Wiedergabe-Fehler", details: error.localizedDescription)
        }
    }
    
    private func stopAudioPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentlyPlayingAudio = nil
        playbackProgress = 0
        stopPlaybackTimer()
    }
    
    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            guard let player = audioPlayer, player.isPlaying else {
                if audioPlayer?.isPlaying == false {
                    stopAudioPlayback()
                }
                return
            }
            
            playbackProgress = player.currentTime / player.duration
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func getIndexOfMemo(_ memo: AudioMemo) -> Int {
        return editableDream.audioMemos.firstIndex(where: { $0.id == memo.id }) ?? 0
    }
    
    // Generate AI analysis once and cache it
    private func generateAIAnalysis() {
        // Combine all text content for analysis
        var allContent = dream.content
        
        // Add transcripts from audio memos
        for memo in editableDream.audioMemos {
            if let transcript = memo.transcript, !transcript.isEmpty {
                allContent += " " + transcript
            }
        }
        
        // Generate keywords from combined content
        cachedKeywords = extractKeywords(from: allContent)
        
        // Generate comprehensive summary
        cachedMoodAnalysis = generateComprehensiveSummary(content: allContent, mood: dream.mood)
    }
    
    // Generate a comprehensive summary combining mood, content analysis, and patterns
    private func generateComprehensiveSummary(content: String, mood: Mood) -> String {
        let emotionalPatterns = analyzeEmotionalPatterns(in: content)
        let sentiment = getSentiment(from: content)
        let thematicElements = extractThematicElements(from: content)
        
        var summary = ""
        
        // Mood-based base analysis
        switch mood {
        case .cosmic:
            summary = "Transzendenter Traum mit universellen Themen"
        case .happy:
            summary = "Freudvoller Traum voller positiver Energie"
        case .sad:
            summary = "Melancholischer Traum mit emotionaler Tiefe"
        case .angry:
            summary = "Intensiver Traum mit konfliktreichen Elementen"
        case .nightmare:
            summary = "Angsttraum zur Verarbeitung tiefer Ängste"
        case .spiritual:
            summary = "Mystischer Traum mit spirituellen Erkenntnissen"
        }
        
        // Add thematic elements
        if !thematicElements.isEmpty {
            summary += " • Themen: \(thematicElements.joined(separator: ", "))"
        }
        
        // Add emotional analysis
        if !emotionalPatterns.isEmpty {
            summary += " • \(emotionalPatterns)"
        }
        
        // Add sentiment if different from mood
        if !sentiment.isEmpty && sentiment != "⚖️ Neutral" {
            summary += " • Sentiment: \(sentiment)"
        }
        
        return summary
    }
    
    // Extract thematic elements from dream content
    private func extractThematicElements(from content: String) -> [String] {
        let thematicKeywords = [
            "Natur": ["wald", "baum", "berg", "meer", "himmel", "sonne", "mond", "sterne", "tier", "blume"],
            "Bewegung": ["fliegen", "fallen", "rennen", "schwimmen", "fahren", "reisen", "gehen"],
            "Menschen": ["familie", "freund", "fremde", "kind", "mann", "frau", "person", "leute"],
            "Gebäude": ["haus", "zimmer", "schule", "kirche", "turm", "brücke", "straße"],
            "Wasser": ["meer", "see", "fluss", "regen", "schwimmen", "ertrinken", "boot"],
            "Gefahr": ["verfolgt", "angst", "monster", "kampf", "krieg", "feuer", "tod"],
            "Transformation": ["verwandeln", "ändern", "wachsen", "schrumpfen", "werden"]
        ]
        
        let lowercasedContent = content.lowercased()
        var foundThemes: [String] = []
        
        for (theme, keywords) in thematicKeywords {
            if keywords.contains(where: { lowercasedContent.contains($0) }) {
                foundThemes.append(theme)
            }
        }
        
        return foundThemes.prefix(3).map { $0 }
    }
    
    // Advanced keyword extraction using NaturalLanguage
    private func extractKeywords(from content: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType])
        tagger.string = content
        
        var keywords: [String] = []
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        
        tagger.enumerateTags(in: content.startIndex..<content.endIndex, 
                           unit: .word, 
                           scheme: .lexicalClass, 
                           options: options) { tag, tokenRange in
            
            let word = String(content[tokenRange]).lowercased()
            
            // Extract nouns, adjectives and proper nouns
            if let tag = tag, 
               (tag == .noun || tag == .adjective || tag == .personalName),
               word.count > 3,
               !isCommonWord(word) {
                keywords.append(word)
            }
            return true
        }
        
        // Get sentiment analysis
        let sentiment = getSentiment(from: content)
        if !sentiment.isEmpty {
            keywords.append(sentiment)
        }
        
        // Remove duplicates and limit to 6
        return Array(Set(keywords)).prefix(6).map { $0 }
    }
    
    private func isCommonWord(_ word: String) -> Bool {
        let commonWords = ["der", "die", "das", "und", "oder", "aber", "ich", "war", "ist", "ein", "eine", "zu", "von", "mit", "auf", "in", "für", "es", "sie", "er", "haben", "sein", "werden", "können", "müssen", "sollen", "wollen", "dann", "auch", "noch", "nur", "wie", "nach", "über", "bei", "aus", "sich", "hat", "wird", "kann", "als", "dass", "alle", "diese", "sehr", "mehr", "immer", "schon", "wieder", "hier", "dort", "heute", "gestern"]
        return commonWords.contains(word)
    }
    
    private func getSentiment(from content: String) -> String {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = content
        
        let (sentiment, _) = tagger.tag(at: content.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        if let sentimentScore = sentiment?.rawValue, let score = Double(sentimentScore) {
            switch score {
            case 0.1...1.0:
                return "🌟 Positiv"
            case (-1.0)...(-0.1):
                return "🌧️ Negativ"
            default:
                return "⚖️ Neutral"
            }
        }
        return ""
    }
    
    // AI-enhanced mood analysis with language detection
    private func getMoodAnalysis(mood: Mood) -> String {
        let _ = NLLanguageRecognizer.dominantLanguage(for: dream.content)?.rawValue ?? "de"
        
        // Analyze emotional patterns in text
        let emotionalTone = analyzeEmotionalPatterns(in: dream.content)
        
        let baseAnalysis: String
        switch mood {
        case .cosmic:
            baseAnalysis = "Transzendente Erfahrung mit universellen Themen"
        case .happy:
            baseAnalysis = "Freudvoller Traum mit positiver Energie"
        case .sad:
            baseAnalysis = "Melancholische Stimmung, emotionale Verarbeitung"
        case .angry:
            baseAnalysis = "Konflikthafte Energie, ungelöste Spannungen"
        case .nightmare:
            baseAnalysis = "Intensive Ängste, Stressverarbeitung des Unterbewusstseins"
        case .spiritual:
            baseAnalysis = "Mystische Verbindung, spirituelle Erkenntnisse"
        }
        
        return "\(baseAnalysis)\(emotionalTone.isEmpty ? "" : " • \(emotionalTone)")"
    }
    
    private func analyzeEmotionalPatterns(in text: String) -> String {
        let emotionalKeywords = [
            "Angst": ["angst", "furcht", "panik", "horror", "schrecken"],
            "Freude": ["glück", "freude", "lachen", "fröhlich", "heiter"],
            "Liebe": ["liebe", "herz", "romantik", "zärtlich", "kuscheln"],
            "Macht": ["stark", "mächtig", "kontrolle", "herrschaft", "kraft"],
            "Flucht": ["rennen", "fliehen", "verfolgt", "entkommen", "weglaufen"],
            "Transformation": ["verwandeln", "ändern", "werden", "wachsen", "entwickeln"]
        ]
        
        let lowercasedText = text.lowercased()
        var foundPatterns: [String] = []
        
        for (pattern, keywords) in emotionalKeywords {
            if keywords.contains(where: { lowercasedText.contains($0) }) {
                foundPatterns.append(pattern)
            }
        }
        
        return foundPatterns.isEmpty ? "" : "Muster: \(foundPatterns.joined(separator: ", "))"
    }
}

struct TranscriptCard: View {
    let memo: AudioMemo
    let index: Int
    let isPlaying: Bool
    let playbackProgress: Double
    let onPlayToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button(action: onPlayToggle) {
                    HStack {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .foregroundColor(.purple)
                        Text("Sprachmemo \(index)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.purple)
                        .font(.caption)
                    Text(String(format: "%.1fs", memo.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Transcript with highlighting
            TranscriptTextView(
                transcript: memo.transcript ?? "",
                isPlaying: isPlaying,
                progress: playbackProgress,
                onTap: onPlayToggle
            )
            
            // Playback progress bar
            if isPlaying {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(Color.purple)
                            .frame(width: geometry.size.width * playbackProgress, height: 4)
                    }
                }
                .frame(height: 4)
                .cornerRadius(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10)
        )
    }
}

struct TranscriptTextView: View {
    let transcript: String
    let isPlaying: Bool
    let progress: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(buildAttributedText())
                .font(.body)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
    
    private func buildAttributedText() -> AttributedString {
        var attributedString = AttributedString(transcript)
        
        if isPlaying && progress > 0 {
            // Calculate how much text should be highlighted based on progress
            let totalLength = transcript.count
            let highlightedLength = Int(Double(totalLength) * progress)
            
            if highlightedLength > 0 && highlightedLength <= totalLength {
                let safeLength = min(highlightedLength, totalLength)
                let endIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: safeLength)
                let highlightRange = attributedString.startIndex..<endIndex
                attributedString[highlightRange].backgroundColor = .purple.opacity(0.3)
                attributedString[highlightRange].foregroundColor = .primary
            }
        }
        
        return attributedString
    }
}

struct EditDreamView: View {
    @Binding var dream: DreamEntry
    var onSave: (DreamEntry) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Titel & Inhalt") {
                    TextField("Titel", text: $dream.title)
                    TextField("Inhalt", text: $dream.content, axis: .vertical)
                        .lineLimit(5...10)
                }
                Section("Stimmung & Qualität") {
                    MoodPicker(selectedMood: $dream.mood)
                    SleepQualitySlider(value: $dream.sleepQuality)
                }
                Section("Tags") {
                    TagEditor(tags: $dream.tags)
                }
                
                Section("Sprachmemos") {
                    ForEach(dream.audioMemos.indices, id: \.self) { index in
                        AudioMemoCard(memo: dream.audioMemos[index]) {
                            dream.audioMemos.remove(at: index)
                        }
                    }
                    
                    AudioMemoRecorderView(audioMemos: $dream.audioMemos)
                }
            }
            .navigationTitle("Bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        onSave(dream)
                        dismiss()
                    }
                }
            }
        }
    }
}

// Preview korrigiert
#Preview {
    DreamDetailView(dream: DreamEntry(
        date: .now,
        title: "Beispieltraum",
        content: "Testinhalt",
        mood: .cosmic,
        tags: ["Test"],
        sleepQuality: 3,
        sample: true
    ))
}
