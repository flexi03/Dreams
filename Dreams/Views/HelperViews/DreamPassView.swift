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
    @AppStorage("dreamPassData") private var dreamPassData: Data = Data()
    @State private var dreamPass: DreamPass?
    @State private var showingNameInput = false
    @State private var tempUserName = ""
    @State private var showingShareSheet = false
    @State private var passImage: UIImage?
    
    var body: some View {
        NavigationStack {
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
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Pass teilen")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                
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
            .onAppear {
                if dreamPass == nil {
                    generateNewPass()
                }
            }
            .sheet(isPresented: $showingNameInput) {
                NameInputView(userName: $tempUserName) {
                    userName = tempUserName
                    generateNewPass()
                    showingNameInput = false
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = passImage {
                    ShareSheet(items: [image])
                }
            }
        }
    }
    
    private func generateNewPass() {
        let name = userName.isEmpty ? "Träumer" : userName
        
        // Versuche existierenden Pass zu laden
        var existingPass: DreamPass? = nil
        if !dreamPassData.isEmpty {
            do {
                existingPass = try JSONDecoder().decode(DreamPass.self, from: dreamPassData)
            } catch {
                print("Fehler beim Laden des gespeicherten Passes: \(error)")
            }
        }
        
        // Erstelle Pass mit existierendem Design (falls vorhanden)
        dreamPass = DreamPass(name: name, dreams: store.dreams, existingPass: existingPass)
        
        // Speichere Pass
        if let pass = dreamPass {
            do {
                dreamPassData = try JSONEncoder().encode(pass)
            } catch {
                print("Fehler beim Speichern des Passes: \(error)")
            }
        }
    }
    
    private func sharePass() {
        guard let pass = dreamPass else { return }
        
        // Optimized rendering with fixed size
        let passCard = DreamPassCard(pass: pass)
            .frame(width: 350, height: 220)
            .background(Color.black) // Ensure solid background
        
        let renderer = ImageRenderer(content: passCard)
        renderer.scale = 2.0 // Reduced scale for better performance
        
        // Use async rendering for better performance
        Task {
            let image = await MainActor.run {
                renderer.uiImage
            }
            
            if let image = image {
                let finalImage = await Task.detached {
                    await addAppLinkToImage(image)
                }.value
                
                await MainActor.run {
                    passImage = finalImage
                    showingShareSheet = true
                }
            }
        }
    }
    
    private func addAppLinkToImage(_ image: UIImage) -> UIImage {
        let padding: CGFloat = 60
        let size = CGSize(width: image.size.width, height: image.size.height + padding)
        
        return UIGraphicsImageRenderer(size: size).image { context in
            // Fill background
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw original image
            image.draw(at: .zero)
            
            // Add app link text with better styling
            let appText = "Erstelle deinen eigenen Dream Pass!"
            let linkText = "Dreams App herunterladen"
            
            let textColor = UIColor.white
            let font = UIFont.systemFont(ofSize: 14, weight: .medium)
            let linkFont = UIFont.systemFont(ofSize: 12, weight: .regular)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            // Draw main text
            let textRect = CGRect(x: 20, y: image.size.height + 10, width: size.width - 40, height: 20)
            appText.draw(in: textRect, withAttributes: [
                .font: font,
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ])
            
            // Draw link text
            let linkRect = CGRect(x: 20, y: image.size.height + 32, width: size.width - 40, height: 18)
            linkText.draw(in: linkRect, withAttributes: [
                .font: linkFont,
                .foregroundColor: textColor.withAlphaComponent(0.7),
                .paragraphStyle: paragraphStyle
            ])
        }
    }
}

struct DreamPassCard: View {
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
            
            // Decorative elements
            GeometryReader { geometry in
                // Floating circles
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 100, height: 100)
                    .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.7)
                
                // Dream symbols
                Text("✨")
                    .font(.title)
                    .opacity(0.3)
                    .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.8)
                
                Text("🌙")
                    .font(.title2)
                    .opacity(0.4)
                    .position(x: geometry.size.width * 0.15, y: geometry.size.height * 0.15)
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
                    
                    // Logo
                    Text(pass.dominantMood.rawValue)
                        .font(.largeTitle)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.2)))
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
}

struct NameInputView: View {
    @Binding var userName: String
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
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
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    DreamPassView()
        .environmentObject(DreamStoreSampleData())
}
