//
//  DreamCard.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//

import SwiftUI

// 6. DreamCard-Komponente mit Animation
struct DreamCard: View {
    let dream: DreamEntry
    @State private var isExpanded = false
    
    var body: some View {
        NavigationLink(value: dream) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(dream.mood.rawValue)
                        .font(.system(size: 40))
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(dream.title)
                                .font(.headline)
                            
                            // Content type indicators
                            HStack(spacing: 6) {
                                if hasManualContent {
                                    Image(systemName: "pencil")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .padding(4)
                                        .background(
                                            Circle()
                                                .fill(Color.blue.opacity(0.2))
                                        )
                                }
                                if hasAudioContent {
                                    HStack(spacing: 2) {
                                        Image(systemName: "mic.fill")
                                            .font(.caption)
                                            .foregroundColor(.purple)
                                        Text("\(dream.audioMemos.count)")
                                            .font(.caption2)
                                            .foregroundColor(.purple)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color.purple.opacity(0.2))
                                    )
                                }
                            }
                        }
                        
                        Text(dream.date.formatted(date: .numeric, time: .omitted))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    SleepQualityIndicator(quality: dream.sleepQuality)
                }
                
                if !dream.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(dream.content)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .lineLimit(Int(isExpanded ? 100 : 3))
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(getContentBackgroundColor())
                        )
                }
                
                if isExpanded {
                    Group {
                        // Korrigiertes FlowLayout mit data-Parameter
                        FlowLayout(data: dream.tags) { tag in
                            Text(tag)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.purple.opacity(0.2))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                                        ))
                        }
                    }
                    .padding(.top, 8)
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 3)
            )
        }
        .buttonStyle(.plain)
    }
    
    // Check if there's manual written content
    private var hasManualContent: Bool {
        let trimmedContent = dream.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedContent.isEmpty { return false }
        
        // Check if content matches any transcript
        for memo in dream.audioMemos {
            if let transcript = memo.transcript, 
               trimmedContent == transcript.trimmingCharacters(in: .whitespacesAndNewlines) {
                return false
            }
        }
        return true
    }
    
    // Check if there are audio memos with transcripts
    private var hasAudioContent: Bool {
        return dream.audioMemos.contains { memo in
            memo.transcript?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        }
    }
    
    // Get background color based on content type
    private func getContentBackgroundColor() -> Color {
        if hasManualContent && hasAudioContent {
            // Mixed content - gradient-like color
            return Color.cyan.opacity(0.25)
        } else if hasManualContent {
            // Manual text only
            return Color.blue.opacity(0.25)
        } else if hasAudioContent {
            // Audio transcript only
            return Color.purple.opacity(0.25)
        } else {
            // Fallback
            return Color.gray.opacity(0.25)
        }
    }
}

//// 8. Tag Cloud Komponente
//struct TagCloud: View {
//    let tags: [String]
//    let dream: DreamEntry
//
//    
//    var body: some View {
//        FlowLayout(alignment: .leading, spacing: 8, data: dream.tags) {_ in
//            ForEach(tags, id: \.self) { tag in
//                Text(tag)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 6)
//                    .background(
//                        Capsule()
//                            .fill(Color.purple.opacity(0.2))
//                    )
//                    .overlay(
//                        Capsule()
//                            .stroke(Color.purple.opacity(0.5), lineWidth: 1)
//                    )
//            }
//        }
//    }
//}
