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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text("Aktivität der letzten Wochen")
                    .font(.headline)
                    .padding()
                
                GitGrid()
                
                Spacer()
            }
            .navigationTitle("Statistiken")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Design.backgroundGradient)
            
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

