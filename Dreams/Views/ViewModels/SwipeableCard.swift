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
    let onPin: () -> Void
    
    @State private var offsetX: CGFloat = 0
    @GestureState private var isDragging = false

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                pinBackground
                Spacer()
                deleteBackground
            }
            
            NavigationLink(value: dream) {
                DreamCard(dream: dream)
            }
            .buttonStyle(PlainButtonStyle())
            .background(.background)
            .cornerRadius(16)
            .offset(x: offsetX)
            .gesture(dragGesture)
        }
        .padding(.horizontal)
        .animation(.interactiveSpring(), value: offsetX)
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .onChanged { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                
                if abs(horizontal) > abs(vertical) * 2 {
                    offsetX = horizontal
                }
            }
            .onEnded { value in
                let translation = value.translation.width
                let velocity = value.velocity.width
                
                if translation < -100 || velocity < -500 {
                    onDelete()
                } else if translation > 100 || velocity > 500 {
                    onPin()
                    offsetX = 0
                } else {
                    withAnimation(.spring()) {
                        offsetX = 0
                    }
                }
            }
    }
    
    private var pinBackground: some View {
        Color.blue
            .cornerRadius(16)
            .overlay(
                Image(systemName: dream.isPinned ? "pin.slash.fill" : "pin.fill")
                    .foregroundColor(.white)
                    .font(.title)
                    .padding(.leading, 24)
            )
            .frame(width: max(offsetX, 0))
    }
    
    private var deleteBackground: some View {
        Color.red
            .cornerRadius(16)
            .overlay(
                Image(systemName: "trash")
                    .foregroundColor(.white)
                    .font(.title)
                    .padding(.trailing, 24)
            )
            .frame(width: max(-offsetX, 0))
    }
}
