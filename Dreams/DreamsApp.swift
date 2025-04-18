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
    var body: some Scene {
        WindowGroup {
            if isFirstStart {
                IntroductionView(isFirstStart: $isFirstStart)
            } else {
                ContentView()
            }
        }
    }
}
