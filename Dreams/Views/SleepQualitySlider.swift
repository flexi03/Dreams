import SwiftUI

struct SleepQualitySlider: View {
    @Binding var value: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Schlafqualität")
                .font(.headline)
            
            HStack {
                ForEach(1...5, id: \.self) { index in
                    Button {
                        value = index
                    } label: {
                        Image(systemName: index <= value ? "moon.fill" : "moon")
                            .foregroundColor(index <= value ? .purple : .gray)
                            .font(.system(size: 20))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}