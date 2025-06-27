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
                                
                                Spacer()
                                
                                // Dream Pass Preview Button
                                NavigationLink(destination: DreamPassView()) {
                                    VStack(spacing: 4) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.purple, .blue, .pink],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 50, height: 32)
                                            
                                            Image(systemName: "creditcard")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        Text("Dream Pass")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            
                            VStack(spacing: 12) {
                                InsightCard(
                                    icon: "lightbulb.fill",
                                    color: .yellow,
                                    title: "Traumaktivität",
                                    insight: getDreamActivityInsight()
                                ) {
                                    withAnimation { selectedStat = .dreamActivity }
                                }
                                
                                InsightCard(
                                    icon: "heart.fill",
                                    color: .pink,
                                    title: "Schlafqualität",
                                    insight: getSleepQualityInsight()
                                ) {
                                    withAnimation { selectedStat = .sleepQualityInsight }
                                }
                                
                                if lucidDreamCount > 0 {
                                    InsightCard(
                                        icon: "sparkles",
                                        color: .purple,
                                        title: "Luzide Träume",
                                        insight: "Du hattest \(lucidDreamCount) luzide Träume! Das sind \(Int((Double(lucidDreamCount) / Double(totalDreams)) * 100))% deiner Träume."
                                    ) {
                                        withAnimation { selectedStat = .lucidInsight }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
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
            }
        }
        .sheet(item: $selectedStat) { stat in
            StatDetailSheet(stat: stat, store: store) {
                selectedStat = nil
            }
            .presentationDetents([.medium, .large])
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
    case dreamActivity, sleepQualityInsight, lucidInsight
    case dreamStreak, averageSleepQuality, moodDistribution, totalDreams, lucidDreams, weeklyFrequency
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
    @Environment(\.dismiss) private var dismiss
    
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
    
    private func getDreamActivityInsight() -> String {
        if dreamStreak > 7 {
            return "Beeindruckend! Du dokumentierst deine Träume sehr konsequent. Diese Kontinuität kann deine Traumerinnerung stärken."
        } else if weeklyDreamFrequency >= 5 {
            return "Du warst diese Woche sehr aktiv! \(Int(weeklyDreamFrequency)) Träume sind ein starkes Zeichen für gute Traumerinnerung."
        } else if store.dreams.count > 20 {
            return "Mit \(store.dreams.count) dokumentierten Träumen baust du eine wertvolle Sammlung deiner nächtlichen Erlebnisse auf."
        } else {
            return "Jeder dokumentierte Traum ist ein Schritt zu besserer Selbstkenntnis. Bleib dran!"
        }
    }
    
    private func getSleepQualityInsight() -> String {
        let avgQuality = store.dreams.isEmpty ? 0 : Double(store.dreams.map { $0.sleepQuality }.reduce(0, +)) / Double(store.dreams.count)
        if avgQuality >= 4.5 {
            return "Exzellent! Deine durchschnittliche Schlafqualität von \(String(format: "%.1f", avgQuality)) zeigt sehr erholsamen Schlaf."
        } else if avgQuality >= 3.5 {
            return "Deine Schlafqualität von \(String(format: "%.1f", avgQuality)) ist gut. Kleine Verbesserungen können noch mehr Erholung bringen."
        } else if avgQuality >= 2.5 {
            return "Mit \(String(format: "%.1f", avgQuality)) ist noch Verbesserungspotential da. Achte auf deine Schlafhygiene."
        } else {
            return "Deine Schlafqualität könnte verbessert werden. Versuche regelmäßige Schlafzeiten und entspannende Abendroutinen."
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
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    contentForStat(stat)
                }
            }
            .padding()
            .navigationTitle(getNavigationTitle(for: stat))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                        onClose()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func contentForStat(_ stat: StatType) -> some View {
        switch stat {
        case .insights:
            insightsView()
        case .dreamActivity:
            dreamActivityView()
        case .sleepQualityInsight:
            sleepQualityInsightView()
        case .lucidInsight:
            lucidInsightView()
        default:
            defaultView(for: stat)
        }
    }
    
    private func insightsView() -> some View {
        VStack(spacing: 16) {
            Text("💡 Insights - Deine persönlichen Traumerkenntnisse")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Was sind Insights?")
                    .font(.subheadline.bold())
                    .foregroundColor(.yellow)
                Text("Insights sind intelligente Analysen deiner Traumdaten. Sie erkennen automatisch Muster, Trends und geben dir personalisierte Empfehlungen für besseren Schlaf und stärkere Traumerinnerung.")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Divider()
                    .background(Color.yellow.opacity(0.3))
                
                Text("🎯 Wie funktionieren sie?")
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Analysieren deine Traum-Häufigkeit und Kontinuität")
                    Text("• Bewerten deine Schlafqualität über Zeit")
                    Text("• Erkennen besondere Traumarten (wie luzide Träume)")
                    Text("• Geben praktische Tipps zur Verbesserung")
                }
                .font(.body)
                .foregroundColor(.secondary)
                
                Divider()
                    .background(Color.blue.opacity(0.3))
                
                Text("📱 Interaktion")
                    .font(.subheadline.bold())
                    .foregroundColor(.green)
                Text("Tippe auf jedes einzelne Insight für detaillierte Erklärungen und spezifische Empfehlungen zu diesem Bereich.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
    
    private func dreamActivityView() -> some View {
        VStack(spacing: 16) {
            Text("🔥 Traumaktivität Insight")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Deine aktuelle Situation:")
                    .font(.subheadline.bold())
                    .foregroundColor(.yellow)
                Text(getDreamActivityInsight())
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                
                Divider()
                
                dreamActivityStats()
                
                Divider()
                
                dreamActivityRecommendations()
            }
        }
    }
    
    private func dreamActivityStats() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("📊 Deine Statistiken:")
                .font(.subheadline.bold())
                .foregroundColor(.blue)
            Text("• Aktuelle Streak: \(dreamStreak) Tage")
            Text("• Träume diese Woche: \(Int(weeklyDreamFrequency))")
            Text("• Träume gesamt: \(store.dreams.count)")
        }
        .font(.body)
        .foregroundColor(.secondary)
    }
    
    private func dreamActivityRecommendations() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("💡 Empfehlungen:")
                .font(.subheadline.bold())
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                if dreamStreak < 3 {
                    Text("• Versuche jeden Morgen sofort nach dem Aufwachen an deine Träume zu denken")
                    Text("• Halte ein Traumtagebuch direkt neben dem Bett bereit")
                    Text("• Stelle dir vor dem Schlafen vor, dass du dich an deine Träume erinnern wirst")
                } else if dreamStreak < 7 {
                    Text("• Du machst großartige Fortschritte! Bleib dran")
                    Text("• Versuche auch Details wie Emotionen und Farben zu notieren")
                    Text("• Experimentiere mit verschiedenen Aufwach-Zeiten")
                } else {
                    Text("• Fantastisch! Du hast eine starke Traumerinnerung entwickelt")
                    Text("• Versuche nun, Muster in deinen Träumen zu erkennen")
                    Text("• Experimentiere mit luziden Traum-Techniken")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
    
    private func sleepQualityInsightView() -> some View {
        VStack(spacing: 16) {
            Text("💤 Schlafqualität Insight")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Deine Bewertung:")
                    .font(.subheadline.bold())
                    .foregroundColor(.pink)
                Text(getSleepQualityInsight())
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.pink.opacity(0.1))
                    .cornerRadius(8)
                
                Divider()
                
                sleepQualityAnalysis()
                
                Divider()
                
                sleepQualityTips()
            }
        }
    }
    
    private func sleepQualityAnalysis() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("📈 Schlafqualitäts-Analyse:")
                .font(.subheadline.bold())
                .foregroundColor(.blue)
            
            let avgQuality = store.dreams.isEmpty ? 0 : Double(store.dreams.map { $0.sleepQuality }.reduce(0, +)) / Double(store.dreams.count)
            Text("• Durchschnitt: \(String(format: "%.1f", avgQuality))/5 Sterne")
            
            let recentQuality = store.dreams.sorted { $0.date > $1.date }.prefix(5)
            if !recentQuality.isEmpty {
                let recentAvg = Double(recentQuality.map { $0.sleepQuality }.reduce(0, +)) / Double(recentQuality.count)
                Text("• Letzte 5 Träume: \(String(format: "%.1f", recentAvg))/5")
            }
            
            let excellentNights = store.dreams.filter { $0.sleepQuality >= 5 }.count
            Text("• Exzellente Nächte (5⭐): \(excellentNights)")
        }
        .font(.body)
        .foregroundColor(.secondary)
    }
    
    private func sleepQualityTips() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🌙 Tipps für besseren Schlaf:")
                .font(.subheadline.bold())
                .foregroundColor(.green)
            
            let currentAvgQuality = store.dreams.isEmpty ? 0 : Double(store.dreams.map { $0.sleepQuality }.reduce(0, +)) / Double(store.dreams.count)
            
            VStack(alignment: .leading, spacing: 4) {
                if currentAvgQuality < 3 {
                    Text("• Entwickle eine entspannende Abendroutine")
                    Text("• Vermeide Bildschirme 1h vor dem Schlafen")
                    Text("• Halte dein Schlafzimmer kühl und dunkel")
                    Text("• Versuche jeden Tag zur gleichen Zeit zu schlafen")
                } else if currentAvgQuality < 4 {
                    Text("• Experimentiere mit Entspannungstechniken vor dem Schlafen")
                    Text("• Achte auf deine Koffein-Aufnahme am Nachmittag")
                    Text("• Versuche 7-9 Stunden Schlaf pro Nacht")
                } else {
                    Text("• Du schläfst bereits sehr gut!")
                    Text("• Halte deine erfolgreichen Schlafgewohnheiten bei")
                    Text("• Achte auf Faktoren, die besonders gute Nächte begünstigen")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
    
    private func lucidInsightView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(.purple)
                Text("Luzide Träume")
                    .font(.title2.bold())
            }
            
            // Current Status
            lucidDreamStatus()
            
            // Analysis
            lucidDreamAnalysis()
            
            // Tips
            lucidDreamTips()
        }
    }
    
    private func lucidDreamStatus() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Deine Luzidität")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(lucidDreamCount)")
                        .font(.largeTitle.bold())
                        .foregroundColor(.purple)
                    Text("Luzide Träume")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(store.dreams.count > 0 ? Int((Double(lucidDreamCount) / Double(store.dreams.count)) * 100) : 0)%")
                        .font(.title.bold())
                        .foregroundColor(.purple)
                    Text("deiner Träume")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.opacity(0.1))
            )
        }
    }
    
    private func lucidDreamAnalysis() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Analyse")
                .font(.headline)
                .foregroundColor(.primary)
            
            if lucidDreamCount == 0 {
                Text("Du hattest noch keine dokumentierten luziden Träume. Das ist völlig normal - luzide Träume sind eine Fähigkeit, die entwickelt werden kann!")
                    .font(.body)
                    .foregroundColor(.secondary)
            } else if lucidDreamCount < 3 {
                Text("Du hast erste Erfolge mit luziden Träumen! Das zeigt, dass du bereits ein gutes Bewusstsein für deine Träume entwickelst.")
                    .font(.body)
                    .foregroundColor(.secondary)
            } else if Double(lucidDreamCount) / Double(store.dreams.count) > 0.2 {
                Text("Beeindruckend! Mit \(Int((Double(lucidDreamCount) / Double(store.dreams.count)) * 100))% luziden Träumen bist du bereits sehr erfahren in der Traumkontrolle.")
                    .font(.body)
                    .foregroundColor(.secondary)
            } else {
                Text("Du entwickelst deine Fähigkeiten im luziden Träumen stetig weiter. Kontinuität ist der Schlüssel zum Erfolg!")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func lucidDreamTips() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipps für mehr Luzidität")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                TipRow(icon: "eye", text: "Reality Checks: Schaue mehrmals täglich auf deine Hände und frage dich: 'Träume ich?'")
                TipRow(icon: "book", text: "Führe regelmäßig Traumtagebuch - das stärkt dein Traumbewusstsein erheblich")
                TipRow(icon: "bed.double", text: "Optimiere deinen Schlaf: 7-9 Stunden und regelmäßige Zeiten fördern REM-Phasen")
                TipRow(icon: "target", text: "Setze dir vor dem Schlafen die Intention: 'Heute Nacht erkenne ich, dass ich träume'")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
    
    private func defaultView(for stat: StatType) -> some View {
        Text("Details für \(getNavigationTitle(for: stat))")
            .font(.headline)
    }
    
    private func getNavigationTitle(for stat: StatType) -> String {
        switch stat {
        case .insights: return "Insights"
        case .dreamActivity: return "Traumaktivität"
        case .sleepQualityInsight: return "Schlafqualität"
        case .lucidInsight: return "Luzide Träume"
        case .audioMemos: return "Audio-Memos"
        case .streak: return "Traum-Streak"
        case .weekly: return "Diese Woche"
        case .mood: return "Stimmungen"
        case .lucid: return "Luzide Träume"
        case .dreams: return "Träume"
        case .sleepQuality: return "Schlafqualität"
        case .tags: return "Tags"
        case .overview: return "Übersicht"
        case .dreamStreak: return "Traum-Streak"
        case .averageSleepQuality: return "Durchschnittliche Schlafqualität"
        case .moodDistribution: return "Stimmungsverteilung"
        case .totalDreams: return "Träume Gesamt"
        case .lucidDreams: return "Luzide Träume"
        case .weeklyFrequency: return "Wöchentliche Häufigkeit"
        }
    }
}

private struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .frame(width: 16)
                .foregroundColor(.purple)
            Text(text)
                .multilineTextAlignment(.leading)
        }
    }
}

struct StatsViewPreview : PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(DreamStoreSampleData())
            .preferredColorScheme(.dark)
    }
}