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
    @State private var showDetail = false
    
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
            .contentShape(Rectangle()) // ← WICHTIG: damit der ganze HStack tappable wird
            .onTapGesture {
                showDetail = true
            }
            
            Text(dream.content)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .lineLimit(Int(isExpanded ? 100 : 3))
            
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
                .contentShape(Rectangle()) // ← WICHTIG: damit der ganze HStack tappable wird
                .onTapGesture {
                    showDetail = true
                }
            }
            
            
            HStack {
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }
        }
        .contentShape(Rectangle()) // WICHTIG für korrekte Hit-Testing
//        .allowsHitTesting(true)   // Standard, aber zur Sicherheit
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .background(
            NavigationLink(value: dream, label: { EmptyView() })
            .hidden() // ← Optional, damit es keine Lücken im Layout gibt
        )
        .navigationDestination(isPresented: $showDetail) {
            DreamDetailView(dream: dream)
                .background(Design.backgroundGradient)
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
