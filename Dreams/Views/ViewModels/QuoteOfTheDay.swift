//
//  QuoteOfTheDay.swift
//  Dreams
//
//  Created by Felix Kircher on 21.04.25.
//

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
                            await quoteViewModel.loadRandomQuote(showToast: true)
                            UserDefaults.standard.set(Date(), forKey: "lastQuoteDate")
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
                Text(quote.content)
                    .font(.headline)
//                    .lineLimit(3)
                HStack {
                    Text("- \(quote.author)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    // Datum anzeigen, falls vorhanden
                    if let date = quote.date {
                        Text(date)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(width: 45, height: 25)
                            .background(
                                RoundedRectangle(cornerSize: .init(width: 8, height: 8))
                                    .fill(Color.primary)
                            )
                    }
                }
                
            } else {
                // Falls kein Zitat vorhanden ist -> z.B. beim ersten Laden der App
                Text("Kein Zitat verfügbar")
                    .foregroundColor(.gray)
                Button("Erstes Zitat laden") {
                    Task { await quoteViewModel.loadRandomQuote() }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Design.gradient.opacity(0.5))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
        .onAppear {
            // Nur beim ersten Aufruf oder wenn kein gespeichertes Zitat vorhanden ist
            if quoteViewModel.currentQuote == nil {
                quoteViewModel.loadSavedQuoteOrLoadNew()
            }
        }
        .padding(.horizontal)
    }
}

// Quote-Struktur
struct Quote: Codable, Identifiable {
    let id: String
    let content: String
    let author: String
    let language: String
    let date: String? // Optional - Datum oder Zeitperiode des Zitats
    
    // CodingKeys für API-Mapping
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case content = "quote"
        case author = "author"
        case language = "language"
        case date = "date"
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case rateLimitExceeded
    case invalidStatusCode(Int)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ungültige URL"
        case .invalidResponse:
            return "Ungültige Antwort vom Server"
        case .rateLimitExceeded:
            return "API-Limit überschritten. Bitte später erneut versuchen."
        case let .invalidStatusCode(code):
            return "Fehlercode: \(code)"
        case let .decodingError(error):
            return "Fehler beim Dekodieren: \(error.localizedDescription)"
        case let .networkError(error):
            return "Netzwerkfehler: \(error.localizedDescription)"
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    
    // Konfigurierbare API-Endpunkte - können leicht geändert werden
    private var quoteAPIBaseURL = "https://quote-garden.onrender.com/api/v3"
    
    // API-URL anpassen (falls nötig)
    func setAPIBaseURL(_ newURL: String) {
        quoteAPIBaseURL = newURL
    }
    
    func fetchRandomQuote(language: String = "de") async throws -> Quote {
        // Wähle Quelle basierend auf Sprache
        if language == "de" {
            // Lokale deutsche Traum-Zitate
            return getLocalDreamQuote()
        } else {
            // Für englische Zitate nutzen wir eine externe API
            return try await fetchExternalQuote()
        }
    }
    
    private func fetchExternalQuote() async throws -> Quote {
        // Verwende konfigurierte API für externe Zitate
        guard let url = URL(string: "\(quoteAPIBaseURL)/quotes/random") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200: break
            case 429: throw APIError.rateLimitExceeded
            default: throw APIError.invalidStatusCode(httpResponse.statusCode)
            }
            
            // Debug: Raw-Antwort loggen
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw API response: \(jsonString)")
            }
            
            // Generische Struktur für API-Antwort
            // Diese muss je nach verwendeter API angepasst werden
            struct QuoteGardenResponse: Codable {
                let data: [QuoteGardenQuote]
                
                struct QuoteGardenQuote: Codable {
                    let _id: String
                    let quoteText: String
                    let quoteAuthor: String
                }
            }
            
            let decoder = JSONDecoder()
            let quoteResponse = try decoder.decode(QuoteGardenResponse.self, from: data)
            
            guard let quoteData = quoteResponse.data.first else {
                throw APIError.invalidResponse
            }
            
            // Konvertiere in unser Quote-Format
            return Quote(
                id: quoteData._id,
                content: quoteData.quoteText,
                author: quoteData.quoteAuthor,
                language: "en",
                date: nil // Die API liefert kein Datum
            )
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            throw APIError.decodingError(decodingError)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // Lokale Sammlung von Traum-bezogenen Zitaten
    private func getLocalDreamQuote() -> Quote {
        // Umfangreiche Sammlung thematisch passender Zitate für eine Traumtagebuch-App
        let dreamQuotes = [
            // Traumdeutung und Traumpsychologie
            Quote(id: "dream1", content: "Träume sind der königliche Weg zum Unbewussten.", author: "Sigmund Freud", language: "de", date: "1900"),
            Quote(id: "dream2", content: "Der Traum ist die kleine verborgene Tür im Innersten der Seele.", author: "Carl Gustav Jung", language: "de", date: "1934"),
            Quote(id: "dream3", content: "Wir sind aus solchem Stoff wie Träume sind, und unser kleines Leben ist von einem Schlaf umringt.", author: "William Shakespeare", language: "de", date: "1611"),
            Quote(id: "dream4", content: "Träume sind Schäume, aber Schäume sind nicht nichts.", author: "Novalis", language: "de", date: "1800"),
            Quote(id: "dream5", content: "In unseren Träumen erwacht die Seele zum Leben.", author: "Marie von Ebner-Eschenbach", language: "de", date: "1893"),
            
            // Philosophische Betrachtungen über Träume
            Quote(id: "dream6", content: "Die Wirklichkeit ist nur eine Illusion, wenn auch eine sehr hartnäckige.", author: "Albert Einstein", language: "de", date: nil),
            Quote(id: "dream7", content: "Alles, was wir sehen, könnte auch anders sein. Alles, was wir überhaupt beschreiben können, könnte auch anders sein.", author: "Ludwig Wittgenstein", language: "de", date: "1921"),
            Quote(id: "dream8", content: "Erlaube dir zu träumen, denn in Träumen ist die Tür zu Ewigkeit.", author: "Friedrich Hölderlin", language: "de", date: "1797"),
            Quote(id: "dream9", content: "Wer sich seinen Träumen stellt, muss nicht von ihnen verfolgt werden.", author: "Friedrich Nietzsche", language: "de", date: "1882"),
            Quote(id: "dream10", content: "Träume sind der Schlüssel zur Unendlichkeit der Fantasie.", author: "Hermann Hesse", language: "de", date: "1922"),
            
            // Traumrealisation und Lebensträume
            Quote(id: "dream11", content: "Folge deinen Träumen, sie kennen den Weg.", author: "Rainer Maria Rilke", language: "de", date: nil),
            Quote(id: "dream12", content: "Wer aufgehört hat zu träumen, hat aufgehört zu leben.", author: "Malcolm Forbes", language: "de", date: nil),
            Quote(id: "dream13", content: "Es ist nicht genug zu wissen, man muss auch anwenden; es ist nicht genug zu wollen, man muss auch tun.", author: "Johann Wolfgang von Goethe", language: "de", date: "1829"),
            Quote(id: "dream14", content: "Die Zukunft gehört denen, die an die Wahrhaftigkeit ihrer Träume glauben.", author: "Eleanor Roosevelt", language: "de", date: nil),
            Quote(id: "dream15", content: "Träume dir dein Leben schön und mach aus diesen Träumen eine Realität.", author: "Marie Curie", language: "de", date: nil),
            
            // Bewusstheit und Klarträume
            Quote(id: "dream16", content: "Im Traum sind wir wissende Unwissende.", author: "Ernst Ferstl", language: "de", date: "1998"),
            Quote(id: "dream17", content: "Wer im Traum zu sich selbst findet, wird auch im Leben zu sich finden.", author: "Paul Keller", language: "de", date: nil),
            Quote(id: "dream18", content: "In Träumen und in Liebe ist nichts unmöglich.", author: "János Arany", language: "de", date: nil),
            Quote(id: "dream19", content: "Klarträume sind das Fenster zu unserer inneren Welt, durch das wir bewusst blicken können.", author: "Paul Tholey", language: "de", date: "1984"),
            Quote(id: "dream20", content: "Im Traum lösen wir die Rätsel, die uns im Wachen beschäftigen.", author: "Wilhelm Stekel", language: "de", date: "1911"),
            
            // Verbindung zwischen Traum und Kreativität
            Quote(id: "dream21", content: "Die Fantasie ist wichtiger als Wissen, denn Wissen ist begrenzt.", author: "Albert Einstein", language: "de", date: nil),
            Quote(id: "dream22", content: "Kreativität ist Intelligenz, die Spaß hat.", author: "Albert Einstein", language: "de", date: nil),
            Quote(id: "dream23", content: "Wer seiner Traumspur folgt, kommt zu sich selbst.", author: "Stefan Zweig", language: "de", date: nil),
            Quote(id: "dream24", content: "Im Schlaf bereiten wir uns auf das Erwachen vor.", author: "Martin Walser", language: "de", date: nil),
            Quote(id: "dream25", content: "Ein Traum ist ein Gedicht, das der Körper schreibt.", author: "Joachim Ringelnatz", language: "de", date: nil),
            
            // Träume und persönliches Wachstum
            Quote(id: "dream26", content: "Wer nicht an Wunder glaubt, ist kein Realist.", author: "David Ben-Gurion", language: "de", date: nil),
            Quote(id: "dream27", content: "Der Mensch muss bei dem Glauben verharren, dass das Unbegreifliche begreiflich sei; er würde sonst nicht forschen.", author: "Johann Wolfgang von Goethe", language: "de", date: "1809"),
            Quote(id: "dream28", content: "Die größte Entscheidung deines Lebens liegt darin, dass du dein Leben ändern kannst, indem du deine Geisteshaltung änderst.", author: "Albert Schweitzer", language: "de", date: nil),
            Quote(id: "dream29", content: "Wer sein Unterbewusstsein kennt, kennt das Universum.", author: "Carl Gustav Jung", language: "de", date: nil),
            Quote(id: "dream30", content: "In jedem Ende liegt ein Anfang verborgen.", author: "Hermann Hesse", language: "de", date: nil)
        ]
        
        return dreamQuotes.randomElement() ?? dreamQuotes[0]
    }
}

@MainActor
class QuoteViewModel: ObservableObject {
    @Published var currentQuote: Quote?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let networkManager = NetworkManager.shared
    
    func loadSavedQuoteOrLoadNew() {
        // Check if this is first app start today
        let lastQuoteDate = UserDefaults.standard.object(forKey: "lastQuoteDate") as? Date
        let today = Calendar.current.startOfDay(for: Date())
        let shouldLoadNewQuote = lastQuoteDate == nil || Calendar.current.startOfDay(for: lastQuoteDate!) < today
        
        if shouldLoadNewQuote {
            // First start or new day - load new quote
            Task {
                await loadRandomQuote()
                UserDefaults.standard.set(Date(), forKey: "lastQuoteDate")
            }
        } else {
            // Load saved quote from same day
            loadSavedQuote()
            
            // If no saved quote exists (shouldn't happen), load a new one
            if currentQuote == nil {
                Task {
                    await loadRandomQuote()
                }
            }
        }
    }
    
    func loadRandomQuote(language: String = "de", showToast: Bool = false) async {
        isLoading = true
        error = nil
        
        do {
            let quote = try await networkManager.fetchRandomQuote(language: language)
            print("Quote geladen: \(quote.content) von \(quote.author)") // Debug-Log
            if showToast {
                ToastManager.shared.showDebug("Quote von \(quote.author) geladen.", details: "Quote hat folgenden Inhalt: \(quote.content) \n \nJahr: \(quote.date ?? "nicht angegeben")")
            }
            currentQuote = quote
            saveQuote(quote)
        } catch {
            print("Fehler beim Laden des Zitats: \(error)") // Wichtig für die Fehlersuche
            self.error = error
            // Bei einem Fehler: versuche das zuletzt gespeicherte Zitat zu laden
            loadSavedQuote()
        }
        
        isLoading = false
    }
    
    // Zitat lokal speichern für Offline-Zugriff
    private func saveQuote(_ quote: Quote) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(quote) {
            UserDefaults.standard.set(encoded, forKey: "savedQuote")
        }
    }
    
    // Gespeichertes Zitat aus UserDefaults laden
    func loadSavedQuote() {
        if let savedData = UserDefaults.standard.data(forKey: "savedQuote") {
            let decoder = JSONDecoder()
            if let quote = try? decoder.decode(Quote.self, from: savedData) {
                currentQuote = quote
            }
        }
    }
    
    // API-Basis-URL ändern (falls nötig)
    func setCustomAPIURL(_ url: String) {
        NetworkManager.shared.setAPIBaseURL(url)
    }
}
