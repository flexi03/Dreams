//
//  DreamEntry.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//

import Foundation

// 1. Erweitertes Datenmodell mit Sleep-Quality
enum Mood: String, CaseIterable, Identifiable {
    case cosmic = "🌌"
    case happy = "😊"
    case sad = "😢"
    case nightmare = "😱"
    case spiritual = "🔮"
    var id: Self { self }
}

struct DreamEntry: Identifiable {
    let id = UUID()
    let date: Date
    var title: String
    var content: String
    var mood: Mood
    var tags: [String]
    var sleepQuality: Int // 1-5
}

// 2. Data Store mit Beispiel-Daten
class DreamStore: ObservableObject {
    @Published var dreams: [DreamEntry] = [
        DreamEntry(
            date: Date().addingTimeInterval(-86400),
            title: "Flug über die Berge",
            content: "Ich schwebte über schneebedeckte Gipfel, als plötzlich...",
            mood: .cosmic,
            tags: ["Luzid", "Freiheit"],
            sleepQuality: 4
        ),
        DreamEntry(
            date: Date().addingTimeInterval(-172800),
            title: "Verlorene Stadt",
            content: "Ein Labyrinth aus alten Steinen, das nie enden wollte...",
            mood: .nightmare,
            tags: ["Albtraum", "Wiederkehrend"],
            sleepQuality: 2
        )
    ]
}
