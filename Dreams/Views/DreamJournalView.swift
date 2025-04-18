// 5. Verbessertes Journal-View mit Swipe-Actions
struct DreamJournalView: View {
    @EnvironmentObject private var store: DreamStore
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(store.dreams) { dream in
                        DreamCard(dream: dream)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteDream(dream)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding()
            }
            .background(Design.backgroundGradient)
            .navigationTitle("Traumtagebuch")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        AddDreamView()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title)
                    }
                }
            }
        }
    }
    
    private func deleteDream(_ dream: DreamEntry) {
        withAnimation(.spring) {
            store.dreams.removeAll { $0.id == dream.id }
        }
    }
}