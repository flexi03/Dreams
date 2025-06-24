//
//  SettingsView.swift
//  Dreams
//
//  Created by Felix Kircher on 17.04.25.
//

import SwiftUI
import ActivityKit

struct SettingsView: View {
    @AppStorage("isFirstStart") var isFirstStart: Bool = true
    @AppStorage("liveActivityAutoStart") var liveActivityAutoStart: Bool = true
    @AppStorage("debugModeEnabled") var debugModeEnabled: Bool = false
    @EnvironmentObject private var store: DreamStoreSampleData
    @StateObject private var activityManager = DreamActivityManager()
    
    var body: some View {
        Form {
            Section("App-Einstellungen") {
                Toggle("Debug-Modus", isOn: $debugModeEnabled)
                    .onChange(of: debugModeEnabled) {
                        ToastManager.shared.showInfo("Debug-Modus \(debugModeEnabled ? "aktiviert" : "deaktiviert")", details: debugModeEnabled ? "Erweiterte Funktionen verfügbar" : "Standard-Modus aktiv")
                    }
                
                Button("LaunchScreen testen") {
                    isFirstStart.toggle()
                }
                .onChange(of: isFirstStart) {
                    withAnimation {
                        ToastManager.shared.showDebug("LaunchScreen wird angezeigt.", details: "isFirstStart: \(isFirstStart)")
                    }
                }
            }
            
            Section("LiveActivity") {
                HStack {
                    Text("Status:")
                    Spacer()
                    Text(activityManager.isActive ? "🟢 Aktiv" : "🔴 Inaktiv")
                        .foregroundColor(activityManager.isActive ? .green : .red)
                }
                
                Toggle("Auto-Start", isOn: $liveActivityAutoStart)
                    .onChange(of: liveActivityAutoStart) {
                        activityManager.autoStartEnabled = liveActivityAutoStart
                        if liveActivityAutoStart && !activityManager.isActive {
                            activityManager.startActivityWithRealData()
                        }
                        ToastManager.shared.showInfo("LiveActivity Auto-Start \(liveActivityAutoStart ? "aktiviert" : "deaktiviert")", details: liveActivityAutoStart ? "Wird automatisch beim App-Start gestartet" : "Manueller Start erforderlich")
                    }
                
                HStack {
                    Text("Tägliches Ziel:")
                    Spacer()
                    Stepper("\(activityManager.dailyGoal)", value: $activityManager.dailyGoal, in: 1...10)
                        .onChange(of: activityManager.dailyGoal) {
                            if activityManager.isActive {
                                activityManager.updateActivityWithRealData()
                                ToastManager.shared.showInfo("Ziel aktualisiert", details: "Neues Tagesziel: \(activityManager.dailyGoal) Träume")
                            }
                        }
                }
                
                Button(action: {
                    if activityManager.isActive {
                        activityManager.endAllActivities()
                    } else {
                        activityManager.startActivityWithRealData()
                    }
                }) {
                    HStack {
                        Image(systemName: activityManager.isActive ? "stop.circle.fill" : "play.circle.fill")
                        Text(activityManager.isActive ? "LiveActivity stoppen" : "LiveActivity starten")
                    }
                }
                .foregroundColor(activityManager.isActive ? .red : .green)
            }
            
            Section("Debug & Testing") {
                NavigationLink(destination: ToastTesterView()) {
                    HStack {
                        Image(systemName: "bell.badge")
                        Text("Toast Tester")
                    }
                }
                
                NavigationLink(destination: DebugView()) {
                    HStack {
                        Image(systemName: "ladybug")
                        Text("LiveActivity Debug")
                    }
                }
                
                if debugModeEnabled {
                    NavigationLink(destination: AppDebugView()) {
                        HStack {
                            Image(systemName: "gearshape.2")
                            Text("Erweiterte Debug-Funktionen")
                        }
                    }
                }
            }
            
            if debugModeEnabled {
                Section("App-Informationen") {
                    HStack {
                        Text("Gesamte Träume:")
                        Spacer()
                        Text("\(store.dreams.count)")
                            .font(.caption.monospacedDigit())
                    }
                    
                    HStack {
                        Text("LiveActivities berechtigt:")
                        Spacer()
                        let authInfo = ActivityAuthorizationInfo()
                        Text(authInfo.areActivitiesEnabled ? "✅ Ja" : "❌ Nein")
                            .foregroundColor(authInfo.areActivitiesEnabled ? .green : .red)
                    }
                    
                    Button("Schnell-Toast senden") {
                        ToastManager.shared.showSuccess("Test Toast", details: "Gesendet um \(Date().formatted(date: .omitted, time: .complete))")
                    }
                    
                    Button("UserDefaults zurücksetzen") {
                        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                        ToastManager.shared.showInfo("UserDefaults zurückgesetzt", details: "App-Einstellungen wurden auf Standard zurückgesetzt")
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .navigationTitle("Einstellungen")
        .onAppear {
            activityManager.setStore(store)
            activityManager.autoStartEnabled = liveActivityAutoStart
        }
    }
}

struct AppDebugView: View {
    @EnvironmentObject private var store: DreamStoreSampleData
    @State private var showingClearAlert = false
    
    var body: some View {
        Form {
            Section("Daten-Management") {
                HStack {
                    Text("Träume im Speicher:")
                    Spacer()
                    Text("\(store.dreams.count)")
                        .font(.caption.monospacedDigit())
                }
                
                Button("Sample-Daten hinzufügen") {
                    store.addSampleData()
                    ToastManager.shared.showSuccess("Sample-Daten hinzugefügt", details: "\(store.dreams.count) Träume im Speicher")
                }
                
                Button("Alle Daten löschen", role: .destructive) {
                    showingClearAlert = true
                }
            }
            
            Section("System-Informationen") {
                HStack {
                    Text("iOS Version:")
                    Spacer()
                    Text(UIDevice.current.systemVersion)
                        .font(.caption.monospacedDigit())
                }
                
                HStack {
                    Text("Device Model:")
                    Spacer()
                    Text(UIDevice.current.model)
                        .font(.caption)
                }
                
                HStack {
                    Text("Bundle ID:")
                    Spacer()
                    Text(Bundle.main.bundleIdentifier ?? "Unknown")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Debug-Aktionen") {
                Button("Alle Toast-Typen testen") {
                    testAllToasts()
                }
                
                Button("Memory Warning simulieren") {
                    UIApplication.shared.perform(Selector(("_performMemoryWarning")))
                    ToastManager.shared.showDebug("Memory Warning", details: "Simuliert für Debug-Zwecke")
                }
                
                Button("Crash-Log erstellen") {
                    ToastManager.shared.showError("Crash-Test", details: "Dies ist ein Test-Crash-Log für Debug-Zwecke")
                }
            }
        }
        .navigationTitle("App Debug")
        .alert("Alle Daten löschen?", isPresented: $showingClearAlert) {
            Button("Löschen", role: .destructive) {
                store.dreams.removeAll()
                ToastManager.shared.showInfo("Daten gelöscht", details: "Alle Träume wurden entfernt")
            }
            Button("Abbrechen", role: .cancel) { }
        } message: {
            Text("Diese Aktion kann nicht rückgängig gemacht werden.")
        }
    }
    
    private func testAllToasts() {
        DispatchQueue.main.async {
            ToastManager.shared.showSuccess("Success Toast", details: "Das ist ein Erfolgs-Toast")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ToastManager.shared.showError("Error Toast", details: "Das ist ein Fehler-Toast")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ToastManager.shared.showInfo("Info Toast", details: "Das ist ein Info-Toast")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            ToastManager.shared.showDebug("Debug Toast", details: "Das ist ein Debug-Toast mit vielen Details und zusätzlichen Informationen")
        }
    }
}

#Preview {
    SettingsView()
}
