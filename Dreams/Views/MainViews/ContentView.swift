//
//  ContentView.swift
//  Dreams
//
//  Created by Felix Kircher on 04.04.25.
//

import SwiftUI
import AVFoundation // Für Sprachaufnahme

// Diktieren

// 3. Design Constants
struct Design {
    static let gradient = LinearGradient(
        colors: [.indigo, .purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [Color(.systemGray6), Color(.systemGray5)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// 4. Haupt-View mit TabBar
struct ContentView: View {
    @StateObject private var store = DreamStore()
    @State private var selectedTab: Tab = .journal
    
    enum Tab: String {
        case journal = "Tagebuch"
        case stats = "Statistiken"
        case profile = "Profil"
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DreamJournalView()
                .tabItem {
                    Label("Traumtagebuch", systemImage: "book.closed")
                }
                .tag(Tab.journal)
            
            StatsView()
                .tabItem {
                    Label("Analysen", systemImage: "chart.bar")
                }
                .tag(Tab.stats)
        }
        .tint(.purple)
        .environmentObject(store)
    }
}

// ContentView Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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
