//
//  AddDreamView.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//

import SwiftUI
import AVFoundation

// 9. Erweitertes AddDreamView mit Sleep Quality Picker und Audioaufnahme
struct AddDreamView: View {
    @EnvironmentObject private var store: DreamStoreSampleData
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: Mood = .happy
    @State private var tags: [String] = []
    @State private var sleepQuality = 3
    @State private var audioURL: URL? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Grundinformationen") {
                    TextField("Titel", text: $title)
                    TextField("Beschreibung", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                }
                
                Section("Bewertung") {
                    MoodPicker(selectedMood: $selectedMood)
                    SleepQualitySlider(value: $sleepQuality)
                }
                
                Section("Tags") {
                    TagEditor(tags: $tags)
                }
                
                Section("Sprachnotiz") {
                    AudioRecorderView(audioURL: $audioURL)
                }
            }
            .navigationTitle("Neuer Traumeintrag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Abbrechen") { dismiss() }
//                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Speichern") {
                        let newDream = DreamEntry(
                            date: .now,
                            title: title.isEmpty ? "Ohne Titel" : title,
                            content: content,
                            mood: selectedMood,
                            tags: tags,
                            sleepQuality: sleepQuality,
                            audioURL: audioURL,
                            sample: false
                        )
                        store.dreams.insert(newDream, at: 0)
                        dismiss()
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddDreamView()
}
