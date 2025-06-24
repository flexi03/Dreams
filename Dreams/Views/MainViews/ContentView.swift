//
//  ContentView.swift
//  Dreams
//
//  Created by Felix Kircher on 04.04.25.
//

import SwiftUI
import AVFoundation // Für Sprachaufnahme

// Diktieren



// 4. Haupt-View mit TabBar
struct ContentView: View {
    @StateObject private var store = DreamStoreSampleData()
    @EnvironmentObject private var activityManager: DreamActivityManager
    @State private var selectedTab: Tab = .journal
    
    enum Tab: String {
        case journal = "Tagebuch"
        case stats = "Statistiken"
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DreamJournalView()
            }
            .tabItem {
                Label("Traumtagebuch", systemImage: "book.closed")
            }
            .tag(Tab.journal)
            
            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Analysen", systemImage: "chart.bar")
            }
            .tag(Tab.stats)
        }
        .tint(.purple)
        .environmentObject(store)
        .onAppear {
            // ActivityManager mit Store verbinden
            activityManager.setStore(store)
        }
    }
}

// ContentView Preview
// Füge einen Preview-Provider mit Dummy-Daten hinzu
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .withToasts()
            .preferredColorScheme(.dark)
    }
} 

//// Intro Preview
//struct IntroductionView_Previews: PreviewProvider {
//    static var previews: some View {
//        IntroductionView()
//    }
//}


//// Testdaten
//let sampleDream = DreamEntry(
//    date: Date(),
//    title: "Flug über die Alpen",
//    content: "Ich konnte fliegen, aber meine Flügel waren aus Glas...",
//    mood: "🌌",
//    tags: ["Luzid", "Kreativ"]
//)
