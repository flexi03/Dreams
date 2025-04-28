//
//  Design.swift
//  Dreams
//
//  Created by Felix Kircher on 22.04.25.
//

import SwiftUI
// 3. Design Constants
struct Design {
    static let gradient = LinearGradient(
        colors: [.indigo, .purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [Color(.indigo.opacity(0.65)), Color(.systemGray5)],
        startPoint: .top,
        endPoint: .bottom
    )
}
