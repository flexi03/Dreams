import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: DreamStore
    
    var body: some View {
        Text("Statistiken werden bald verfügbar sein!")
            .navigationTitle("Analysen")
    }
}