//
//  QuoteOfTheDay.swift
//  Dreams
//
//  Created by Felix Kircher on 21.04.25.
//

import SwiftUI

struct QuoteOfTheDay: View {
    @StateObject private var quoteViewModel = QuoteViewModel()
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let error = quoteViewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else if let quote = quoteViewModel.currentQuote {
                HStack {
                    Text("Zitat des Tages")
                        .font(.title)
                        .bold()
                    
                    Button(action: {
                        Task {
                            await quoteViewModel.loadRandomQuote()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise.circle")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title)
                    }
                    
                    if quoteViewModel.isLoading {
                        ProgressView()
                    }
                }
                Text(quote.quote)
                    .font(.headline)
                    .lineLimit(3)
                
                Text("- \(quote.author)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                // Falls kein Zitat vorhanden ist -> zb beim ersten Laden der App
                Text("No quote available")
                    .foregroundColor(.gray)
                Button("Load first quote") {
                    Task { await quoteViewModel.loadRandomQuote() }
                }
            }
            
            
        }
        .frame(width: .infinity)
        .contentShape(Rectangle())
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Design.gradient.opacity(0.5))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .onAppear {
            quoteViewModel.loadSavedQuote()
        }
        .padding(.horizontal)
    }
}

struct Quote: Codable, Identifiable {
    let id: Int
    let quote: String
    let author: String
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case rateLimitExceeded
    case invalidStatusCode(Int)
    case decodingError(Error)
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://qapi.vercel.app/api"
    
    func fetchRandomQuote() async throws -> Quote {
        guard let url = URL(string: "\(baseURL)/random") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200: break
        case 429: throw APIError.rateLimitExceeded
        default: throw APIError.invalidStatusCode(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(Quote.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

@MainActor
class QuoteViewModel: ObservableObject {
    @Published var currentQuote: Quote?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let networkManager = NetworkManager.shared
    
    func loadRandomQuote() async {
        isLoading = true
        error = nil
        
        do {
            let quote = try await networkManager.fetchRandomQuote()
            print("API Response: \(quote)") // Debug-Log
            currentQuote = quote
            saveQuote(quote)
        } catch {
            print("API Error: \(error)") // Wichtig für die Fehlersuche
            self.error = error
        }
        
        isLoading = false
    }
    
    private func saveQuote(_ quote: Quote) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(quote) {
            UserDefaults.standard.set(encoded, forKey: "savedQuote")
        }
    }
    
    func loadSavedQuote() {
        if let savedData = UserDefaults.standard.data(forKey: "savedQuote") {
            let decoder = JSONDecoder()
            if let quote = try? decoder.decode(Quote.self, from: savedData) {
                currentQuote = quote
            }
        }
    }
}
