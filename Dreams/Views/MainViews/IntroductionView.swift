//
//  IntroductionView.swift
//  Dreams
//
//  Created by Felix Kircher on 04.04.25.
//

import SwiftUI

struct IntroductionView: View {
    @Binding var isFirstStart: Bool
    var body: some View {
        Text("First Start of Dreams!")
        Button("Start") {
            isFirstStart.toggle()
            print(isFirstStart)
        }
    }
}

#Preview {
    IntroductionView(isFirstStart: .constant(true))
}
