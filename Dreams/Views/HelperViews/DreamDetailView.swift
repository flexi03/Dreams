//
//  DreamDetailView.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//

import SwiftUI

struct DreamDetailView: View {
    let dream: DreamEntry
    let keywords = ["Wasser", "Flug", "Unbekannte Person"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Initialisierer korrigiert
                HStack {
                    Text(dream.mood.rawValue)
                        .font(.system(size: 40))
                    Text(dream.date.formatted(date: .numeric, time: .omitted))
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading) {
                    Text("Tags")
                        .font(.headline)
                    HStack {
                        ForEach(dream.tags, id: \.self) { tag in
                            Text(tag)
                                .padding(5)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Inhalt")
                        .font(.headline)
                    Text(dream.content)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading) {
                    Text("KI-Analyse")
                        .font(.headline)
                    Text("Wiederkehrende Themen: \(keywords.joined(separator: ", "))")
                        .italic()
                }
            }
            .padding()
        }
        .navigationTitle(dream.title)
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
        sleepQuality: 3 // Hinzugefügter Parameter
    ))
}
