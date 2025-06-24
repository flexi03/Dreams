//
//  DreamActivityManager.swift
//  Dreams
//
//  Created by Felix Kircher on 08.06.25.
//

import SwiftUI
import ActivityKit

@MainActor
class DreamActivityManager: ObservableObject {
    @Published var isActive = false
    @Published var errorMessage = ""
    @Published var autoStartEnabled = true
    @Published var dailyGoal = 3
    
    private var store: DreamStoreSampleData?
    
    init() {
        checkExistingActivities()
    }
    
    func setStore(_ store: DreamStoreSampleData) {
        self.store = store
        if autoStartEnabled && !isActive {
            startActivityWithRealData()
        }
    }
    
    private func checkExistingActivities() {
        let existingActivities = Activity<DreamActivityAttributes>.activities
        isActive = !existingActivities.isEmpty
        
        if isActive {
            ToastManager.shared.showInfo("LiveActivity aktiv", details: "\(existingActivities.count) aktive LiveActivity(s) gefunden")
        }
    }
    
    func startActivityWithRealData() {
        guard let store = store else {
            ToastManager.shared.showError("Fehler", details: "Store nicht verfügbar")
            return
        }
        
        let authInfo = ActivityAuthorizationInfo()
        print("Live Activities enabled: \(authInfo.areActivitiesEnabled)")
        
        guard authInfo.areActivitiesEnabled else {
            errorMessage = "Live Activities sind in den Einstellungen deaktiviert"
            ToastManager.shared.showError("LiveActivity Fehler", details: errorMessage)
            return
        }
        
        // Berechne echte Daten
        let streak = calculateDreamStreak(dreams: store.dreams)
        let todayCount = getTodaysDreamCount(dreams: store.dreams)
        let lastDream = store.dreams.sorted { $0.date > $1.date }.first
        
        let attributes = DreamActivityAttributes()
        let initialState = DreamActivityAttributes.ContentState(
            currentStreak: streak,
            todaysDreamCount: todayCount,
            dailyGoal: dailyGoal,
            lastDreamTitle: lastDream?.title
        )
        
        do {
            let activity = try Activity<DreamActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: initialState, staleDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())),
                pushType: nil
            )
            print("✅ Live Activity gestartet: \(activity.id)")
            isActive = true
            errorMessage = ""
            ToastManager.shared.showSuccess("LiveActivity gestartet", details: "Streak: \(streak) | Heute: \(todayCount)/\(dailyGoal)")
        } catch {
            print("❌ Fehler beim Starten: \(error)")
            errorMessage = "Fehler: \(error.localizedDescription)"
            ToastManager.shared.showError("LiveActivity Fehler", details: errorMessage)
        }
    }
    
    func updateActivityWithRealData() {
        guard let store = store else { return }
        
        Task {
            let streak = calculateDreamStreak(dreams: store.dreams)
            let todayCount = getTodaysDreamCount(dreams: store.dreams)
            let lastDream = store.dreams.sorted { $0.date > $1.date }.first
            
            let newState = DreamActivityAttributes.ContentState(
                currentStreak: streak,
                todaysDreamCount: todayCount,
                dailyGoal: dailyGoal,
                lastDreamTitle: lastDream?.title
            )
            
            for activity in Activity<DreamActivityAttributes>.activities {
                await activity.update(ActivityContent(
                    state: newState, 
                    staleDate: Calendar.current.date(byAdding: .hour, value: 8, to: Date())
                ))
                print("✅ Activity aktualisiert - Streak: \(streak), Heute: \(todayCount)")
            }
            
            await MainActor.run {
                ToastManager.shared.showInfo("LiveActivity aktualisiert", details: "Streak: \(streak) | Heute: \(todayCount)/\(dailyGoal)")
            }
        }
    }
    
    func endAllActivities() {
        Task {
            let activeCount = Activity<DreamActivityAttributes>.activities.count
            for activity in Activity<DreamActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            await MainActor.run {
                isActive = false
                ToastManager.shared.showInfo("LiveActivity beendet", details: "\(activeCount) Activity(s) beendet")
            }
        }
    }
    
    func restartActivity() {
        endAllActivities()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.startActivityWithRealData()
        }
    }
    
    private func calculateDreamStreak(dreams: [DreamEntry]) -> Int {
        let sortedDreams = dreams.sorted { $0.date > $1.date }
        guard !sortedDreams.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        for dream in sortedDreams {
            let dreamDate = Calendar.current.startOfDay(for: dream.date)
            if dreamDate == currentDate {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if dreamDate == Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
                streak += 1
                currentDate = dreamDate
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        return streak
    }
    
    private func getTodaysDreamCount(dreams: [DreamEntry]) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        return dreams.filter { dream in
            dream.date >= today && dream.date < tomorrow
        }.count
    }
    
    // Legacy-Methoden für Debugging
    func startActivity() {
        startActivityWithRealData()
    }
    
    func updateActivity() {
        updateActivityWithRealData()
    }
    
    func endActivity() {
        endAllActivities()
    }
}

// Enhanced Debug View
struct DebugView: View {
    @StateObject private var manager = DreamActivityManager()
    @EnvironmentObject private var store: DreamStoreSampleData
    
    var body: some View {
        Form {
            Section("LiveActivity Status") {
                HStack {
                    Text("Status:")
                    Spacer()
                    Text(manager.isActive ? "🟢 Aktiv" : "🔴 Inaktiv")
                        .foregroundColor(manager.isActive ? .green : .red)
                }
                
                if !manager.errorMessage.isEmpty {
                    Text(manager.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                HStack {
                    Text("Aktive Activities:")
                    Spacer()
                    Text("\(Activity<DreamActivityAttributes>.activities.count)")
                        .font(.caption.monospacedDigit())
                }
            }
            
            Section("Steuerung") {
                Button(action: {
                    manager.startActivityWithRealData()
                }) {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("LiveActivity starten")
                        Spacer()
                    }
                }
                .disabled(manager.isActive)
                
                Button(action: {
                    manager.updateActivityWithRealData()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                        Text("Activity aktualisieren")
                        Spacer()
                    }
                }
                .disabled(!manager.isActive)
                
                Button(action: {
                    manager.restartActivity()
                }) {
                    HStack {
                        Image(systemName: "gobackward.circle.fill")
                        Text("Activity neustarten")
                        Spacer()
                    }
                }
                .disabled(!manager.isActive)
                
                Button(role: .destructive, action: {
                    manager.endAllActivities()
                }) {
                    HStack {
                        Image(systemName: "stop.circle.fill")
                        Text("Alle Activities beenden")
                        Spacer()
                    }
                }
                .disabled(!manager.isActive)
            }
            
            Section("Einstellungen") {
                Toggle("Auto-Start aktiviert", isOn: $manager.autoStartEnabled)
                    .onChange(of: manager.autoStartEnabled) {
                        if manager.autoStartEnabled && !manager.isActive {
                            ToastManager.shared.showInfo("Auto-Start aktiviert", details: "LiveActivity wird beim nächsten App-Start automatisch gestartet")
                        }
                    }
                
                HStack {
                    Text("Tägliches Ziel:")
                    Spacer()
                    Stepper("\(manager.dailyGoal)", value: $manager.dailyGoal, in: 1...10)
                        .onChange(of: manager.dailyGoal) {
                            if manager.isActive {
                                manager.updateActivityWithRealData()
                            }
                        }
                }
            }
            
            Section("Aktuelle Daten") {
                let currentStreak = manager.calculateDreamStreakPublic(dreams: store.dreams)
                let todayCount = manager.getTodaysDreamCountPublic(dreams: store.dreams)
                let lastDream = store.dreams.sorted { $0.date > $1.date }.first
                
                HStack {
                    Text("Aktueller Streak:")
                    Spacer()
                    Text("\(currentStreak) Tage")
                        .font(.caption.monospacedDigit())
                }
                
                HStack {
                    Text("Träume heute:")
                    Spacer()
                    Text("\(todayCount)/\(manager.dailyGoal)")
                        .font(.caption.monospacedDigit())
                }
                
                if let lastDream = lastDream {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Letzter Traum:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(lastDream.title)
                            .font(.subheadline)
                        Text(lastDream.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button("Test-Daten aktualisieren") {
                    manager.updateActivityWithRealData()
                }
                .disabled(!manager.isActive)
            }
            
            Section("Debug Info") {
                let authInfo = ActivityAuthorizationInfo()
                
                HStack {
                    Text("Activities berechtigt:")
                    Spacer()
                    Text(authInfo.areActivitiesEnabled ? "✅ Ja" : "❌ Nein")
                        .foregroundColor(authInfo.areActivitiesEnabled ? .green : .red)
                }
                
                HStack {
                    Text("Gesamte Träume:")
                    Spacer()
                    Text("\(store.dreams.count)")
                        .font(.caption.monospacedDigit())
                }
                
                Button("Debug-Toast senden") {
                    ToastManager.shared.showDebug("LiveActivity Debug", details: "Aktiv: \(manager.isActive) | Streak: \(manager.calculateDreamStreakPublic(dreams: store.dreams)) | Heute: \(manager.getTodaysDreamCountPublic(dreams: store.dreams))")
                }
            }
        }
        .navigationTitle("LiveActivity Debug")
        .onAppear {
            manager.setStore(store)
        }
    }
}

// Extension um private Methoden für Debug View zugänglich zu machen
extension DreamActivityManager {
    func calculateDreamStreakPublic(dreams: [DreamEntry]) -> Int {
        calculateDreamStreak(dreams: dreams)
    }
    
    func getTodaysDreamCountPublic(dreams: [DreamEntry]) -> Int {
        getTodaysDreamCount(dreams: dreams)
    }
}
