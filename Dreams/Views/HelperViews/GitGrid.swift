//
//  GitGrid.swift
//  Dreams
//
//  Created by Felix Kircher on 22.05.25.
//

import SwiftUI

private struct IdentifiableDate: Identifiable {
    var id: Date { date }
    let date: Date
}

struct GitGrid: View {
    
    @EnvironmentObject private var store: DreamStoreSampleData
    @State private var selectedDate: IdentifiableDate? = nil
    
    var body: some View {
        LazyHGrid(rows: Array(repeating: GridItem(.fixed(16), spacing: 6), count: 7), spacing: 6) {
            ForEach(0..<98, id: \.self) { index in
                let date = Calendar.current.date(byAdding: .day, value: -index, to: Date())!
                let count = groupedEntriesByDate[Calendar.current.startOfDay(for: date)]?.count ?? 0
                Rectangle()
                    .fill(color(for: count))
                    .frame(width: 18, height: 18)
                    .cornerRadius(5)
                    .onTapGesture {
                        selectedDate = IdentifiableDate(date: Calendar.current.startOfDay(for: date))
                    }
                    .help("\(formattedDate(date)): \(count) Eintrag(e)")
            }
        }
        .padding()
        //            .frame(maxWidth: 320, maxHeight: 200)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
            
        }
        //            .padding(.horizontal)
        .sheet(item: $selectedDate) { identifiable in
            GitGridDayDetailView(date: identifiable.date, entries: groupedEntriesByDate[identifiable.date] ?? [])
        }

    }
        
    
    
    private var groupedEntriesByDate: [Date: [DreamEntry]] {
        Dictionary(grouping: store.dreams) { dream in
            Calendar.current.startOfDay(for: dream.date)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func color(for count: Int) -> Color {
        switch count {
        case 0: return Color.gray.opacity(0.1)
        case 1: return Color.green.opacity(0.4)
        case 2...3: return Color.green.opacity(0.7)
        default: return Color.green
        }
    }
}

struct GitGridDayDetailView: View {
    let date: Date
    let entries: [DreamEntry]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDream: DreamEntry?
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(formattedDate(date))
                        .font(.title2.bold())
                    
                    HStack {
                        Image(systemName: "moon.stars.fill")
                            .foregroundColor(.purple)
                        Text("\(entries.count) Traum\(entries.count == 1 ? "" : "träume")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                if entries.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Image(systemName: "moon.zzz")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Keine Träume an diesem Tag")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Vielleicht war es eine ruhige Nacht ohne Traumerinnerung.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Dreams List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(entries, id: \.id) { entry in
                                DreamPreviewCard(entry: entry) {
                                    selectedDream = entry
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Träume")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .sheet(item: $selectedDream) { dream in
            NavigationStack {
                DreamDetailView(dream: dream)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Schließen") {
                                selectedDream = nil
                            }
                        }
                    }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

struct DreamPreviewCard: View {
    let entry: DreamEntry
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with title and mood
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text(timeFormatted(entry.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(entry.mood.rawValue)
                        .font(.title2)
                }
                
                // Content preview
                if !entry.content.isEmpty {
                    Text(entry.content)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                // Bottom info row
                HStack(spacing: 16) {
                    // Sleep quality
                    HStack(spacing: 4) {
                        ForEach(0..<5, id: \.self) { index in
                            Image(systemName: index < entry.sleepQuality ? "moon.fill" : "moon")
                                .font(.caption)
                                .foregroundColor(index < entry.sleepQuality ? .yellow : .gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Tags
                    if !entry.tags.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "tag.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            Text(entry.tags.prefix(2).joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.blue)
                            if entry.tags.count > 2 {
                                Text("+\(entry.tags.count - 2)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Audio indicator
                    if !entry.audioMemos.isEmpty {
                        HStack(spacing: 2) {
                            Image(systemName: "mic.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            Text("\(entry.audioMemos.count)")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func timeFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
