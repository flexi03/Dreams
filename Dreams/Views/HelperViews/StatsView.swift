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
                                    withAnimation { selectedStat = .totalDreams }
                                }
                                StatCard(title: "Ø Qualität", value: String(format: "%.1f", averageSleepQuality), systemImage: "bed.double.fill", color: .indigo) {
                                    withAnimation { selectedStat = .averageSleepQuality }
                                }
                                StatCard(title: "Streak", value: "\(dreamStreak)", systemImage: "flame.fill", color: .red) {
                                    withAnimation { selectedStat = .dreamStreak }
                                }
                                StatCard(title: "Diese Woche", value: "\(Int(weeklyDreamFrequency))", systemImage: "calendar.badge.clock", color: .blue) {
                                    withAnimation { selectedStat = .weeklyFrequency }
                                }
                                StatCard(title: "Audio Memos", value: "\(totalAudioMemos)", systemImage: "mic.fill", color: .orange) {
                                    withAnimation { selectedStat = .audioMemos }
                                }
                                StatCard(title: "Stimmung", value: mostCommonMood.rawValue, systemImage: "face.smiling", color: .yellow) {
                                    withAnimation { selectedStat = .moodDistribution }
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
    
    private var totalAudioMemos: Int {
        store.dreams.flatMap { $0.audioMemos }.count
    }
    
    private var averageSleepQuality: Double {
        guard !store.dreams.isEmpty else { return 0 }
        let sum = store.dreams.map { $0.sleepQuality }.reduce(0, +)
        return Double(sum) / Double(store.dreams.count)
    }
    
    private var mostCommonMood: Mood {
        let moodCounts = Dictionary(grouping: store.dreams, by: { $0.mood })
            .mapValues { $0.count }
        return moodCounts.max(by: { $0.value < $1.value })?.key ?? .happy
    }
    
    private var mostCommonTags: [String] {
        let allTags = store.dreams.flatMap { $0.tags }
        let counts = Dictionary(grouping: allTags, by: { $0 }).mapValues { $0.count }
        let sorted = counts.sorted { $0.value > $1.value }
        return Array(sorted.prefix(3).map { $0.key })
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
        case .totalDreams:
            totalDreamsView()
        case .averageSleepQuality:
            averageSleepQualityView()
        case .dreamStreak:
            dreamStreakView()
        case .weeklyFrequency:
            weeklyFrequencyView()
        case .audioMemos:
            audioMemosView()
        case .moodDistribution:
            moodDistributionView()
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
                Text("Insights sind intelligente Analysen deiner \(store.dreams.count) dokumentierten Träume. Sie erkennen automatisch Muster in deinem Schlafverhalten, analysieren deine Traumqualität und geben dir personalisierte Empfehlungen für bessere Traumerinnerung.")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                
                Divider()
                
                Text("🎯 Wie funktionieren sie?")
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
                VStack(alignment: .leading, spacing: 6) {
                    Text("• Analysieren deine \(dreamStreak)-Tage-Streak und Kontinuität")
                    Text("• Bewerten deine durchschnittliche Schlafqualität (\(String(format: "%.1f", averageSleepQuality))⭐)")
                    Text("• Erkennen besondere Traumarten (z.B. \(lucidDreamCount) luzide Träume)")
                    Text("• Geben praktische Tipps basierend auf deinen echten Daten")
                }
                .font(.body)
                .foregroundColor(.secondary)
                
                Divider()
                
                Text("🧠 Deine Muster:")
                    .font(.subheadline.bold())
                    .foregroundColor(.purple)
                VStack(alignment: .leading, spacing: 6) {
                    Text("• Häufigste Stimmung: \(getMoodName(mostCommonMood)) (\(mostCommonMood.rawValue))")
                    Text("• Audio-Memos aufgenommen: \(totalAudioMemos)")
                    Text("• Diese Woche dokumentiert: \(Int(weeklyDreamFrequency)) Träume")
                    if !mostCommonTags.isEmpty {
                        Text("• Beliebte Tags: \(mostCommonTags.prefix(2).joined(separator: ", "))")
                    }
                }
                .font(.body)
                .foregroundColor(.secondary)
                
                Divider()
                
                Text("📱 Interaktion")
                    .font(.subheadline.bold())
                    .foregroundColor(.green)
                Text("Tippe auf jedes einzelne Insight für detaillierte Erklärungen und spezifische Empfehlungen zu deinem persönlichen Traumverhalten.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
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
            
            // Explanation
            lucidDreamExplanation()
            
            // Current Status
            lucidDreamStatus()
            
            // Analysis
            lucidDreamAnalysis()
            
            // Tips
            lucidDreamTips()
        }
    }
    
    private func lucidDreamExplanation() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Was sind luzide Träume?")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Luzide Träume sind Träume, in denen du dir bewusst bist, dass du träumst. In diesem Zustand kannst du oft aktiv Einfluss auf den Traumverlauf nehmen und bewusste Entscheidungen treffen.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("🌟 Besonderheiten:")
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
                Text("• Du erkennst während des Träumens, dass es ein Traum ist")
                Text("• Du kannst bewusst handeln und Entscheidungen treffen")
                Text("• Oft sehr lebendige und detailreiche Traumerfahrungen")
                Text("• Möglichkeit, Ängste zu überwinden oder Fähigkeiten zu trainieren")
            }
            .font(.body)
            .foregroundColor(.secondary)
            
            Divider()
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
    
    private func totalDreamsView() -> some View {
        VStack(spacing: 16) {
            Text("🌙 Deine Traumsammlung")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Deine Bilanz:")
                    .font(.subheadline.bold())
                    .foregroundColor(.purple)
                Text("Du hast bereits \(store.dreams.count) Träume dokumentiert! Das ist eine beeindruckende Sammlung deiner nächtlichen Abenteuer.")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("📊 Einordnung:")
                        .font(.subheadline.bold())
                        .foregroundColor(.blue)
                    if store.dreams.count == 0 {
                        Text("• Zeit für deinen ersten Traum! 🚀")
                    } else if store.dreams.count < 5 {
                        Text("• Du stehst noch am Anfang deiner Traumreise")
                        Text("• Jeder neue Traum bringt dich weiter")
                    } else if store.dreams.count < 20 {
                        Text("• Du entwickelst eine schöne Routine")
                        Text("• Deine Traumerinnerung wird immer stärker")
                    } else if store.dreams.count < 50 {
                        Text("• Du bist ein echter Traumsammler geworden!")
                        Text("• Deine Sammlung zeigt schöne Muster")
                    } else {
                        Text("• Wow! Du bist ein wahrer Traummeister 🏆")
                        Text("• Deine Sammlung ist beeindruckend umfangreich")
                    }
                }
                .font(.body)
                .foregroundColor(.secondary)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("🎯 Motivation:")
                        .font(.subheadline.bold())
                        .foregroundColor(.green)
                    if store.dreams.count < 10 {
                        Text("• Versuche eine Woche lang jeden Tag zu dokumentieren")
                        Text("• Schon 10 Träume zeigen erste Muster")
                    } else if store.dreams.count < 30 {
                        Text("• Du könntest bald deine persönlichen Traumthemen entdecken")
                        Text("• 30 Träume sind ein toller Meilenstein!")
                    } else {
                        Text("• Du hast genug Daten für tiefe Einblicke")
                        Text("• Achte auf wiederkehrende Symbole und Themen")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
    
    private func averageSleepQualityView() -> some View {
        VStack(spacing: 16) {
            Text("😴 Deine Schlafqualität")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Dein Durchschnitt:")
                    .font(.subheadline.bold())
                    .foregroundColor(.indigo)
                
                let avgQuality = store.dreams.isEmpty ? 0 : Double(store.dreams.map { $0.sleepQuality }.reduce(0, +)) / Double(store.dreams.count)
                Text("Mit \(String(format: "%.1f", avgQuality)) von 5 Sternen zeigst du \(getQualityDescription(avgQuality))!")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.indigo.opacity(0.1))
                    .cornerRadius(8)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("📈 Details:")
                        .font(.subheadline.bold())
                        .foregroundColor(.blue)
                    
                    let excellentNights = store.dreams.filter { $0.sleepQuality >= 5 }.count
                    let goodNights = store.dreams.filter { $0.sleepQuality >= 4 }.count
                    let okayNights = store.dreams.filter { $0.sleepQuality >= 3 }.count
                    
                    Text("• Perfekte Nächte (5⭐): \(excellentNights)")
                    Text("• Sehr gute Nächte (4⭐+): \(goodNights)")
                    Text("• Okay Nächte (3⭐+): \(okayNights)")
                    
                    if store.dreams.count > 0 {
                        let excellentPercent = Int((Double(excellentNights) / Double(store.dreams.count)) * 100)
                        Text("• \(excellentPercent)% deiner Nächte waren perfekt!")
                    }
                }
                .font(.body)
                .foregroundColor(.secondary)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("💡 Verbesserung:")
                        .font(.subheadline.bold())
                        .foregroundColor(.green)
                    if avgQuality < 3 {
                        Text("• Versuche eine entspannende Abendroutine")
                        Text("• Achte auf regelmäßige Schlafzeiten")
                        Text("• Reduziere Bildschirmzeit vor dem Schlafen")
                    } else if avgQuality < 4 {
                        Text("• Du schläfst schon gut - kleine Optimierungen helfen")
                        Text("• Experimentiere mit der Raumtemperatur")
                        Text("• Achte auf deine Ernährung am Abend")
                    } else {
                        Text("• Du schläfst fantastisch! 🎉")
                        Text("• Behalte deine erfolgreichen Gewohnheiten bei")
                        Text("• Du könntest anderen Tipps geben")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
    
    private func dreamStreakView() -> some View {
        VStack(spacing: 16) {
            Text("🔥 Deine Traum-Streak")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Aktuelle Serie:")
                    .font(.subheadline.bold())
                    .foregroundColor(.red)
                Text("Du dokumentierst seit \(dreamStreak) Tag\(dreamStreak == 1 ? "" : "en") deine Träume! \(getStreakMotivation())")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("🏆 Streak-Level:")
                        .font(.subheadline.bold())
                        .foregroundColor(.orange)
                    if dreamStreak == 0 {
                        Text("• Bereit für den Start! 🚀")
                        Text("• Schon morgen früh kannst du beginnen")
                    } else if dreamStreak < 3 {
                        Text("• 🌱 Anfänger - Du fängst gerade an")
                        Text("• Jeder Tag zählt!")
                    } else if dreamStreak < 7 {
                        Text("• 🌿 Fortgeschritten - Du bist auf einem guten Weg")
                        Text("• Eine Woche ist das erste große Ziel")
                    } else if dreamStreak < 14 {
                        Text("• 🌳 Erfahren - Du hast eine tolle Routine entwickelt")
                        Text("• Zwei Wochen sind beeindruckend!")
                    } else if dreamStreak < 30 {
                        Text("• 🎯 Profi - Du beherrschst die Traumerinnerung")
                        Text("• Ein Monat ist ein fantastischer Meilenstein")
                    } else {
                        Text("• 👑 Meister - Du bist unglaublich konsequent!")
                        Text("• Deine Disziplin ist vorbildlich")
                    }
                }
                .font(.body)
                .foregroundColor(.secondary)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("🎯 Nächstes Ziel:")
                        .font(.subheadline.bold())
                        .foregroundColor(.green)
                    if dreamStreak < 7 {
                        Text("• Erreiche eine Woche (\(7 - dreamStreak) Tage noch)")
                        Text("• Lege das Handy direkt neben dein Bett")
                    } else if dreamStreak < 14 {
                        Text("• Schaffe zwei Wochen (\(14 - dreamStreak) Tage noch)")
                        Text("• Du bildest gerade eine starke Gewohnheit")
                    } else if dreamStreak < 30 {
                        Text("• Erreiche einen ganzen Monat!")
                        Text("• Du bist schon sehr nah dran")
                    } else {
                        Text("• Du könntest auf 50 oder sogar 100 Tage gehen!")
                        Text("• Du bist bereits ein Vorbild für andere")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
    
    private func weeklyFrequencyView() -> some View {
        VStack(spacing: 16) {
            Text("📅 Diese Woche")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Deine Wochenbilanz:")
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
                Text("In den letzten 7 Tagen hast du \(Int(weeklyDreamFrequency)) Träume dokumentiert. \(getWeeklyMotivation())")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("📊 Wochenrhythmus:")
                        .font(.subheadline.bold())
                        .foregroundColor(.purple)
                    
                    let weeklyRate = weeklyDreamFrequency / 7.0 * 100
                    Text("• Tägliche Rate: \(String(format: "%.0f", weeklyRate))%")
                    
                    if weeklyDreamFrequency == 0 {
                        Text("• Diese Woche war ruhig - das ist normal!")
                        Text("• Manchmal braucht unser Geist eine Pause")
                    } else if weeklyDreamFrequency < 3 {
                        Text("• Ein entspanntes Tempo")
                        Text("• Qualität ist wichtiger als Quantität")
                    } else if weeklyDreamFrequency < 5 {
                        Text("• Eine ausgewogene Woche")
                        Text("• Du findest einen guten Rhythmus")
                    } else if weeklyDreamFrequency == 7 {
                        Text("• Perfekte Woche! Jeden Tag dokumentiert! 🎉")
                        Text("• Das ist außergewöhnlich konsequent")
                    } else {
                        Text("• Sehr aktive Traumwoche!")
                        Text("• Du erinnerst dich an sehr viele Details")
                    }
                }
                .font(.body)
                .foregroundColor(.secondary)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("🚀 Für nächste Woche:")
                        .font(.subheadline.bold())
                        .foregroundColor(.green)
                    if weeklyDreamFrequency < 3 {
                        Text("• Versuche 4-5 Träume zu dokumentieren")
                        Text("• Stelle dir einen sanften Wecker für morgens")
                    } else if weeklyDreamFrequency < 7 {
                        Text("• Du könntest eine perfekte Woche schaffen!")
                        Text("• Versuche auch an Wochenenden zu dokumentieren")
                    } else {
                        Text("• Halte dein fantastisches Tempo!")
                        Text("• Du könntest anderen zeigen, wie es geht")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
    
    private func audioMemosView() -> some View {
        VStack(spacing: 16) {
            Text("🎤 Deine Audio-Memos")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Deine Sprachnotizen:")
                    .font(.subheadline.bold())
                    .foregroundColor(.orange)
                Text("Du hast \(totalAudioMemos) Audio-Memos aufgenommen! \(getAudioMemoDescription())")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("🎯 Nutzen von Audio-Memos:")
                        .font(.subheadline.bold())
                        .foregroundColor(.purple)
                    Text("• Schneller als Tippen direkt nach dem Aufwachen")
                    Text("• Erfassen auch Emotionen und Stimmungen")
                    Text("• Können später transkribiert werden")
                    Text("• Ideal für komplexe oder lange Träume")
                    if totalAudioMemos > 0 {
                        let averagePerDream = Double(totalAudioMemos) / Double(max(store.dreams.count, 1))
                        Text("• Du nutzt durchschnittlich \(String(format: "%.1f", averagePerDream)) Memos pro Traum")
                    }
                }
                .font(.body)
                .foregroundColor(.secondary)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("💡 Tipp:")
                        .font(.subheadline.bold())
                        .foregroundColor(.green)
                    if totalAudioMemos == 0 {
                        Text("• Probiere Audio-Memos für deinen nächsten Traum!")
                        Text("• Besonders hilfreich direkt nach dem Aufwachen")
                        Text("• Du kannst sprechen ohne die Augen zu öffnen")
                    } else if totalAudioMemos < 5 {
                        Text("• Audio-Memos werden mit der Zeit natürlicher")
                        Text("• Sprich einfach drauf los - Details kommen später")
                    } else {
                        Text("• Du nutzt Audio-Memos bereits sehr gut!")
                        Text("• Achte auf die automatische Transkription")
                        Text("• Memos können auch Stimmungen erfassen")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
    
    private func moodDistributionView() -> some View {
        VStack(spacing: 16) {
            Text("😊 Deine Traumstimmungen")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Deine häufigste Stimmung:")
                    .font(.subheadline.bold())
                    .foregroundColor(.yellow)
                Text("Deine Träume sind am häufigsten \(getMoodName(mostCommonMood).lowercased()) (\(mostCommonMood.rawValue)). \(getMoodInsight())")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(getMoodColor(mostCommonMood).opacity(0.1))
                    .cornerRadius(8)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("🎨 Stimmungsverteilung:")
                        .font(.subheadline.bold())
                        .foregroundColor(.blue)
                    
                    let moodCounts = Dictionary(grouping: store.dreams, by: { $0.mood }).mapValues { $0.count }
                    ForEach(Mood.allCases, id: \.self) { mood in
                        let count = moodCounts[mood] ?? 0
                        if count > 0 {
                            let percentage = store.dreams.count > 0 ? Int((Double(count) / Double(store.dreams.count)) * 100) : 0
                            Text("• \(getMoodName(mood)): \(count)x (\(percentage)%)")
                        }
                    }
                }
                .font(.body)
                .foregroundColor(.secondary)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("🧠 Bedeutung:")
                        .font(.subheadline.bold())
                        .foregroundColor(.green)
                    switch mostCommonMood {
                    case .happy:
                        Text("• Fröhliche Träume deuten auf positives Wohlbefinden hin")
                        Text("• Du verarbeitest wahrscheinlich schöne Erlebnisse")
                    case .cosmic:
                        Text("• Kosmische Träume zeigen spirituelle Verbindung")
                        Text("• Du denkst gerne über große Zusammenhänge nach")
                    case .spiritual:
                        Text("• Spirituelle Träume deuten auf innere Suche hin")
                        Text("• Du beschäftigst dich mit tieferen Lebensfragen")
                    case .sad:
                        Text("• Traurige Träume helfen bei der Verarbeitung")
                        Text("• Das ist ein natürlicher Teil des Heilungsprozesses")
                    case .angry:
                        Text("• Wütende Träume verarbeiten oft Frustration")
                        Text("• Träume helfen beim Abbau von Anspannung")
                    case .nightmare:
                        Text("• Albträume verarbeiten oft Ängste und Stress")
                        Text("• Häufige Albträume sollten beachtet werden")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }
    
    // Helper functions for the new views
    private func getQualityDescription(_ quality: Double) -> String {
        if quality >= 4.5 { return "exzellenten Schlaf" }
        else if quality >= 3.5 { return "guten Schlaf" }
        else if quality >= 2.5 { return "okay Schlaf" }
        else { return "Verbesserungspotential" }
    }
    
    private func getStreakMotivation() -> String {
        if dreamStreak == 0 { return "Zeit für einen Neustart! 🚀" }
        else if dreamStreak == 1 { return "Ein großartiger Anfang! 🌱" }
        else if dreamStreak < 7 { return "Du baust eine tolle Gewohnheit auf! 💪" }
        else if dreamStreak < 14 { return "Beeindruckende Konstanz! 🔥" }
        else if dreamStreak < 30 { return "Du bist ein wahrer Traumdokumentations-Profi! 🏆" }
        else { return "Unglaublich! Du bist ein Meister der Konstanz! 👑" }
    }
    
    private func getWeeklyMotivation() -> String {
        if weeklyDreamFrequency == 0 { return "Manchmal braucht die Seele eine Pause - das ist völlig normal." }
        else if weeklyDreamFrequency < 3 { return "Ein entspanntes Tempo, das ist völlig in Ordnung." }
        else if weeklyDreamFrequency < 5 { return "Eine schöne Balance aus Dokumentation und Entspannung." }
        else if weeklyDreamFrequency == 7 { return "Wahnsinn! Jeden Tag dokumentiert - du bist unglaublich!" }
        else { return "So eine aktive Traumwoche ist beeindruckend!" }
    }
    
    private func getAudioMemoDescription() -> String {
        if totalAudioMemos == 0 { return "Audio-Memos sind ein großartiges Tool, das du noch entdecken kannst." }
        else if totalAudioMemos < 5 { return "Du probierst Audio-Memos aus - ein cleverer Ansatz!" }
        else if totalAudioMemos < 15 { return "Du nutzt Audio-Memos regelmäßig - sehr praktisch!" }
        else { return "Du bist ein Audio-Memo-Experte! Sehr effizient." }
    }
    
    private func getMoodInsight() -> String {
        switch mostCommonMood {
        case .happy: return "Das zeigt eine positive Grundstimmung in deinem Leben."
        case .cosmic: return "Du hast eine tiefe Verbindung zum Universum und großen Fragen."
        case .spiritual: return "Deine Träume spiegeln eine spirituelle Reise wider."
        case .sad: return "Deine Träume helfen dir beim Verarbeiten von Emotionen."
        case .angry: return "Träume sind ein sicherer Ort, um Frustrationen zu verarbeiten."
        case .nightmare: return "Albträume können Stress oder Ängste widerspiegeln - das ist normal."
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