//
//  ToastView.swift
//  Dreams
//
//  Created by Felix Kircher on 07.06.25.
//

import SwiftUI

// MARK: - Toast View
struct ToastView: View {
    let toast: Toast
    let index: Int
    let onDismiss: () -> Void
    
    @StateObject private var toastManager = ToastManager.shared
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    
    private var isExpanded: Bool {
        toastManager.expandedToastId == toast.id
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Toast Content
            HStack(spacing: 12) {
                // Icon
                Image(systemName: toast.type.icon)
                    .font(.title2)
                    .foregroundColor(toast.type.color)
                
                // Message
                VStack(alignment: .leading, spacing: 4) {
                    Text(toast.message)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(isExpanded ? nil : 2)
                    
                    if !isExpanded {
                        Text(DateFormatter.toastTimeFormatter.string(from: toast.timestamp))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Expand button (only show if there are details or if message is long)
                if toast.details != nil || toast.message.count > 50 {
                    Button(action: {
                        toastManager.toggleExpanded(toast.id)
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .frame(width: 30, height: 30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(toast.type.color.opacity(0.3), lineWidth: isExpanded ? 2 : 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Close Button
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(width: 30, height: 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.red.opacity(0.3), lineWidth: isExpanded ? 2 : 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            
            // Expanded Content
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                        .background(toast.type.color.opacity(0.3))
                    
                    if let details = toast.details {
                        Text("Details:")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        
                        Text(details)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    HStack {
                        Text("Time: \(DateFormatter.toastTimeFormatter.string(from: toast.timestamp))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Type: \(String(describing: toast.type).capitalized)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(toast.type.color.opacity(0.3), lineWidth: isExpanded ? 2 : 1)
        )
        .scaleEffect(isExpanded ? 1.0 : scaleForIndex)
        .offset(y: isExpanded ? -66 : (offsetForIndex + dragOffset.height))
        .opacity(isExpanded ? 1.0 : opacityForIndex)
        .zIndex(isExpanded ? 1000 : Double(toastManager.toasts.count - index - 1)) // Higher index = higher z-index, newest (index 0) gets highest
        .gesture(
            DragGesture()
                .onChanged { value in
                    if !isExpanded && value.translation.height > 0 {
                        dragOffset = value.translation
                        isDragging = true
                    }
                }
                .onEnded { value in
                    if !isExpanded && value.translation.height > 50 {
                        onDismiss()
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = .zero
                        }
                    }
                    isDragging = false
                }
        )
        .disabled(isExpanded && index > 0) // Disable interaction for background toasts when one is expanded
    }
    
    private var scaleForIndex: CGFloat {
        let baseScale: CGFloat = 1.0
        let scaleReduction: CGFloat = 0.05
        return baseScale - (CGFloat(index) * scaleReduction)
    }
    
    private var offsetForIndex: CGFloat {
        let baseOffset: CGFloat = -66
        let offsetIncrease: CGFloat = 8 // Changed to positive to move older toasts up
        return baseOffset + (CGFloat(index) * offsetIncrease)
    }
    
    private var opacityForIndex: Double {
        let baseOpacity: Double = 1.0
        let opacityReduction: Double = 0.15
        return baseOpacity - (Double(index) * opacityReduction)
    }
}


// MARK: - Toast Container
struct ToastContainer: View {
    @StateObject private var toastManager = ToastManager.shared
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack(alignment: .bottom) {
                ForEach(Array(toastManager.toasts.enumerated()), id: \.element.id) { index, toast in
                    ToastView(
                        toast: toast,
                        index: index
                    ) {
                        toastManager.dismiss(toast)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                }
            }
        }
        .allowsHitTesting(true)
    }
}


// MARK: - View Extension für einfache Verwendung
extension View {
    func withToasts() -> some View {
        ZStack {
            self
            ToastContainer()
        }
    }
}


// MARK: - Demo View
struct ToastTesterView: View {
    @StateObject private var toastManager = ToastManager.shared
    
    var body: some View {
//        NavigationView {
            ScrollView {
                Button("Error Toast") {
                    toastManager.showError(
                        "Dies ist eine Fehlermeldung!",
                        details: "Fehlercode: E001\nBeschreibung: Verbindung zum Server fehlgeschlagen\nLösung: Bitte versuchen Sie es später erneut"
                    )
                }
                .buttonStyle(ToastButtonStyle(color: .red))
                
                Button("Warning Toast") {
                    toastManager.showWarning(
                        "Achtung: Dies ist eine Warnung!",
                        details: "Warnung: Niedriger Akkustand erkannt. Bitte laden Sie Ihr Gerät auf."
                    )
                }
                .buttonStyle(ToastButtonStyle(color: .orange))
                
                Button("Success Toast") {
                    toastManager.showSuccess(
                        "Erfolgreich gespeichert!",
                        details: "Datei wurde erfolgreich in der Cloud gespeichert.\nGröße: 2.5 MB\nSpeicherort: /Documents/wichtige_datei.pdf"
                    )
                }
                .buttonStyle(ToastButtonStyle(color: .green))
                
                Button("Info Toast") {
                    toastManager.showInfo(
                        "Hier ist eine Information für dich.",
                        details: "Die App wurde auf Version 2.1.0 aktualisiert.\nNeue Features:\n• Verbesserte Performance\n• Neue Benutzeroberfläche\n• Bug-Fixes"
                    )
                }
                .buttonStyle(ToastButtonStyle(color: .blue))
                
                Button("Debug Toast") {
                    toastManager.showDebug(
                        "Debug: Wert = 42",
                        details: "Debug-Information:\nMemory Usage: 45.2 MB\nCPU Usage: 12%\nNetwork Status: Connected\nLast API Call: 200 OK"
                    )
                }
                .buttonStyle(ToastButtonStyle(color: .purple))
                
                Button("Long Message Toast") {
                    toastManager.showInfo(
                        "Dies ist eine sehr lange Nachricht, die zeigt, wie Toasts mit viel Text umgehen. Sie sollte expandierbar sein, auch ohne explizite Details, da der Text sehr lang ist und mehr Platz benötigt.",
                        details: "Zusätzliche Details können hier angezeigt werden, wenn der Toast erweitert wird."
                    )
                }
                .buttonStyle(ToastButtonStyle(color: .teal))
                
                Divider()
                    .padding(.vertical)
                
                Button("Mehrere Toasts") {
                    toastManager.showError("Fehler 1", details: "Erster Fehler mit Details")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        toastManager.showWarning("Warnung 1", details: "Erste Warnung mit Details")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        toastManager.showSuccess("Erfolg 1", details: "Erster Erfolg mit Details")
                    }
                }
                .buttonStyle(ToastButtonStyle(color: .gray))
                
                Button("Alle schließen") {
                    toastManager.dismissAll()
                }
                .buttonStyle(ToastButtonStyle(color: .red))
                
                Spacer()
            }
//            .padding()
            .navigationTitle("Toast Demo Tester")
//        }
    }
}


// MARK: - Preview
struct ToastTesterView_Previews: PreviewProvider {
    static var previews: some View {
        ToastTesterView()
            .withToasts()
            .preferredColorScheme(.dark)
    }
}
