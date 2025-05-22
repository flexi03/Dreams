//
//  GitGrid.swift
//  Dreams
//
//  Created by Felix Kircher on 22.05.25.
//

import SwiftUI

private struct IdentifiableDate: Identifiable {
    var id: Date { date }
    let date: Date
}

struct GitGrid: View {
    
    @EnvironmentObject private var store: DreamStoreSampleData
    @State private var selectedDate: IdentifiableDate? = nil
    
    var body: some View {
        LazyHGrid(rows: Array(repeating: GridItem(.fixed(16), spacing: 6), count: 7), spacing: 6) {
            ForEach(0..<98, id: \.self) { index in
                let date = Calendar.current.date(byAdding: .day, value: -index, to: Date())!
                let count = groupedEntriesByDate[Calendar.current.startOfDay(for: date)]?.count ?? 0
                Rectangle()
                    .fill(color(for: count))
                    .frame(width: 18, height: 18)
                    .cornerRadius(5)
                    .onTapGesture {
                        selectedDate = IdentifiableDate(date: Calendar.current.startOfDay(for: date))
                    }
                    .help("\(formattedDate(date)): \(count) Eintrag(e)")
            }
        }
        .padding()
        //            .frame(maxWidth: 320, maxHeight: 200)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
            
        }
        //            .padding(.horizontal)
        .sheet(item: $selectedDate) { identifiable in
            let date = identifiable.date
            VStack(alignment: .leading, spacing: 10) {
                Text(formattedDate(date))
                    .font(.headline)
                let entries = groupedEntriesByDate[date] ?? []
                Text("\(entries.count) Eintrag(e)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ForEach(entries.prefix(5), id: \.id) { entry in
                    Text("• \(entry.title)")
                        .font(.body)
                }

                if entries.count > 5 {
                    Text("… und \(entries.count - 5) weitere")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding()
            .presentationDetents([.medium])
        }

    }
        
    
    
    private var groupedEntriesByDate: [Date: [DreamEntry]] {
        Dictionary(grouping: store.dreams) { dream in
            Calendar.current.startOfDay(for: dream.date)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func color(for count: Int) -> Color {
        switch count {
        case 0: return Color.gray.opacity(0.1)
        case 1: return Color.green.opacity(0.4)
        case 2...3: return Color.green.opacity(0.7)
        default: return Color.green
        }
    }
}
