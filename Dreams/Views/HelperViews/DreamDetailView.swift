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
    @State private var currentlyPlayingAudio: AudioMemo?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var playbackProgress: Double = 0
    @State private var playbackTimer: Timer?
    @State private var cachedKeywords: [String] = []
    @State private var cachedMoodAnalysis: String = ""
    let dreamId: UUID
    
    init(dream: DreamEntry) {
        self.dreamId = dream.id
        self._cachedKeywords = State(initialValue: [])
        self._cachedMoodAnalysis = State(initialValue: "")
    }
    
    // Get current dream from store
    private var currentDream: DreamEntry {
        store.dreams.first { $0.id == dreamId } ?? DreamEntry(
            date: Date(),
            title: "Nicht gefunden",
            content: "Dieser Traum konnte nicht gefunden werden.",
            mood: .sad,
            tags: ["Tag1", "Tag2"],
            sleepQuality: 1,
            sample: false
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                VStack(spacing: 16) {
                    HStack {
                        Text(currentDream.mood.rawValue)
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
                        Text(currentDream.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                            Text(currentDream.date.formatted(date: .complete, time: .omitted))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "bed.double")
                                    .foregroundColor(.blue)
                                ForEach(1...5, id: \.self) { index in
                                    Image(systemName: index <= currentDream.sleepQuality ? "moon.fill" : "moon")
                                        .foregroundColor(index <= currentDream.sleepQuality ? .accentColor : .gray)
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
                        
                        Text(currentDream.content)
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
                ForEach(Array(currentDream.audioMemos.enumerated()), id: \.element.id) { index, memo in
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
                if !currentDream.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        FlowLayout(data: currentDream.tags) { tag in
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
                if !currentDream.audioMemos.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "waveform")
                                .foregroundColor(.purple)
                            Text("Sprachmemos")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(currentDream.audioMemos.indices, id: \.self) { index in
                                AudioMemoCard(memo: currentDream.audioMemos[index]) {
                                    // Delete audio memo by ID to avoid index issues
                                    let memoToDelete = currentDream.audioMemos[index]
                                    
                                    // Update the store directly
                                    if let storeIndex = store.dreams.firstIndex(where: { $0.id == dreamId }) {
                                        store.dreams[storeIndex].audioMemos.removeAll { $0.id == memoToDelete.id }
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
            EditDreamView(
                originalDreamId: dreamId,
                onSave: {
                    showEdit = false
                },
                onCancel: {
                    showEdit = false
                }
            )
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
        let trimmedContent = currentDream.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedContent.isEmpty { return false }
        
        // Check if content matches any transcript
        for memo in currentDream.audioMemos {
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
        playbackTimer?.invalidate()
        playbackTimer = nil
        audioPlayer?.stop()
        audioPlayer = nil
        currentlyPlayingAudio = nil
        playbackProgress = 0
        
        // Reset audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
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
        return currentDream.audioMemos.firstIndex(where: { $0.id == memo.id }) ?? 0
    }
    
    // Generate AI analysis once and cache it
    private func generateAIAnalysis() {
        // Combine all text content for analysis
        var allContent = currentDream.content
        
        // Add transcripts from audio memos
        for memo in currentDream.audioMemos {
            if let transcript = memo.transcript, !transcript.isEmpty {
                allContent += " " + transcript
            }
        }
        
        // Generate keywords from combined content
        cachedKeywords = extractKeywords(from: allContent)
        
        // Generate comprehensive summary
        cachedMoodAnalysis = generateComprehensiveSummary(content: allContent, mood: currentDream.mood)
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
        var thematicKeywords: [String: [String]] = [:]
        
        thematicKeywords["Natur"] = ["wald", "baum", "berg", "meer"]
        thematicKeywords["Natur"]! += ["himmel", "sonne", "mond", "sterne"]
        thematicKeywords["Natur"]! += ["tier", "blume"]
        
        thematicKeywords["Bewegung"] = ["fliegen", "fallen", "rennen"]
        thematicKeywords["Bewegung"]! += ["schwimmen", "fahren", "reisen", "gehen"]
        
        thematicKeywords["Menschen"] = ["familie", "freund", "fremde"]
        thematicKeywords["Menschen"]! += ["kind", "mann", "frau"]
        thematicKeywords["Menschen"]! += ["person", "leute"]
        
        thematicKeywords["Gebäude"] = ["haus", "zimmer", "schule"]
        thematicKeywords["Gebäude"]! += ["kirche", "turm", "brücke", "straße"]
        
        thematicKeywords["Wasser"] = ["meer", "see", "fluss"]
        thematicKeywords["Wasser"]! += ["regen", "schwimmen", "ertrinken", "boot"]
        
        thematicKeywords["Gefahr"] = ["verfolgt", "angst", "monster"]
        thematicKeywords["Gefahr"]! += ["kampf", "krieg", "feuer", "tod"]
        
        thematicKeywords["Transformation"] = ["verwandeln", "ändern"]
        thematicKeywords["Transformation"]! += ["wachsen", "schrumpfen", "werden"]
        
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
        if ["der", "die", "das"].contains(word) { return true }
        if ["ein", "eine"].contains(word) { return true }
        if ["und", "oder", "aber"].contains(word) { return true }
        if ["als", "dass"].contains(word) { return true }
        if ["ich", "es", "sie"].contains(word) { return true }
        if ["er", "sich"].contains(word) { return true }
        if ["war", "ist", "haben"].contains(word) { return true }
        if ["sein", "werden", "können"].contains(word) { return true }
        if ["müssen", "sollen", "wollen"].contains(word) { return true }
        if ["hat", "wird", "kann"].contains(word) { return true }
        if ["dann", "auch", "noch"].contains(word) { return true }
        if ["nur", "wie", "sehr"].contains(word) { return true }
        if ["mehr", "immer", "schon"].contains(word) { return true }
        if ["wieder", "hier", "dort"].contains(word) { return true }
        if ["heute", "gestern"].contains(word) { return true }
        if ["zu", "von", "mit"].contains(word) { return true }
        if ["auf", "in", "für"].contains(word) { return true }
        if ["nach", "über", "bei"].contains(word) { return true }
        if ["aus", "alle", "diese"].contains(word) { return true }
        return false
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
        let _ = NLLanguageRecognizer.dominantLanguage(for: currentDream.content)?.rawValue ?? "de"
        
        // Analyze emotional patterns in text
        let emotionalTone = analyzeEmotionalPatterns(in: currentDream.content)
        
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
        var emotionalKeywords: [String: [String]] = [:]
        
        emotionalKeywords["Angst"] = ["angst", "furcht"]
        emotionalKeywords["Angst"]! += ["panik", "horror", "schrecken"]
        
        emotionalKeywords["Freude"] = ["glück", "freude"]
        emotionalKeywords["Freude"]! += ["lachen", "fröhlich", "heiter"]
        
        emotionalKeywords["Liebe"] = ["liebe", "herz"]
        emotionalKeywords["Liebe"]! += ["romantik", "zärtlich", "kuscheln"]
        
        emotionalKeywords["Macht"] = ["stark", "mächtig"]
        emotionalKeywords["Macht"]! += ["kontrolle", "herrschaft", "kraft"]
        
        emotionalKeywords["Flucht"] = ["rennen", "fliehen"]
        emotionalKeywords["Flucht"]! += ["verfolgt", "entkommen", "weglaufen"]
        
        emotionalKeywords["Transformation"] = ["verwandeln", "ändern"]
        emotionalKeywords["Transformation"]! += ["werden", "wachsen", "entwickeln"]
        
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
    @EnvironmentObject private var store: DreamStoreSampleData
    @State private var tempDreamId: UUID
    let originalDreamId: UUID
    var onSave: () -> Void
    var onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(originalDreamId: UUID, onSave: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.originalDreamId = originalDreamId
        self._tempDreamId = State(initialValue: UUID()) // Temp dream gets new ID
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    // Get the temp dream for editing
    private var tempDream: Binding<DreamEntry> {
        if let index = store.dreams.firstIndex(where: { $0.id == tempDreamId }) {
            return $store.dreams[index]
        }
        // Fallback - should not happen
        return .constant(DreamEntry(
            date: Date(),
            title: "Error",
            content: "",
            mood: .sad,
            tags: [],
            sleepQuality: 1,
            sample: false
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Titel & Inhalt") {
                    TextField("Titel", text: tempDream.title)
                    TextField("Inhalt", text: tempDream.content, axis: .vertical)
                        .lineLimit(5...10)
                }
                Section("Stimmung & Qualität") {
                    MoodPicker(selectedMood: tempDream.mood)
                    SleepQualitySlider(value: tempDream.sleepQuality)
                }
                Section("Tags") {
                    TagEditor(tags: tempDream.tags)
                }
                
                Section("Sprachmemos") {
                    ForEach(tempDream.wrappedValue.audioMemos.indices, id: \.self) { index in
                        AudioMemoCard(memo: tempDream.wrappedValue.audioMemos[index]) {
                            tempDream.wrappedValue.audioMemos.remove(at: index)
                        }
                    }
                    
                    AudioMemoRecorderView(audioMemos: tempDream.audioMemos)
                }
            }
            .navigationTitle("Bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { 
                        // Delete temp dream
                        store.dreams.removeAll { $0.id == tempDreamId }
                        dismiss()
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        // Copy temp dream data to original
                        if let tempIndex = store.dreams.firstIndex(where: { $0.id == tempDreamId }),
                           let originalIndex = store.dreams.firstIndex(where: { $0.id == originalDreamId }) {
                            
                            let tempData = store.dreams[tempIndex]
                            // Copy all data except ID and date
                            store.dreams[originalIndex].title = tempData.title
                            store.dreams[originalIndex].content = tempData.content
                            store.dreams[originalIndex].mood = tempData.mood
                            store.dreams[originalIndex].tags = tempData.tags
                            store.dreams[originalIndex].sleepQuality = tempData.sleepQuality
                            store.dreams[originalIndex].audioMemos = tempData.audioMemos
                            store.dreams[originalIndex].isPinned = tempData.isPinned
                        }
                        
                        // Delete temp dream
                        store.dreams.removeAll { $0.id == tempDreamId }
                        dismiss()
                        onSave()
                    }
                }
            }
            .onAppear {
                createTempDream()
            }
        }
    }
    
    private func createTempDream() {
        // Find original dream and create a copy
        if let originalDream = store.dreams.first(where: { $0.id == originalDreamId }) {
            let tempDream = DreamEntry(
                id: tempDreamId,
                isPinned: originalDream.isPinned,
                date: originalDream.date,
                title: originalDream.title,
                content: originalDream.content,
                mood: originalDream.mood,
                tags: originalDream.tags,
                sleepQuality: originalDream.sleepQuality,
                audioMemos: originalDream.audioMemos,
                sample: originalDream.sample
            )
            store.dreams.append(tempDream)
        }
    }
}

// Preview korrigiert
#Preview {
    DreamDetailView(dream: DreamEntry(
        date: .now,
        title: "Beispiel Traum",
        content: "Dies ist ein Beispieltraum für die Vorschau mit etwas längerem Inhalt um die Darstellung zu testen.",
        mood: .nightmare,
        tags: ["Beispiel", "Vorschau"],
        sleepQuality: 4,
        sample: true
    ))
    .environmentObject(DreamStoreSampleData())
    .preferredColorScheme(.dark)
}
