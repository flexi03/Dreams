//
//  Toast.swift
//  Dreams
//
//  Created by Felix Kircher on 07.06.25.
//

import SwiftUI

// MARK: - Toast Model
struct Toast: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let type: ToastType
    let timestamp = Date()
    let details: String?
    
    init(message: String, type: ToastType, details: String? = nil) {
        self.message = message
        self.type = type
        self.details = details
    }
    
    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Toast Types
enum ToastType: CaseIterable {
    case error
    case warning
    case success
    case info
    case debug
    
    var color: Color {
        switch self {
        case .error:
            return .red
        case .warning:
            return .orange
        case .success:
            return .green
        case .info:
            return .blue
        case .debug:
            return .purple
        }
    }
    
    var icon: String {
        switch self {
        case .error:
            return "xmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .info:
            return "info.circle.fill"
        case .debug:
            return "wrench.and.screwdriver.fill"
        }
    }
}

// MARK: - Toast Manager
@MainActor
class ToastManager: ObservableObject {
    @Published var toasts: [Toast] = []
    @Published var expandedToastId: UUID? {
        didSet {
            if expandedToastId != nil {
                pauseCurrentTimer()
            } else {
                resumeCurrentTimer()
            }
        }
    }
    private var currentTimer: Timer?
    private var currentTimerToastId: UUID?
    private var pausedTimerInfo: (toastId: UUID, remainingTime: TimeInterval)?
    private var timers: [UUID: Timer] = [:]
    private var pausedTimers: [UUID: (startTime: Date, duration: TimeInterval)] = [:]
    
    static let shared = ToastManager()
    
    private init() {}
    
    func show(message: String, type: ToastType, details: String? = nil) {
        let toast = Toast(message: message, type: type, details: details)
        
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.toasts.insert(toast, at: 0) // Insert at beginning to make newest on top
            }
            
            // Start timer for the new topmost toast (5 seconds for new toast)
            if self.expandedToastId == nil {
                self.startTimerForTopmostToast(duration: 5.0)
            }
        }
    }
    
    func dismiss(_ toast: Toast) {
        timers[toast.id]?.invalidate()
        timers.removeValue(forKey: toast.id)
        pausedTimers.removeValue(forKey: toast.id)
        
        // If this toast was expanded, collapse it
        if expandedToastId == toast.id {
            expandedToastId = nil
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            toasts.removeAll { $0.id == toast.id }
        }
    }
    
    func dismissAll() {
        timers.values.forEach { $0.invalidate() }
        timers.removeAll()
        pausedTimers.removeAll()
        expandedToastId = nil
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            toasts.removeAll()
        }
    }
    
    func toggleExpanded(_ toastId: UUID) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if expandedToastId == toastId {
                expandedToastId = nil
            } else {
                expandedToastId = toastId
            }
        }
    }
    
    // MARK: - Timer Management
    private func startTimerForTopmostToast(duration: TimeInterval) {
        // Clear any existing timer
        currentTimer?.invalidate()
        currentTimer = nil
        currentTimerToastId = nil
        
        // Get the topmost toast (first in array)
        guard let topmostToast = toasts.first else { return }
        
        // Start new timer for topmost toast
        currentTimerToastId = topmostToast.id
        currentTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            Task { @MainActor in
                self.dismiss(topmostToast)
            }
        }
    }
    
    private func pauseCurrentTimer() {
        guard let timer = currentTimer,
              let toastId = currentTimerToastId,
              let toast = toasts.first(where: { $0.id == toastId }) else { return }
        
        // Calculate remaining time
        let elapsed = Date().timeIntervalSince(toast.timestamp)
        let totalDuration: TimeInterval = (toastId == toasts.first?.id) ? 5.0 : 1.5
        let remaining = max(0, totalDuration - elapsed)
        
        // Store paused info
        pausedTimerInfo = (toastId: toastId, remainingTime: remaining)
        
        // Stop current timer
        timer.invalidate()
        currentTimer = nil
        currentTimerToastId = nil
    }
    
    private func resumeCurrentTimer() {
        guard let pausedInfo = pausedTimerInfo else {
            // No paused timer, start new one for topmost toast
            if !toasts.isEmpty {
                startTimerForTopmostToast(duration: 5.0)
            }
            return
        }
        
        // Check if the paused toast still exists and is still the topmost
        guard let toast = toasts.first(where: { $0.id == pausedInfo.toastId }),
              toast.id == toasts.first?.id else {
            // Paused toast is no longer topmost, start new timer for current topmost
            pausedTimerInfo = nil
            if !toasts.isEmpty {
                startTimerForTopmostToast(duration: 1.5)
            }
            return
        }
        
        // Resume timer with remaining time
        currentTimerToastId = pausedInfo.toastId
        currentTimer = Timer.scheduledTimer(withTimeInterval: pausedInfo.remainingTime, repeats: false) { _ in
            Task { @MainActor in
                self.dismiss(toast)
            }
        }
        
        pausedTimerInfo = nil
    }
}


// MARK: - Convenience Extensions
extension ToastManager {
    func showError(_ message: String, details: String? = nil) {
        show(message: message, type: .error, details: details)
    }
    
    func showWarning(_ message: String, details: String? = nil) {
        show(message: message, type: .warning, details: details)
    }
    
    func showSuccess(_ message: String, details: String? = nil) {
        show(message: message, type: .success, details: details)
    }
    
    func showInfo(_ message: String, details: String? = nil) {
        show(message: message, type: .info, details: details)
    }
    
    func showDebug(_ message: String, details: String? = nil) {
        show(message: message, type: .debug, details: details)
    }
}

// MARK: - Date Formatters
extension DateFormatter {
    // Time formatter for xx:xx:xx before seperated in normal (xx:xx) and detail (xx:xx:xx)
    static let toastTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }()
}


// MARK: - Custom Button Style
struct ToastButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .padding(.horizontal)
    }
}
