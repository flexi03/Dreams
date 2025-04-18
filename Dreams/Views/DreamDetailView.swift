struct DreamDetailView: View {
    let dream: DreamEntry
    // Mock für KI-Analyse
    let keywords = ["Wasser", "Flug", "Unbekannte Person"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(dream.mood)
                        .font(.system(size: 40))
                    Text(dream.date, style: .date)
                        .foregroundStyle(.gray)
                }
                
                VStack(alignment: .leading) {
                    Text("Tags")
                        .font(.headline)
                    HStack {
                        ForEach(dream.tags, id: \.self) { tag in
                            Text(tag)
                                .padding(5)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Inhalt")
                        .font(.headline)
                    Text(dream.content)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading) {
                    Text("KI-Analyse")
                        .font(.headline)
                    Text("Wiederkehrende Themen: \(keywords.joined(separator: ", "))")
                        .italic()
                }
            }
            .padding()
        }
        .navigationTitle(dream.title)
    }
}