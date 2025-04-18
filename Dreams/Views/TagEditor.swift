import SwiftUI

struct TagEditor: View {
    @Binding var tags: [String]
    @State private var newTag = ""
    
    let suggestions = ["Albtraum", "Luzid", "Wiederkehrend", "Prophetisch", "Kreativ"]
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Neuer Tag", text: $newTag)
                .onSubmit(addTag)
            
            FlowLayout(alignment: .leading, spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        if !tags.contains(suggestion) {
                            tags.append(suggestion)
                        }
                    } label: {
                        Text(suggestion)
                            .padding(6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespaces)
        guard !trimmedTag.isEmpty else { return }
        tags.append(trimmedTag)
        newTag = ""
    }
}