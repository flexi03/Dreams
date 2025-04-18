//
//  MoodPicker.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//


import SwiftUI

struct MoodPicker: View {
    @Binding var selectedMood: Mood
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Stimmung")
                .font(.headline)
                .padding(.bottom, 8)
            
            HStack {
                ForEach(Mood.allCases) { mood in
                    Button {
                        selectedMood = mood
                    } label: {
                        Text(mood.rawValue)
                            .font(.system(size: 32))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(selectedMood == mood ? Color.purple.opacity(0.2) : Color.clear)
                            )
                    }
                }
            }
        }
    }
}