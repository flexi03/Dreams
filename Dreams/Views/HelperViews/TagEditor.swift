//
//  TagEditor.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//


import SwiftUI

struct TagEditor: View {
    @Binding var tags: [String]
    @State private var newTag = ""
//    @Binding var selectedTags: [String]
    
    let suggestions = ["Albtraum", "Luzid", "Wiederkehrend", "Prophetisch", "Kreativ"]
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Neuer Tag", text: $newTag)
                .onSubmit(addTag)
            
            HStack {
                ForEach(tags.indices, id: \.self) { tag in
                    Button {
                        
                    } label: {
                        Text(suggestions.first ?? "")
                            .padding(6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .contentShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
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
