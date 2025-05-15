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
            Text("Einstellungen")
            Toggle("LaunchScreen anzeigen", isOn: $isFirstStart)
                .onChange(of: isFirstStart) { _ in
                    withAnimation {
                        // Animation wird ausgelöst
                    }
                }
        }
        .navigationTitle("Einstellungen")
    }
}

#Preview {
    SettingsView()
}
