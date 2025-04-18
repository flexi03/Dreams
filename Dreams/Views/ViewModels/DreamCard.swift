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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dream.mood.rawValue)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading) {
                    Text(dream.title)
                        .font(.headline)
                    
                    Text(dream.date.formatted(date: .numeric, time: .omitted))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                SleepQualityIndicator(quality: dream.sleepQuality)
            }
            
            
            if isExpanded {
                Text(dream.content)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                
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
                .padding(.top, 8)
            }
            
            HStack {
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .onTapGesture {
            withAnimation(.easeInOut) {
                isExpanded.toggle()
            }
        }
    }
}

// 8. Tag Cloud Komponente
struct TagCloud: View {
    let tags: [String]
    let dream: DreamEntry

    
    var body: some View {
        FlowLayout(alignment: .leading, spacing: 8, data: dream.tags) {_ in
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.purple.opacity(0.2))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                    )
            }
        }
    }
}
