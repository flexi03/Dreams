//
//  StatsView.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//

import SwiftUI

private struct IdentifiableDate: Identifiable {
    var id: Date { date }
    let date: Date
}

struct StatsView: View {
    @EnvironmentObject private var store: DreamStoreSampleData
    @State private var selectedDate: IdentifiableDate? = nil
    @State private var selectedStat: StatType? = nil
    
    // Hilfsfunktionen für Statistiken
    private var totalDreams: Int {
        store.dreams.count
    }
    
    private var averageSleepQuality: Double {
        guard !store.dreams.isEmpty else { return 0 }
        let sum = store.dreams.map { $0.sleepQuality }.reduce(0, +)
        return Double(sum) / Double(store.dreams.count)
    }
    
    private var mostCommonTags: [String] {
        let allTags = store.dreams.flatMap { $0.tags }
        let counts = Dictionary(grouping: allTags, by: { $0 }).mapValues { $0.count }
        let sorted = counts.sorted { $0.value > $1.value }
        return Array(sorted.prefix(3).map { $0.key })
    }
    
    private var totalAudioMemos: Int {
        store.dreams.flatMap { $0.audioMemos }.count
    }
    
    private var dreamStreak: Int {
        let sortedDreams = store.dreams.sorted { $0.date > $1.date }
        guard !sortedDreams.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        for dream in sortedDreams {
            let dreamDate = Calendar.current.startOfDay(for: dream.date)
            if dreamDate == currentDate {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if dreamDate == Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
                streak += 1
                currentDate = dreamDate
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        return streak
    }
    
    private var mostCommonMood: Mood {
        let moodCounts = Dictionary(grouping: store.dreams, by: { $0.mood })
            .mapValues { $0.count }
        return moodCounts.max(by: { $0.value < $1.value })?.key ?? .happy
    }
    
    private var weeklyDreamFrequency: Double {
        guard !store.dreams.isEmpty else { return 0 }
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let recentDreams = store.dreams.filter { $0.date >= weekAgo }
        return Double(recentDreams.count)
    }
    
    private var lucidDreamCount: Int {
        store.dreams.filter { dream in
            dream.tags.contains(where: { 
                $0.lowercased().contains("luzid") || 
                $0.lowercased().contains("klar") ||
                $0.lowercased().contains("bewusst")
            })
        }.count
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Insights Section (moved to top)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Insights")
                                    .font(.title2.bold())
                                Button(action: {
                                    withAnimation { selectedStat = .insights }
                                }) {
                                    Image(systemName: "info.circle")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                InsightCard(
                                    icon: "lightbulb.fill",
                                    color: .yellow,
                                    title: "Traumaktivität",
                                    insight: getDreamActivityInsight()
                                ) {
                                    withAnimation { selectedStat = .insights }
                                }
                                
                                InsightCard(
                                    icon: "heart.fill",
                                    color: .pink,
                                    title: "Schlafqualität",
                                    insight: getSleepQualityInsight()
                                ) {
                                    withAnimation { selectedStat = .insights }
                                }
                                
                                if lucidDreamCount > 0 {
                                    InsightCard(
                                        icon: "sparkles",
                                        color: .purple,
                                        title: "Luzide Träume",
                                        insight: "Du hattest \(lucidDreamCount) luzide Träume! Das sind \(Int((Double(lucidDreamCount) / Double(totalDreams)) * 100))% deiner Träume."
                                    ) {
                                        withAnimation { selectedStat = .insights }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top)
                        
                        // Main Statistics Grid (organized by importance)
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Übersicht")
                                    .font(.title2.bold())
                                Button(action: {
                                    withAnimation { selectedStat = .overview }
                                }) {
                                    Image(systemName: "info.circle")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Core Stats in 3x2 grid (6 most important stats)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                                StatCard(title: "Träume", value: "\(totalDreams)", systemImage: "moon.stars.fill", color: .purple) {
                                    withAnimation { selectedStat = .dreams }
                                }
                                StatCard(title: "Ø Qualität", value: String(format: "%.1f", averageSleepQuality), systemImage: "bed.double.fill", color: .indigo) {
                                    withAnimation { selectedStat = .sleepQuality }
                                }
                                StatCard(title: "Streak", value: "\(dreamStreak)", systemImage: "flame.fill", color: .red) {
                                    withAnimation { selectedStat = .streak }
                                }
                                StatCard(title: "Diese Woche", value: "\(Int(weeklyDreamFrequency))", systemImage: "calendar.badge.clock", color: .blue) {
                                    withAnimation { selectedStat = .weekly }
                                }
                                StatCard(title: "Audio Memos", value: "\(totalAudioMemos)", systemImage: "mic.fill", color: .orange) {
                                    withAnimation { selectedStat = .audioMemos }
                                }
                                StatCard(title: "Stimmung", value: mostCommonMood.rawValue, systemImage: "face.smiling", color: .yellow) {
                                    withAnimation { selectedStat = .mood }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Dream Activity Grid
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Aktivität der letzten Wochen")
                                .font(.title2.bold())
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            GitGrid()
                                .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
                .navigationTitle("Deine Traumstatistiken")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Design.backgroundGradient)
                
                // Custom Popup - positioned correctly
                if let stat = selectedStat {
                    BlurPopup(isPresented: Binding(
                        get: { selectedStat != nil },
                        set: { if !$0 { 
                            withAnimation {
                                selectedStat = nil 
                            }
                        } }
                    )) {
                        StatDetailSheet(stat: stat, store: store, onClose: { 
                            withAnimation {
                                selectedStat = nil
                            }
                        })
                    }
                    .zIndex(1000)
                }
            }
        }
    }
    
    // Helper functions for insights
    private func getDreamActivityInsight() -> String {
        if dreamStreak > 7 {
            return "Beeindruckend! Du dokumentierst deine Träume sehr konsequent. Diese Kontinuität kann deine Traumerinnerung stärken."
        } else if weeklyDreamFrequency >= 5 {
            return "Du warst diese Woche sehr aktiv! \(Int(weeklyDreamFrequency)) Träume sind ein starkes Zeichen für gute Traumerinnerung."
        } else if totalDreams > 20 {
            return "Mit \(totalDreams) dokumentierten Träumen baust du eine wertvolle Sammlung deiner nächtlichen Erlebnisse auf."
        } else {
            return "Jeder dokumentierte Traum ist ein Schritt zu besserer Selbstkenntnis. Bleib dran!"
        }
    }
    
    private func getSleepQualityInsight() -> String {
        if averageSleepQuality >= 4.5 {
            return "Exzellent! Deine durchschnittliche Schlafqualität von \(String(format: "%.1f", averageSleepQuality)) zeigt sehr erholsamen Schlaf."
        } else if averageSleepQuality >= 3.5 {
            return "Deine Schlafqualität von \(String(format: "%.1f", averageSleepQuality)) ist gut. Kleine Verbesserungen können noch mehr Erholung bringen."
        } else if averageSleepQuality >= 2.5 {
            return "Mit \(String(format: "%.1f", averageSleepQuality)) ist noch Verbesserungspotential da. Achte auf deine Schlafhygiene."
        } else {
            return "Deine Schlafqualität könnte verbessert werden. Versuche regelmäßige Schlafzeiten und entspannende Abendroutinen."
        }
    }
    
    private func getMoodName(_ mood: Mood) -> String {
        switch mood {
        case .cosmic: return "Kosmisch"
        case .happy: return "Glücklich"
        case .sad: return "Traurig"
        case .angry: return "Wütend"
        case .nightmare: return "Albtraum"
        case .spiritual: return "Spirituell"
        }
    }
    
    private func getMoodColor(_ mood: Mood) -> Color {
        switch mood {
        case .cosmic: return .purple
        case .happy: return .yellow
        case .sad: return .blue
        case .angry: return .red
        case .nightmare: return .black
        case .spiritual: return .green
        }
    }
}

// New InsightCard component
private struct InsightCard: View {
    let icon: String
    let color: Color
    let title: String
    let insight: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    Text(insight)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
        }
        .buttonStyle(.plain)
    }
}

private enum StatType: String, Identifiable, CaseIterable {
    case dreams, sleepQuality, tags, audioMemos, streak, weekly, mood, lucid, insights, overview
    var id: String { rawValue }
}

private struct StatCard: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 22))
                    .foregroundColor(color)
                    .padding(.top, 8)
                Text(value)
                    .font(.title3.bold())
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
            }
            .frame(width: 90, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.12))
            )
        }
        .buttonStyle(.plain)
    }
}

private struct StatDetailSheet: View {
    let stat: StatType
    let store: DreamStoreSampleData
    let onClose: () -> Void
    
    private var dreamStreak: Int {
        let sortedDreams = store.dreams.sorted { $0.date > $1.date }
        guard !sortedDreams.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        for dream in sortedDreams {
            let dreamDate = Calendar.current.startOfDay(for: dream.date)
            if dreamDate == currentDate {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if dreamDate == Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
                streak += 1
                currentDate = dreamDate
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        return streak
    }
    
    private var weeklyDreamFrequency: Double {
        guard !store.dreams.isEmpty else { return 0 }
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let recentDreams = store.dreams.filter { $0.date >= weekAgo }
        return Double(recentDreams.count)
    }
    
    private var lucidDreamCount: Int {
        store.dreams.filter { dream in
            dream.tags.contains(where: { 
                $0.lowercased().contains("luzid") || 
                $0.lowercased().contains("klar") ||
                $0.lowercased().contains("bewusst")
            })
        }.count
    }
    
    private func getMoodColor(_ mood: Mood) -> Color {
        switch mood {
        case .cosmic: return .purple
        case .happy: return .yellow
        case .sad: return .blue
        case .angry: return .red
        case .nightmare: return .black
        case .spiritual: return .green
        }
    }
    
    private func getMoodName(_ mood: Mood) -> String {
        switch mood {
        case .cosmic: return "Kosmisch"
        case .happy: return "Glücklich"
        case .sad: return "Traurig"
        case .angry: return "Wütend"
        case .nightmare: return "Albtraum"
        case .spiritual: return "Spirituell"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding(4)
                }
            }
            .padding(.top, 4)
            switch stat {
            case .insights:
                Text("Insights Erklärung")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Was sind Insights?")
                        .font(.subheadline.bold())
                    Text("Insights sind personalisierte Erkenntnisse basierend auf deinen Traumdaten. Sie helfen dir, Muster in deinem Schlaf und deinen Träumen zu erkennen.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Traumaktivität")
                        .font(.subheadline.bold())
                    Text("Analysiert deine Traum-Dokumentations-Gewohnheiten und gibt Tipps zur Verbesserung der Traumerinnerung.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Schlafqualität")
                        .font(.subheadline.bold())
                    Text("Bewertet deine durchschnittliche Schlafqualität und gibt Empfehlungen für besseren Schlaf.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if lucidDreamCount > 0 {
                        Text("Luzide Träume")
                            .font(.subheadline.bold())
                        Text("Luzide Träume sind Träume, in denen du dir bewusst bist, dass du träumst. Sie werden automatisch durch Tags wie 'luzid', 'klar' oder 'bewusst' erkannt.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            case .audioMemos:
                Text("Sprachmemos")
                    .font(.headline)
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(store.dreams.filter { !$0.audioMemos.isEmpty }) { dream in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dream.title)
                                    .font(.subheadline.bold())
                                Text("\(dream.audioMemos.count) Audio-Memos")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                let totalDuration = dream.audioMemos.reduce(0) { $0 + $1.duration }
                                Text("Gesamt: \(String(format: "%.1f", totalDuration))s")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(6)
                            .background(Color.orange.opacity(0.08))
                            .cornerRadius(8)
                        }
                    }
                }
                .frame(maxHeight: 400)
            case .streak:
                Text("Traum-Streak")
                    .font(.headline)
                VStack(spacing: 12) {
                    Text("\(dreamStreak)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.red)
                    Text("Tage in Folge")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if dreamStreak > 7 {
                        Text("🔥 Fantastische Serie!")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if dreamStreak > 3 {
                        Text("⭐ Guter Lauf!")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            case .weekly:
                Text("Diese Woche")
                    .font(.headline)
                VStack(spacing: 12) {
                    Text("\(Int(weeklyDreamFrequency))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Träume diese Woche")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if weeklyDreamFrequency >= 5 {
                        Text("🌟 Sehr aktive Woche!")
                    } else if weeklyDreamFrequency >= 3 {
                        Text("✨ Gute Aktivität!")
                    } else {
                        Text("💤 Ruhige Woche")
                    }
                }
            case .mood:
                Text("Stimmungsverteilung")
                    .font(.headline)
                let moodCounts = Dictionary(grouping: store.dreams, by: { $0.mood }).mapValues { $0.count }
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Mood.allCases, id: \.self) { mood in
                        let count = moodCounts[mood] ?? 0
                        if count > 0 {
                            HStack {
                                Text(mood.rawValue)
                                    .font(.title2)
                                Text(getMoodName(mood))
                                    .font(.subheadline)
                                Spacer()
                                Text("\(count)×")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(6)
                            .background(getMoodColor(mood).opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
            case .lucid:
                Text("Luzide Träume")
                    .font(.headline)
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(store.dreams.filter { dream in
                            dream.tags.contains(where: { 
                                $0.lowercased().contains("luzid") || 
                                $0.lowercased().contains("klar") ||
                                $0.lowercased().contains("bewusst")
                            })
                        }) { dream in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dream.title)
                                    .font(.subheadline.bold())
                                Text(dream.date, style: .date)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("Tags: \(dream.tags.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundColor(.cyan)
                            }
                            .padding(6)
                            .background(Color.cyan.opacity(0.08))
                            .cornerRadius(8)
                        }
                    }
                }
                .frame(maxHeight: 400)
            case .dreams:
                Text("Letzte Träume")
                    .font(.headline)
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(store.dreams.sorted(by: { $0.date > $1.date }).prefix(10)) { dream in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dream.title)
                                    .font(.subheadline.bold())
                                Text(dream.date, style: .date)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(dream.content)
                                    .font(.caption)
                                    .lineLimit(2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(6)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(8)
                        }
                    }
                }
                .frame(maxHeight: 400)
            case .sleepQuality:
                Text("Schlafqualitäts-Verteilung")
                    .font(.headline)
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(1...5, id: \ .self) { quality in
                        let count = store.dreams.filter { $0.sleepQuality == quality }.count
                        VStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.purple.opacity(0.7))
                                .frame(width: 18, height: CGFloat(count * 18 + 8))
                            Text("\(quality)")
                                .font(.caption2)
                        }
                    }
                }
                Text("1 = schlecht, 5 = sehr gut")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            case .tags:
                Text("Häufigste Tags")
                    .font(.headline)
                let allTags = store.dreams.flatMap { $0.tags }
                let counts = Dictionary(grouping: allTags, by: { $0 }).mapValues { $0.count }
                let sorted = counts.sorted { $0.value > $1.value }
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(sorted.prefix(5), id: \ .key) { tag, count in
                        HStack {
                            Text(tag)
                                .font(.subheadline)
                            Spacer()
                            Text("\(count)×")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(6)
                        .background(Color.green.opacity(0.08))
                        .cornerRadius(8)
                    }
                }
            case .overview:
                Text("Übersicht Erklärung")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Was ist die Übersicht?")
                        .font(.subheadline.bold())
                    Text("Die Übersicht zeigt dir die wichtigsten Statistiken deines Traumtagebuchs auf einen Blick. Hier findest du grundlegende Zahlen und Trends.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Träume Gesamt")
                        .font(.subheadline.bold())
                    Text("Die Gesamtzahl aller dokumentierten Träume in deinem Tagebuch.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Durchschnittliche Schlafqualität")
                        .font(.subheadline.bold())
                    Text("Basiert auf deinen Bewertungen von 1-5 Sternen für jeden Traum.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Streak & Wochenaktivität")
                        .font(.subheadline.bold())
                    Text("Zeigt deine Kontinuität beim Dokumentieren von Träumen.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: 320)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(radius: 10)
        )
        .padding()
    }
}

// BlurPopup Modifier
private struct BlurPopup<Content: View>: View {
    @Binding var isPresented: Bool
    let content: () -> Content
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .onTapGesture { isPresented = false }
            VStack {
                content()
            }
            .transition(.scale)
        }
        .animation(.easeInOut, value: isPresented)
    }
}

struct StatsViewPreview : PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(DreamStoreSampleData())
            .preferredColorScheme(.dark)
    }
}

