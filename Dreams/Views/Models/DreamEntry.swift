//
//  DreamEntry.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//

import Foundation
import Speech
import SwiftUI

// 1. Erweitertes Datenmodell mit Sleep-Quality
enum Mood: String, CaseIterable, Identifiable, Codable {
    case cosmic = "🌌"
    case happy = "😊"
    case sad = "😢"
    case angry = "😡"
    case nightmare = "😱"
    case spiritual = "🔮"
    var id: Self { self }
}

struct AudioMemo: Identifiable, Hashable, Codable {
    let id: UUID
    let url: URL
    let createdAt: Date
    var transcript: String?
    var duration: TimeInterval
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AudioMemo, rhs: AudioMemo) -> Bool {
        lhs.id == rhs.id
    }
    
    init(url: URL, transcript: String? = nil, duration: TimeInterval = 0) {
        self.id = UUID()
        self.url = url
        self.createdAt = Date()
        self.transcript = transcript
        self.duration = duration
    }
    
    enum CodingKeys: String, CodingKey {
        case id, url, createdAt, transcript, duration
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        // Store just the filename
        try container.encode(url.lastPathComponent, forKey: .url)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(transcript, forKey: .transcript)
        try container.encode(duration, forKey: .duration)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        let urlString = try container.decode(String.self, forKey: .url)
        
        // Reconstruct absolute path from filename
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        if urlString.hasPrefix("file://") || urlString.hasPrefix("/") {
            // Old format with full path - try to extract filename
            let filename = URL(string: urlString)?.lastPathComponent ?? urlString.components(separatedBy: "/").last ?? urlString
            url = documentsPath.appendingPathComponent(filename)
        } else {
            // New format with just filename
            url = documentsPath.appendingPathComponent(urlString)
        }
        
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        transcript = try container.decodeIfPresent(String.self, forKey: .transcript)
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration) ?? 0
    }
}


struct DreamEntry: Identifiable, Hashable, Codable {
    let id: UUID
    var isPinned: Bool = false
    let date: Date
    var title: String
    var content: String
    var mood: Mood
    var tags: [String]
    var sleepQuality: Int // 1-5
    var audioMemos: [AudioMemo]
    var sample: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DreamEntry, rhs: DreamEntry) -> Bool {
        lhs.id == rhs.id
    }
    
    init(id: UUID = UUID(), isPinned: Bool = false, date: Date, title: String, content: String, mood: Mood, tags: [String], sleepQuality: Int, audioMemos: [AudioMemo] = [], sample: Bool) {
        self.id = id
        self.isPinned = isPinned
        self.date = date
        self.title = title
        self.content = content
        self.mood = mood
        self.tags = tags
        self.sleepQuality = sleepQuality
        self.audioMemos = audioMemos
        self.sample = sample
    }
    
    // Custom encoder to ensure all fields are properly saved
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encode(date, forKey: .date)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(mood, forKey: .mood)
        try container.encode(tags, forKey: .tags)
        try container.encode(sleepQuality, forKey: .sleepQuality)
        try container.encode(audioMemos, forKey: .audioMemos)
        try container.encode(sample, forKey: .sample)
    }
    
    // Custom decoder to handle missing audioMemos field in existing data
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        date = try container.decode(Date.self, forKey: .date)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        mood = try container.decode(Mood.self, forKey: .mood)
        tags = try container.decode([String].self, forKey: .tags)
        sleepQuality = try container.decode(Int.self, forKey: .sleepQuality)
        audioMemos = try container.decodeIfPresent([AudioMemo].self, forKey: .audioMemos) ?? []
        sample = try container.decode(Bool.self, forKey: .sample)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, isPinned, date, title, content, mood, tags, sleepQuality, audioMemos, sample
    }
}

// 2. Data Store Sample Data mit Beispiel-Daten
class DreamStoreSampleData: ObservableObject {
    @Published var dreams: [DreamEntry] = [] {
        didSet { saveDreams() }
    }
    private let storageKey = "dreams_v1"
    
    init() {
        loadDreams()
    }
    
    private func saveDreams() {
        do {
            let data = try JSONEncoder().encode(dreams)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Fehler beim Speichern der Träume: \(error)")
        }
    }
    
    private func loadDreams() {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do {
                dreams = try JSONDecoder().decode([DreamEntry].self, from: data)
            } catch {
                print("Fehler beim Laden der Träume: \(error)")
                dreams = Self.sampleDreams
            }
        } else {
            dreams = Self.sampleDreams
        }
    }
    
    public func deleteDream(_ dream: DreamEntry) {
        dreams.removeAll { $0.id == dream.id }
    }
    public func togglePin(_ dream: DreamEntry) {
        if let index = dreams.firstIndex(where: { $0.id == dream.id }) {
            dreams[index].isPinned.toggle()
            print("Debug: Toggled pin for dream \(dream.title) to \(dreams[index].isPinned)")
            
            // Force save immediately
            saveDreams()
        }
    }
    
    public func addSampleData() {
        let additionalSampleDreams = [
            DreamEntry(
                date: Date().addingTimeInterval(-3600), // 1 Stunde vor
                title: "Debug Test Traum",
                content: "Dies ist ein Test-Traum für Debug-Zwecke.",
                mood: .cosmic,
                tags: ["Test", "Debug"],
                sleepQuality: 4,
                sample: true
            ),
            DreamEntry(
                date: Date().addingTimeInterval(-7200), // 2 Stunden vor
                title: "Zweiter Test Traum",
                content: "Ein weiterer Traum für die Testdaten.",
                mood: .happy,
                tags: ["Sample", "Zufall"],
                sleepQuality: 5,
                sample: true
            )
        ]
        dreams.append(contentsOf: additionalSampleDreams)
    }
    
    // Beispiel-Daten nur beim ersten Start
    private static var sampleDreams: [DreamEntry] {
        [
            DreamEntry(
                date: Date().addingTimeInterval(-86400),
                title: "Hi",
                content: "Content",
                mood: .happy,
                tags: ["Tag1", "Tag2"],
                sleepQuality: 1,
                sample: true),
            DreamEntry(
                date: Date().addingTimeInterval(-86400),
                title: "Flug über die Berge",
                content: "Ich schwebte über schneebedeckte Gipfel, als plötzlich ein schwarzes Loch auf mich trat. Es war dunkel und es hörte sich ein lautes Knacken an. Ich konnte nicht fliehen. Es wurde immer dunkler und dann war ich wieder auf der Erde. Es fühlte sich so real an. Es fühlte sich so real an. Es fühlte sich so real an. Es fühlte sich so real an. Es fühlte sich so real an.",
                mood: .cosmic,
                tags: ["Luzid", "Freiheit"],
                sleepQuality: 4,
                sample: true
            ),
            DreamEntry(
                date: Date().addingTimeInterval(-172800),
                title: "Verlorene Stadt",
                content: "Ein Labyrinth aus alten Steinen, das nie enden wollte und mich in einen Albtraum verschluckte.",
                mood: .nightmare,
                tags: ["Albtraum", "Wiederkehrend"],
                sleepQuality: 2,
                sample: true
            ),
            DreamEntry(
                date: Date().addingTimeInterval(-259200),
                title: "Fliegende Inseln",
                content: "Ich war auf einer Insel, die im Wind flog und ich konnte mit den Wellen tanzen. Es war ein schöner Tag. Es war ein schöner Tag. ",
                mood: .happy,
                tags: ["Natur", "Freude"],
                sleepQuality: 5,
                sample: true
            ),
            DreamEntry(
                date: Date().addingTimeInterval(-345600),
                title: "Ritt im Regen",
                content: "Ich rode in einer stormhaften Regenfälle. Es regnete ständig und ich konnte nicht bremsen. Es regnete ständig und ich konnte nicht bremsen. Es regnete ständig und ich konnte nicht bremsen.",
                mood: .angry,
                tags: ["Rennen", "Regen"],
                sleepQuality: 1,
                sample: true
            )
        ]
    }
}
