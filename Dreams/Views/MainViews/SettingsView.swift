//
//  SettingsView.swift
//  Dreams
//
//  Created by Felix Kircher on 17.04.25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isFirstStart") var isFirstStart: Bool = true
    var body: some View {
        Form {
            Section("LaunchScreen") {
                Button("LaunchScreen testen") {
                    isFirstStart.toggle()
                }
                .onChange(of: isFirstStart) {
                    withAnimation {
                        ToastManager.shared.showDebug("LaunchScreen wird angezeigt.", details: "isFirstStart: \(isFirstStart)")
                    }
                }
//                Toggle("LaunchScreen anzeigen", isOn: $isFirstStart)
//                    .onChange(of: isFirstStart) {
//                        withAnimation {
//                            // Animation wird ausgelöst
//                        }
//                    }
            }
            
            Section("Toasts aka Notifications") {
                NavigationLink(destination: ToastTesterView()) {
                    Text("Toast Tester View")
                }
            }
        }
//        .withToasts()
        .navigationTitle("Einstellungen")
    }
}

#Preview {
    SettingsView()
}
