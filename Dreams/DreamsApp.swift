//
//  DreamsApp.swift
//  Dreams
//
//  Created by Felix Kircher on 04.04.25.
//

import SwiftUI

@main
struct DreamsApp: App {
    @AppStorage("isFirstStart") var isFirstStart: Bool = true
    @State private var isAnimating: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isFirstStart {
                    IntroductionView(isFirstStart: $isFirstStart)
                        .transition(.opacity.combined(with: .scale(scale: 1)))
//                        .preferredColorScheme(.dark)
                } else {
                    ContentView()
                        .transition(.opacity.combined(with: .scale(scale: 1)))
                        .preferredColorScheme(.dark)
                }
            }
            .withToasts()
            .preferredColorScheme(.dark)
            .animation(.easeInOut(duration: 0.8), value: isFirstStart)
        }
    }
}
