import SwiftUI

struct SleepQualityIndicator: View {
    let quality: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= quality ? "moon.fill" : "moon")
                    .foregroundColor(index <= quality ? .purple : .gray)
            }
        }
    }
}