// 6. DreamCard-Komponente mit Animation
struct DreamCard: View {
    let dream: DreamEntry
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dream.mood.rawValue)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading) {
                    Text(dream.title)
                        .font(.headline)
                    
                    Text(dream.date.formatted(date: .numeric, time: .omitted))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                SleepQualityIndicator(quality: dream.sleepQuality)
            }
            
            if isExpanded {
                Text(dream.content)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                
                TagCloud(tags: dream.tags)
                    .padding(.top, 8)
            }
            
            HStack {
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .onTapGesture {
            withAnimation(.easeInOut) {
                isExpanded.toggle()
            }
        }
    }
}