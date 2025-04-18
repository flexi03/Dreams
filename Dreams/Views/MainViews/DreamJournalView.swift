//
//  DreamJournalView.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//

import SwiftUI

// 5. Verbessertes Journal-View mit Swipe-Actions
struct DreamJournalView: View {
    @EnvironmentObject private var store: DreamStore
    @State private var searchText = ""
    
    // Gefilterte und sortierte Träume
    private var filteredDreams: [DreamEntry] {
        if searchText.isEmpty {
            return store.dreams
        } else {
            return store.dreams.filter { dream in
                dream.title.localizedCaseInsensitiveContains(searchText) ||
                dream.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private var pinnedDreams: [DreamEntry] {
        filteredDreams.filter { $0.isPinned }.sorted(by: { $0.date > $1.date })
    }
    
    private var unpinnedDreams: [DreamEntry] {
        filteredDreams.filter { !$0.isPinned }.sorted(by: { $0.date > $1.date })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Angepinnte Träume
                    if !pinnedDreams.isEmpty {
                        Section {
                            ForEach(pinnedDreams) { dream in
                                SwipeableCard(
                                    dream: dream,
                                    onDelete: { withAnimation { store.deleteDream(dream) } },
                                    onPin: { withAnimation { store.togglePin(dream) } }
                                )
                            }
                        } header: {
                            Text("Angepinnt")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Alle Träume
                    Section {
                        ForEach(unpinnedDreams) { dream in
                            SwipeableCard(
                                dream: dream,
                                onDelete: { withAnimation { store.deleteDream(dream) } },
                                onPin: { withAnimation { store.togglePin(dream) } }
                            )
                        }
                    } header: {
                        Text("Alle Träume")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
//            .scrollIndicators(.hidden)
//                        .contentMargins(.vertical, 16)
            .background(Design.backgroundGradient)
            .navigationTitle("Traumtagebuch")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddDreamView()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Suche in deinen Träumen")
        }
    }
}


#Preview {
    DreamJournalView()
        .environmentObject(DreamStore())
}
