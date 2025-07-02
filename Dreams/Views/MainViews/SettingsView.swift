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
    @AppStorage("isDebugMode") var isDebugMode: Bool = false
    @AppStorage("dreamPassUserName") var dreamPassUserName: String = ""
    @EnvironmentObject private var store: DreamStoreSampleData
    @StateObject private var activityManager = DreamActivityManager()
    
    var body: some View {
        Form {
            Section("Personalisierung") {
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Dein Name", text: $dreamPassUserName)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.secondary)
                }
                
                NavigationLink(destination: DreamPassView()) {
                    HStack {
                        Image(systemName: "creditcard")
                            .foregroundColor(.purple)
                        Text("Dream Pass")
                        Spacer()
                        if !dreamPassUserName.isEmpty {
                            Text(dreamPassUserName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section("App-Einstellungen") {
                Toggle("Debug-Modus", isOn: $isDebugMode)
                    .onChange(of: isDebugMode) {
                        ToastManager.shared.showInfo("Debug-Modus \(isDebugMode ? "aktiviert" : "deaktiviert")", details: isDebugMode ? "Erweiterte Funktionen verfügbar • Debug-Toasts werden angezeigt" : "Standard-Modus aktiv • Debug-Toasts ausgeblendet")
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
                
                Toggle("Auto-Start", isOn: $activityManager.autoStartEnabled)
                    .onChange(of: activityManager.autoStartEnabled) {
                        if activityManager.autoStartEnabled && !activityManager.isActive {
                            activityManager.startActivityWithRealData()
                        }
                        ToastManager.shared.showInfo("LiveActivity Auto-Start \(activityManager.autoStartEnabled ? "aktiviert" : "deaktiviert")", details: activityManager.autoStartEnabled ? "Wird automatisch beim App-Start gestartet" : "Manueller Start erforderlich")
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
                
                NavigationLink(destination: LiveActivityDebugView()) {
                    HStack {
                        Image(systemName: "ladybug")
                        Text("LiveActivity Debug")
                    }
                }
                
                if isDebugMode {
                    NavigationLink(destination: AppDebugView()) {
                        HStack {
                            Image(systemName: "gearshape.2")
                            Text("Erweiterte Debug-Funktionen")
                        }
                    }
                }
            }
            
            Section("App-Version") {
                HStack {
                    Text("Version:")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unbekannt")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build:")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unbekannt")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Bundle ID:")
                    Spacer()
                    Text(Bundle.main.bundleIdentifier ?? "Unbekannt")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                HStack {
                    Text("iOS Version:")
                    Spacer()
                    Text(UIDevice.current.systemVersion)
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Gerät:")
                    Spacer()
                    Text(UIDevice.current.model)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if isDebugMode {
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
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            // Store setzen ohne Auto-Start (vermeidet ungewollten Start in Settings)
            activityManager.setStore(store, shouldAutoStart: false)
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
            
            Section("Erweiterte System-Informationen") {
                HStack {
                    Text("Prozessor:")
                    Spacer()
                    Text(ProcessInfo.processInfo.processorCount > 1 ? "\(ProcessInfo.processInfo.processorCount) Kerne" : "1 Kern")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Speicher:")
                    Spacer()
                    Text(ByteCountFormatter.string(fromByteCount: Int64(ProcessInfo.processInfo.physicalMemory), countStyle: .memory))
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Systemname:")
                    Spacer()
                    Text(UIDevice.current.systemName)
                        .font(.caption)
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
        .toolbar(.hidden, for: .tabBar)
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
        .environmentObject(DreamActivityManager())
        .environmentObject(DreamStoreSampleData())
        .preferredColorScheme(.dark)
}
