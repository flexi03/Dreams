//
//  DreamPass.swift
//  Dreams
//
//  Created by Felix Kircher on 27.06.25.
//

import SwiftUI
import Foundation

// MARK: - DreamPass Model
struct DreamPass: Identifiable, Codable {
    let id: UUID
    let name: String
    let createdDate: Date
    let totalDreams: Int
    let currentStreak: Int
    let favoriteTag: String
    let dominantMood: Mood
    let passNumber: String
    let colorScheme: DreamPassColorScheme
    
    init(name: String, dreams: [DreamEntry], existingPass: DreamPass? = nil) {
        if let existing = existingPass {
            // Verwende existierendes Design, aktualisiere nur Daten
            self.id = existing.id
            self.createdDate = existing.createdDate
            self.passNumber = existing.passNumber
            self.colorScheme = existing.colorScheme
        } else {
            // Erstelle neues Design
            self.id = UUID()
            self.createdDate = Date()
            self.passNumber = Self.generatePassNumber()
            self.colorScheme = DreamPassColorScheme.random()
        }
        
        // Diese Werte werden immer aktualisiert
        self.name = name
        self.totalDreams = dreams.count
        self.currentStreak = Self.calculateStreak(dreams: dreams)
        self.favoriteTag = Self.findFavoriteTag(dreams: dreams)
        self.dominantMood = Self.findDominantMood(dreams: dreams)
    }
    
    private static func calculateStreak(dreams: [DreamEntry]) -> Int {
        let calendar = Calendar.current
        let sortedDreams = dreams.sorted { $0.date > $1.date }
        
        var streak = 0
        var currentDate = Date()
        
        for dream in sortedDreams {
            if calendar.isDate(dream.date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if calendar.isDate(dream.date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    private static func findFavoriteTag(dreams: [DreamEntry]) -> String {
        var tagCounts: [String: Int] = [:]
        
        for dream in dreams {
            for tag in dream.tags {
                tagCounts[tag, default: 0] += 1
            }
        }
        
        return tagCounts.max(by: { $0.value < $1.value })?.key ?? "Träumer"
    }
    
    private static func findDominantMood(dreams: [DreamEntry]) -> Mood {
        var moodCounts: [Mood: Int] = [:]
        
        for dream in dreams {
            moodCounts[dream.mood, default: 0] += 1
        }
        
        return moodCounts.max(by: { $0.value < $1.value })?.key ?? .cosmic
    }
    
    private static func generatePassNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: Date())
        let randomSuffix = String(format: "%04d", Int.random(in: 1000...9999))
        return "DP-\(dateString)-\(randomSuffix)"
    }
}

// MARK: - Color Schemes
struct DreamPassColorScheme: Codable {
    let primary: CodableColor
    let secondary: CodableColor
    let accent: CodableColor
    let background: CodableColor
    let name: String
    
    static func random() -> DreamPassColorScheme {
        let schemes = [
            // Cosmic Theme
            DreamPassColorScheme(
                primary: CodableColor(.purple),
                secondary: CodableColor(.indigo),
                accent: CodableColor(.pink),
                background: CodableColor(.black),
                name: "Cosmic Dreams"
            ),
            // Ocean Theme
            DreamPassColorScheme(
                primary: CodableColor(.blue),
                secondary: CodableColor(.teal),
                accent: CodableColor(.cyan),
                background: CodableColor(.navy),
                name: "Ocean Depths"
            ),
            // Sunset Theme
            DreamPassColorScheme(
                primary: CodableColor(.orange),
                secondary: CodableColor(.red),
                accent: CodableColor(.yellow),
                background: CodableColor(.brown),
                name: "Sunset Reverie"
            ),
            // Forest Theme
            DreamPassColorScheme(
                primary: CodableColor(.green),
                secondary: CodableColor(.mint),
                accent: CodableColor(.yellow),
                background: CodableColor(.black),
                name: "Forest Whispers"
            ),
            // Aurora Theme
            DreamPassColorScheme(
                primary: CodableColor(.green),
                secondary: CodableColor(.blue),
                accent: CodableColor(.purple),
                background: CodableColor(.black),
                name: "Aurora Borealis"
            )
        ]
        
        return schemes.randomElement() ?? schemes[0]
    }
}

// MARK: - Codable Color Helper
struct CodableColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    init(_ color: Color) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }
    
    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

// Convenience extensions
extension Color {
    static let navy = Color(.sRGB, red: 0.0, green: 0.0, blue: 0.2, opacity: 1.0)
}