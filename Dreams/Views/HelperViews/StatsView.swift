//
//  StatsView.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//


import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: DreamStoreSampleData
    
    var body: some View {
        ScrollView {
            Text("Statistiken werden bald verfügbar sein!")
                .navigationTitle("Analysen")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Design.backgroundGradient)
    }

}
