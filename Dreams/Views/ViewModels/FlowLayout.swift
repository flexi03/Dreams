//
//  FlowLayout.swift
//  Dreams
//
//  Created by Felix Kircher on 16.04.25.
//


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
        GeometryReader { geometry in
            VStack(alignment: alignment, spacing: spacing) {
                ForEach(computeRows(availableWidth: geometry.size.width), id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(row, id: \.self) {
                            content($0)
                        }
                        if alignment == .leading {
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: Alignment(horizontal: alignment, vertical: .top))
        }
        .frame(height: computeHeight())
    }
    
    private func computeRows(availableWidth: CGFloat) -> [[Data.Element]] {
        guard availableWidth > 0 else {
            return [Array(data)]
        }
        
        var rows: [[Data.Element]] = []
        var currentRow: [Data.Element] = []
        var currentWidth: CGFloat = 0
        
        for element in data {
            let elementSize = sizeFor(element: element)
            let spacingWidth = currentRow.isEmpty ? 0 : spacing
            let neededWidth = currentWidth + spacingWidth + elementSize.width
            
            if neededWidth > availableWidth && !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = [element]
                currentWidth = elementSize.width
            } else {
                currentRow.append(element)
                currentWidth = neededWidth
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private func computeHeight() -> CGFloat {
        let rows = computeRows(availableWidth: UIScreen.main.bounds.width)
        let rowHeight: CGFloat = 32 // Angenommene Höhe pro Zeile
        let totalSpacing = spacing * CGFloat(max(0, rows.count - 1))
        return CGFloat(rows.count) * rowHeight + totalSpacing
    }
    
    private func sizeFor(element: Data.Element) -> CGSize {
        // Vereinfachte Größenberechnung für bessere Performance
        let text = String(describing: element)
        let font = UIFont.systemFont(ofSize: 14) // Entspricht .subheadline
        let attributes = [NSAttributedString.Key.font: font]
        let textSize = (text as NSString).size(withAttributes: attributes)
        
        // Padding hinzufügen (horizontal: 12 + 12 = 24, vertical: 6 + 6 = 12)
        return CGSize(
            width: textSize.width + 24,
            height: textSize.height + 12
        )
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
