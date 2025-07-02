//
//  AddDreamView.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//

import SwiftUI
import AVFoundation

// 9. Erweitertes AddDreamView mit Sleep Quality Picker
struct AddDreamView: View {
    @EnvironmentObject private var store: DreamStoreSampleData
    @EnvironmentObject private var activityManager: DreamActivityManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: Mood = .happy
    @State private var tags: [String] = []
    @State private var sleepQuality = 3
    @State private var audioMemos: [AudioMemo] = []
    
    private var canSave: Bool {
        let hasTitle = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasContent = !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasTranscript = audioMemos.contains { memo in
            memo.transcript?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }
        
        return hasTitle && (hasContent || hasTranscript)
    }
    
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
                
                Section("Sprachmemos") {
                    ForEach(audioMemos.indices, id: \.self) { index in
                        AudioMemoCard(memo: audioMemos[index]) {
                            audioMemos.remove(at: index)
                        }
                    }
                    
                    AudioMemoRecorderView(audioMemos: $audioMemos)
                }
            }
            .navigationTitle("Neuer Traumeintrag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Speichern") {
                        // Auto-fill content from transcript if empty
                        var finalContent = content
                        if finalContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            if let transcript = audioMemos.first(where: { $0.transcript?.isEmpty == false })?.transcript {
                                finalContent = transcript
                                ToastManager.shared.showInfo("Beschreibung automatisch aus Transkript übernommen")
                            }
                        }
                        
                        let newDream = DreamEntry(
                            date: .now,
                            title: title,
                            content: finalContent,
                            mood: selectedMood,
                            tags: tags,
                            sleepQuality: sleepQuality,
                            audioMemos: audioMemos,
                            sample: false
                        )
                        store.dreams.insert(newDream, at: 0)
                        
                        // LiveActivity aktualisieren
                        activityManager.setStore(store)
                        activityManager.updateActivityWithRealData()
                        
                        ToastManager.shared.showSuccess("Traum gespeichert", details: "\(audioMemos.count) Audio-Memos hinzugefügt • LiveActivity aktualisiert")
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}

#Preview {
    AddDreamView()
        .preferredColorScheme(.dark)
}
