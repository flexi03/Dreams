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
    
    let suggestions = ["Albtraum", "Luzid", "Wiederkehrend", "Prophetisch", "Kreativ"]
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Neuer Tag", text: $newTag)
                .onSubmit(addTag)
            
            // Existing tags
            if !tags.isEmpty {
                Text("Deine Tags:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Button {
                            removeTag(tag)
                        } label: {
                            HStack(spacing: 4) {
                                Text(tag)
                                Spacer()
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.purple.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Suggestion tags
            Text("Vorschläge:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        addSuggestion(suggestion)
                    } label: {
                        HStack {
                            Text(suggestion)
                            Spacer()
                            if tags.contains(suggestion) {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            tags.contains(suggestion) ? 
                            Color.purple.opacity(0.3) : 
                            Color.gray.opacity(0.2)
                        )
                        .animation(.easeInOut(duration: 0.2), value: tags)
                        .foregroundColor(
                            tags.contains(suggestion) ? 
                            .primary : 
                            .secondary
                        )
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .disabled(tags.contains(suggestion))
                }
            }
        }
    }
    
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespaces)
        guard !trimmedTag.isEmpty, !tags.contains(trimmedTag) else { return }
        tags.append(trimmedTag)
        newTag = ""
    }
    
    private func addSuggestion(_ suggestion: String) {
        guard !tags.contains(suggestion) else { return }
        tags.append(suggestion)
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}
