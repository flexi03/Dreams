import SwiftUI

struct FlowLayout<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    init(
        alignment: HorizontalAlignment = .leading,
        spacing: CGFloat = 8,
        data: Data,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
            
            FlowLayoutHelper(
                data: data,
                spacing: spacing,
                alignment: alignment,
                content: content
            )
        }
    }
}

private struct FlowLayoutHelper<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State private var width: CGFloat = 0
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(row, id: \.self) {
                        content($0)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .readSize { size in
            width = size.width
        }
    }
    
    private func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = []
        var currentRow: [Data.Element] = []
        var currentWidth: CGFloat = 0
        
        for element in data {
            let elementSize = sizeFor(element: element)
            
            if currentWidth + elementSize.width > width {
                rows.append(currentRow)
                currentRow = []
                currentWidth = 0
            }
            
            currentRow.append(element)
            current