//
//  SwipeToDeleteCard.swift
//  Dreams
//
//  Created by Felix Kircher on 17.04.25.
//

import SwiftUI

struct SwipeableCard: View {
    let dream: DreamEntry
    let onDelete: () -> Void
    let onPin: () -> Void // Neue Aktion
    
    @State private var offsetX: CGFloat = 0
    @GestureState private var isDragging = false

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // Pin Hintergrund (links)
                Color.blue
                    .cornerRadius(16)
                    .overlay(
                        Image(systemName: dream.isPinned ? "pin.slash.fill" : "pin.fill")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding(.leading, 24)
                    )
                    .frame(width: max(offsetX, 0))
                    .clipped()
                
                Spacer()
                
                // Delete Hintergrund (rechts)
                Color.red
                    .cornerRadius(16)
                    .overlay(
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding(.trailing, 24)
                    )
                    .frame(width: max(-offsetX, 0))
                    .clipped()
            }
            
            // DreamCard
            DreamCard(dream: dream)
                .background(.background)
                .cornerRadius(16)
                .offset(x: offsetX)
                .gesture(
                    DragGesture()
                        .updating($isDragging) { _, state, _ in
                            state = true
                        }
                        .onChanged { value in
                            offsetX = value.translation.width
                        }
                        .onEnded { value in
                            if value.translation.width < -100 {
                                withAnimation {
                                    onDelete()
                                }
                            } else if value.translation.width > 100 {
                                withAnimation {
                                    onPin()
                                    offsetX = 0
                                }
                            } else {
                                withAnimation {
                                    offsetX = 0
                                }
                            }
                        }
                )
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: offsetX)
    }
}
