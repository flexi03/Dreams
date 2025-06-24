//
//  DreamLiveActivity.swift
//  Dreams
//
//  Created by Felix Kircher on 08.06.25.
//


// DreamLiveActivity.swift - NUR im Widget Extension Target
import SwiftUI
import ActivityKit
import WidgetKit

// MARK: - Live Activity Widget
struct DreamLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DreamActivityAttributes.self) { context in
            // Lock Screen View
            DreamLockScreenView(
                streak: context.state.currentStreak,
                todayCount: context.state.todaysDreamCount,
                dailyGoal: context.state.dailyGoal,
                lastDreamTitle: context.state.lastDreamTitle
            )
            .activityBackgroundTint(Color.purple.opacity(0.1))
            .activitySystemActionForegroundColor(.purple)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "moon.stars.fill")
                            .foregroundColor(.purple)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(context.state.currentStreak)")
                                .font(.title2.bold())
                            Text("Tag Streak")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(spacing: 4) {
                        Text("Heute")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            Circle()
                                .stroke(Color.purple.opacity(0.3), lineWidth: 3)
                                .frame(width: 40, height: 40)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(context.state.todaysDreamCount) / CGFloat(context.state.dailyGoal))
                                .stroke(Color.purple, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(-90))
                            
                            Text("\(context.state.todaysDreamCount)")
                                .font(.caption.bold())
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Button(intent: AddDreamIntent()) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Neuer Traum")
                                    .font(.caption.bold())
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.purple)
                            .clipShape(Capsule())
                        }
                        
                        Spacer()
                        
                        if let lastTitle = context.state.lastDreamTitle {
                            VStack(alignment: .trailing) {
                                Text("Letzter Traum:")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(lastTitle)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                
            } compactLeading: {
                // Compact Leading (left side of notch)
                HStack(spacing: 4) {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(.purple)
                        .font(.caption)
                    Text("\(context.state.currentStreak)")
                        .font(.caption.bold())
                }
                
            } compactTrailing: {
                // Compact Trailing (right side of notch)
                ZStack {
                    Circle()
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 16, height: 16)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(context.state.todaysDreamCount) / CGFloat(context.state.dailyGoal))
                        .stroke(Color.purple, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                        .frame(width: 16, height: 16)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(context.state.todaysDreamCount)")
                        .font(.system(size: 7, weight: .bold))
                }
                
            } minimal: {
                // Minimal View (when multiple activities are active)
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(.purple)
                    .font(.caption)
            }
        }
    }
}

// MARK: - Lock Screen View
struct DreamLockScreenView: View {
    let streak: Int
    let todayCount: Int
    let dailyGoal: Int
    let lastDreamTitle: String?
    
    var body: some View {
        HStack {
            // Streak Section
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(streak)")
                        .font(.title2.bold())
                }
                Text("Tage Streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Progress Section
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color.purple.opacity(0.3), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: min(1.0, CGFloat(todayCount) / CGFloat(dailyGoal)))
                        .stroke(Color.purple, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: todayCount)
                    
                    Text("\(todayCount)")
                        .font(.headline.bold())
                }
                
                Text("von \(dailyGoal) heute")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Quick Action Button
            Button(intent: AddDreamIntent()) {
                VStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                    Text("Hinzufügen")
                        .font(.caption2)
                }
            }
        }
        .padding()
    }
}

// MARK: - Widget Bundle
@main
struct DreamWidgetBundle: WidgetBundle {
    var body: some Widget {
        DreamLiveActivity()
    }
}
