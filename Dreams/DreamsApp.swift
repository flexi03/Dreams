//
//  DreamsApp.swift
//  Dreams
//
//  Created by Felix Kircher on 04.04.25.
//

import SwiftUI
import ActivityKit

@main
struct DreamsApp: App {
    @AppStorage("isFirstStart") var isFirstStart: Bool = true
    @AppStorage("liveActivityAutoStart") var liveActivityAutoStart: Bool = true
    @State private var isAnimating: Bool = false
    @StateObject private var activityManager = DreamActivityManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isFirstStart {
                    IntroductionView(isFirstStart: $isFirstStart)
                        .transition(.opacity.combined(with: .scale(scale: 1)))
                        .environmentObject(activityManager)
                } else {
                    ContentView()
                        .transition(.opacity.combined(with: .scale(scale: 1)))
                        .preferredColorScheme(.dark)
                        .environmentObject(activityManager)
                        .onAppear {
                            setupLiveActivity()
                        }
                }
            }
            .onOpenURL { url in
                if url.scheme == "dreams" {
                    // Handle Deep Link - z.B. Navigation zu Add Dream View
                    print("App geöffnet via Deep Link: \(url)")
                    
                    // LiveActivity bei Deep Link aktualisieren
                    activityManager.updateActivityWithRealData()
                }
            }
            .withToasts()
            .preferredColorScheme(.dark)
            .animation(.easeInOut(duration: 0.8), value: isFirstStart)
        }
    }
    
    private func setupLiveActivity() {
        // Auto-Start nur wenn aktiviert und nicht bereits aktiv
        if liveActivityAutoStart && !activityManager.isActive {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                activityManager.startActivityWithRealData()
            }
        }
        
        // Bestehende Activities prüfen und Toast anzeigen
        if activityManager.isActive {
            ToastManager.shared.showInfo("LiveActivity bereits aktiv", details: "Dreams Widget läuft im Hintergrund")
        }
    }
}
