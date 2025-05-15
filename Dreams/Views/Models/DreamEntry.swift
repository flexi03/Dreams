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
    case angry = "😡"
    case nightmare = "😱"
    case spiritual = "🔮"
    var id: Self { self }
}

struct DreamEntry: Identifiable, Hashable {
    let id = UUID()
    var isPinned: Bool = false
    let date: Date
    var title: String
    var content: String
    var mood: Mood
    var tags: [String]
    var sleepQuality: Int // 1-5
    var audioURL: URL? // URL zur gespeicherten Audiodatei
    var sample: Bool
}

// 2. Data Store Sample Data mit Beispiel-Daten
class DreamStoreSampleData: ObservableObject {
    @Published var dreams: [DreamEntry] = [
        DreamEntry(
            date: Date().addingTimeInterval(-86400),
            title: "Hi",
            content: "Content",
            mood: .happy,
            tags: ["Tag1", "Tag2"],
            sleepQuality: 1,
            audioURL: nil,
            sample: true),
        DreamEntry(
            date: Date().addingTimeInterval(-86400),
            title: "Flug über die Berge",
            content: "Ich schwebte über schneebedeckte Gipfel, als plötzlich ein schwarzes Loch auf mich trat. Es war dunkel und es hörte sich ein lautes Knacken an. Ich konnte nicht fliehen. Es wurde immer dunkler und dann war ich wieder auf der Erde. Es fühlte sich so real an. Es fühlte sich so real an. Es fühlte sich so real an. Es fühlte sich so real an. Es fühlte sich so real an.",
            mood: .cosmic,
            tags: ["Luzid", "Freiheit"],
            sleepQuality: 4,
            audioURL: nil,
            sample: true
        ),
        DreamEntry(
            date: Date().addingTimeInterval(-172800),
            title: "Verlorene Stadt",
            content: "Ein Labyrinth aus alten Steinen, das nie enden wollte und mich in einen Albtraum verschluckte.",
            mood: .nightmare,
            tags: ["Albtraum", "Wiederkehrend"],
            sleepQuality: 2,
            audioURL: nil,
            sample: true
        ),
        DreamEntry(
            date: Date().addingTimeInterval(-259200),
            title: "Fliegende Inseln",
            content: "Ich war auf einer Insel, die im Wind flog und ich konnte mit den Wellen tanzen. Es war ein schöner Tag. Es war ein schöner Tag. ",
            mood: .happy,
            tags: ["Natur", "Freude"],
            sleepQuality: 5,
            audioURL: nil,
            sample: true
        ),
        DreamEntry(
            date: Date().addingTimeInterval(-345600),
            title: "Ritt im Regen",
            content: "Ich rode in einer stormhaften Regenfälle. Es regnete ständig und ich konnte nicht bremsen. Es regnete ständig und ich konnte nicht bremsen. Es regnete ständig und ich konnte nicht bremsen.",
            mood: .angry,
            tags: ["Rennen", "Regen"],
            sleepQuality: 1,
            audioURL: nil,
            sample: true
        )
    ]
    public func deleteDream(_ dream: DreamEntry) {
        dreams.removeAll { $0.id == dream.id }
    }
    public func togglePin(_ dream: DreamEntry) {
        if let index = dreams.firstIndex(where: { $0.id == dream.id }) {
            dreams[index].isPinned.toggle()
        }
    }
}
