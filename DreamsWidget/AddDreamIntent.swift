//
//  AddDreamIntent.swift
//  Dreams
//
//  Created by Felix Kircher on 08.06.25.
//

// AddDreamIntent.swift
// Target Membership: ✅ Dreams ✅ DreamsWidgetExtension

import AppIntents
import ActivityKit

// MARK: - App Intent
struct AddDreamIntent: AppIntent {
    static var title: LocalizedStringResource = "Neuen Traum hinzufügen"
    static var description = IntentDescription("Öffnet die Dreams App um einen neuen Traum hinzuzufügen")
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult {
        // openAppWhenRun: true öffnet automatisch die App
        return .result()
    }
}

// MARK: - Activity Attributes (muss auch geteilt werden)
struct DreamActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentStreak: Int
        var todaysDreamCount: Int
        var dailyGoal: Int
        var lastDreamTitle: String?
    }
    
    var appName: String = "Dreams"
}
