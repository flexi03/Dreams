//
//  DreamPassView.swift
//  Dreams
//
//  Created by Felix Kircher on 27.06.25.
//

import SwiftUI
import UIKit

struct DreamPassView: View {
    @EnvironmentObject private var store: DreamStoreSampleData
    @AppStorage("dreamPassUserName") private var userName: String = ""
    @AppStorage("savedDreamPassData") private var savedPassData: Data = Data()
    @State private var dreamPass: DreamPass?
    @State private var showingNameInput = false
    @State private var tempUserName = ""
    @State private var showingShareSheet = false
    @State private var passImage: UIImage?
    @State private var shareItem: Any?
    @State private var isGeneratingImage = false
    
    var body: some View {
        ZStack {
                // Background gradient
                if let pass = dreamPass {
                    LinearGradient(
                        colors: [pass.colorScheme.background.color, pass.colorScheme.primary.color.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        if let pass = dreamPass {
                            // Main Pass Card
                            DreamPassCard(pass: pass)
                                .padding(.horizontal, 20)
                            
                            // Action Buttons
                            VStack(spacing: 16) {
                                Button(action: generateNewPass) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Neuen Pass generieren")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.regularMaterial)
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: sharePass) {
                                    HStack {
                                        if isGeneratingImage {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                                .foregroundColor(.white)
                                        } else {
                                            Image(systemName: "square.and.arrow.up")
                                        }
                                        Text(isGeneratingImage ? "Generiere Bild..." : "Pass teilen")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isGeneratingImage ? .gray : .blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .disabled(isGeneratingImage)
                                
                                if userName.isEmpty {
                                    Button(action: { showingNameInput = true }) {
                                        HStack {
                                            Image(systemName: "person.badge.plus")
                                            Text("Namen hinzufügen")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(.purple)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        } else {
                            ProgressView("Generiere Dream Pass...")
                                .scaleEffect(1.2)
                                .padding()
                        }
                    }
                    .padding(.vertical, 20)
                }
        }
        .navigationTitle("Dream Pass")
        .navigationBarTitleDisplayMode(.large)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            loadOrCreatePass()
        }
        .sheet(isPresented: $showingNameInput) {
            NameInputView(userName: $tempUserName) {
                userName = tempUserName
                generateNewPass()
                showingNameInput = false
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let item = shareItem {
                ShareSheet(items: [item])
            }
        }
    }
    
    private func loadOrCreatePass() {
        // Versuche gespeicherten Pass zu laden
        if let savedPass = loadSavedPass() {
            // Aktualisiere nur die Statistiken, behalte Design bei
            dreamPass = updatePassStats(savedPass)
        } else {
            // Erstelle neuen Pass wenn keiner gespeichert
            generateNewPass()
        }
    }
    
    private func generateNewPass() {
        let name = userName.isEmpty ? "Träumer" : userName
        let newPass = DreamPass(name: name, dreams: store.dreams, forceNewDesign: true)
        dreamPass = newPass
        savePass(newPass)
    }
    
    private func loadSavedPass() -> DreamPass? {
        guard !savedPassData.isEmpty else { return nil }
        return try? JSONDecoder().decode(DreamPass.self, from: savedPassData)
    }
    
    private func savePass(_ pass: DreamPass) {
        if let encoded = try? JSONEncoder().encode(pass) {
            savedPassData = encoded
        }
    }
    
    private func updatePassStats(_ existingPass: DreamPass) -> DreamPass {
        // Erstelle neuen Pass mit aktualisierten Stats aber gleichem Design
        return DreamPass(
            existingDesign: existingPass,
            name: userName.isEmpty ? "Träumer" : userName,
            dreams: store.dreams
        )
    }
    
    private func sharePass() {
        guard let pass = dreamPass, !isGeneratingImage else { return }
        
        isGeneratingImage = true
        passImage = nil
        
        // Create a simplified version for sharing (no animations) with padding for corners
        let passCard = DreamPassCardStatic(pass: pass)
            .frame(width: 350, height: 220)
            .padding(20) // Add padding so corners aren't cut off
            .background(Color.clear) // Transparent background for better preview
        
        let renderer = ImageRenderer(content: passCard)
        renderer.scale = 2.0
        
        // Render immediately and save to temp file for better ShareSheet recognition
        if let image = renderer.uiImage,
           let pngData = image.pngData() {
            
            // Create temp file with proper name and extension
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "DreamPass-\(Date().timeIntervalSince1970).png"
            let tempURL = tempDir.appendingPathComponent(fileName)
            
            do {
                try pngData.write(to: tempURL)
                // Store URL for sharing (better preview in ShareSheet)
                shareItem = tempURL
                passImage = image // Keep for fallback
                isGeneratingImage = false
                showingShareSheet = true
            } catch {
                // Fallback to regular image sharing
                shareItem = image
                passImage = image
                isGeneratingImage = false
                showingShareSheet = true
            }
        } else {
            // Fallback: try again with lower scale
            renderer.scale = 1.0
            if let fallbackImage = renderer.uiImage {
                shareItem = fallbackImage
                passImage = fallbackImage
                isGeneratingImage = false
                showingShareSheet = true
            } else {
                isGeneratingImage = false
            }
        }
    }
}

struct DreamPassCard: View {
    let pass: DreamPass
    @State private var animationOffset: CGFloat = 0
    @State private var starOpacities: [Double] = Array(repeating: 0.0, count: 8)
    @State private var starPositions: [(x: Double, y: Double)] = []
    
    var body: some View {
        ZStack {
            // Background with gradient
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            pass.colorScheme.primary.color,
                            pass.colorScheme.secondary.color,
                            pass.colorScheme.accent.color.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
            
            // Decorative elements
            GeometryReader { geometry in
                // Background decorative circles (better distributed)
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.3)
                    .offset(y: animationOffset)
                
                Circle()
                    .fill(Color.white.opacity(0.02))
                    .frame(width: 60, height: 60)
                    .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.15)
                    .offset(y: -animationOffset * 0.7)
                
                Circle()
                    .fill(Color.white.opacity(0.03))
                    .frame(width: 140, height: 140)
                    .position(x: geometry.size.width * 0.05, y: geometry.size.height * 0.85)
                    .offset(y: -animationOffset * 0.3)
                
                Circle()
                    .fill(Color.white.opacity(0.025))
                    .frame(width: 70, height: 70)
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.05)
                    .offset(y: animationOffset * 0.5)
                
                // Twinkling stars
                ForEach(0..<8, id: \.self) { index in
                    if index < starPositions.count {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 2, height: 2)
                            .opacity(starOpacities[index])
                            .position(
                                x: geometry.size.width * starPositions[index].x,
                                y: geometry.size.height * starPositions[index].y
                            )
                    }
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DREAM PASS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(pass.colorScheme.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Logo with proper background
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 56, height: 56)
                        
                        Text(pass.dominantMood.rawValue)
                            .font(.largeTitle)
                    }
                }
                
                Spacer()
                
                // Stats
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TRÄUME")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(pass.totalDreams)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("STREAK")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(pass.currentStreak)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("TAG")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.7))
                        Text(pass.favoriteTag)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                
                // Footer
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pass.name.uppercased())
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(pass.passNumber)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Text(pass.createdDate.formatted(.dateTime.day().month().year()))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(24)
        }
        .frame(height: 220)
        .onAppear {
            // Generate random star positions
            generateRandomStarPositions()
            
            // Start floating animation
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animationOffset = 10
            }
            
            // Start star twinkling animations
            startStarAnimations()
        }
    }
    
    private func generateRandomStarPositions() {
        starPositions = []
        for _ in 0..<8 {
            let x = Double.random(in: 0.1...0.9)
            let y = Double.random(in: 0.1...0.9)
            starPositions.append((x: x, y: y))
        }
    }
    
    private func startStarAnimations() {
        // Initialize with random opacities
        for i in 0..<starOpacities.count {
            starOpacities[i] = Double.random(in: 0.2...0.8)
        }
        
        // Start individual twinkling animations for each star
        for i in 0..<starOpacities.count {
            let delay = Double(i) * 0.3
            let duration = Double.random(in: 1.5...3.0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    starOpacities[i] = Double.random(in: 0.1...0.9)
                }
            }
        }
    }
}

// Static version for sharing (no animations)
struct DreamPassCardStatic: View {
    let pass: DreamPass
    
    var body: some View {
        ZStack {
            // Background with gradient
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            pass.colorScheme.primary.color,
                            pass.colorScheme.secondary.color,
                            pass.colorScheme.accent.color.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 8)
            
            // Static decorative elements
            GeometryReader { geometry in
                // Static background circles
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.3)
                
                Circle()
                    .fill(Color.white.opacity(0.02))
                    .frame(width: 60, height: 60)
                    .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.15)
                
                Circle()
                    .fill(Color.white.opacity(0.03))
                    .frame(width: 140, height: 140)
                    .position(x: geometry.size.width * 0.05, y: geometry.size.height * 0.85)
                
                Circle()
                    .fill(Color.white.opacity(0.025))
                    .frame(width: 70, height: 70)
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.05)
                
                // Static stars
                ForEach(staticStarPositions.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 2, height: 2)
                        .opacity(0.6)
                        .position(
                            x: geometry.size.width * staticStarPositions[index].x,
                            y: geometry.size.height * staticStarPositions[index].y
                        )
                }
            }
            
            // Content (same as animated version)
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DREAM PASS")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(pass.colorScheme.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Logo with proper background
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 56, height: 56)
                        
                        Text(pass.dominantMood.rawValue)
                            .font(.largeTitle)
                    }
                }
                
                Spacer()
                
                // Stats
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TRÄUME")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(pass.totalDreams)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("STREAK")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(pass.currentStreak)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("TAG")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.7))
                        Text(pass.favoriteTag)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                
                // Footer
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pass.name.uppercased())
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(pass.passNumber)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Text(pass.createdDate.formatted(.dateTime.day().month().year()))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(24)
        }
        .frame(height: 220)
    }
    
    // Static star positions for consistent sharing images
    private var staticStarPositions: [(x: Double, y: Double)] {
        [
            (x: 0.2, y: 0.25),
            (x: 0.8, y: 0.2),
            (x: 0.3, y: 0.6),
            (x: 0.7, y: 0.75),
            (x: 0.85, y: 0.5),
            (x: 0.15, y: 0.8),
            (x: 0.6, y: 0.35),
            (x: 0.45, y: 0.85)
        ]
    }
}

struct NameInputView: View {
    @Binding var userName: String
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("🌟")
                        .font(.system(size: 60))
                    
                    Text("Personalisiere deinen Dream Pass")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Gib deinen Namen ein, um deinen persönlichen Dream Pass zu erstellen")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                TextField("Dein Name", text: $userName)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                
                Button(action: onSave) {
                    Text("Dream Pass erstellen")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty)
                
                Spacer()
            }
        .padding(24)
        .navigationTitle("Name eingeben")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        // Direct sharing - iOS should handle file URLs and images properly
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    DreamPassView()
        .environmentObject(DreamStoreSampleData())
        .preferredColorScheme(.dark)
}
