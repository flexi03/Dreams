//
//  DreamJournalView.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//

import SwiftUI

// 5. Verbessertes Journal-View mit Swipe-Actions
struct DreamJournalView: View {
    @EnvironmentObject private var store: DreamStoreSampleData
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
        ScrollView {
            LazyVStack(spacing: 16) {
                // Quote of the Day
                QuoteOfTheDay()
                
                // Angepinnte Träume
                if !pinnedDreams.isEmpty {
                    Section {
                        ForEach(pinnedDreams) { dream in
                            let currentDreamState = store.dreams.first(where: { $0.id == dream.id })
                            DreamCard(dream: currentDreamState ?? dream)
                                .padding(.horizontal)
                                .contextMenu {
                                    Button(action: { 
                                        withAnimation { 
                                            store.togglePin(dream) 
                                        } 
                                    }) {
                                        Label((currentDreamState?.isPinned ?? dream.isPinned) ? "Entpinnen" : "Anpinnen", 
                                              systemImage: (currentDreamState?.isPinned ?? dream.isPinned) ? "pin.slash" : "pin")
                                    }
                                    Button(role: .destructive, action: { 
                                        withAnimation { 
                                            store.deleteDream(dream) 
                                        } 
                                    }) {
                                        Label("Löschen", systemImage: "trash")
                                    }
                                }
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
                        let currentDreamState = store.dreams.first(where: { $0.id == dream.id })
                        DreamCard(dream: currentDreamState ?? dream)
                            .padding(.horizontal)
                            .contextMenu {
                                Button(action: { 
                                    withAnimation { 
                                        store.togglePin(dream) 
                                    } 
                                }) {
                                    Label((currentDreamState?.isPinned ?? dream.isPinned) ? "Entpinnen" : "Anpinnen", 
                                          systemImage: (currentDreamState?.isPinned ?? dream.isPinned) ? "pin.slash" : "pin")
                                }
                                Button(role: .destructive, action: { 
                                    withAnimation { 
                                        store.deleteDream(dream) 
                                    } 
                                }) {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    Text("Alle Träume")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
            .scrollTargetLayout()
        }
        .background(Design.backgroundGradient)
        .navigationTitle("Traumtagebuch")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    SettingsView()
                } label: {
                    // wenn ios 26
                    if #available(iOS 26.0, *) {
                        Image(systemName: "person")
                            .bold()
                    } else {
                        Image(systemName: "person.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    AddDreamView()
                } label: {
                    // wenn ios 26
                    if #available(iOS 26.0, *) {
                        Image(systemName: "plus")
                            .bold()
                    } else {
                        Image(systemName: "plus")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Suche in deinen Träumen")
        .navigationDestination(for: DreamEntry.self) { dream in
            DreamDetailView(dream: dream)
        }
    }
}


#Preview {
    DreamJournalView()
        .environmentObject(DreamStoreSampleData())
        .preferredColorScheme(.dark)
}
