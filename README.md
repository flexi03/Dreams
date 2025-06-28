# Dreams 🌙

**Eine innovative iOS-App zur Dokumentation und Analyse von Träumen**

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS_26+-blue.svg)
![TestFlight](https://img.shields.io/badge/TestFlight-Live_Beta-green.svg)
![University](https://img.shields.io/badge/HSD-Academic_Project-purple.svg)

Dreams ist eine moderne iOS-App, die entwickelt wurde, um die faszinierende Welt der Träume systematisch zu erfassen, zu analysieren und zu verstehen. Als Uni-Projekt im Rahmen des Moduls "Mediengestaltung 2" an der Hochschule Düsseldorf entstanden, kombiniert Dreams cutting-edge iOS-Technologien mit innovativen UX-Ansätzen.

## 🎯 Kernfeatures

### 🎤 Audio-Integration & KI-Transkription
- **Sprachaufzeichnung** für spontane Traumerinnerungen direkt nach dem Aufwachen
- **Automatische Transkription** mit iOS Speech Framework
- **Intelligente Content-Erkennung** zwischen manuell geschriebenem Text und Audio-Transkripten
- **Kombinierte Workflows** für nahtlose Text/Audio-Eingabe

### 📊 Erweiterte Statistiken & Visualisierung
- **GitGrid-Visualisierung**: GitHub-inspirierte Aktivitätsübersicht für Traumhäufigkeit
- **Streak-System**: Motivation durch aufeinanderfolgende Traumtagebuch-Einträge
- **Mood-Tracking**: Emotionale Muster und Trends über Zeit
- **Schlafqualitäts-Analyse**: Mond-basierte Bewertung (1-5 🌙)
- **Tag-Clouds**: Häufigste Traumthemen und -muster
- **Detaillierte Insights**: Umfassende Datenanalyse für persönliche Traumtrends

### 🎫 DreamPass-System
Innovatives Pass-Feature mit:
- **5 Farbschemata**: Cosmic, Ocean, Sunset, Forest, Aurora
- **Dynamische Live-Statistiken** mit automatischen Updates
- **Share-Funktionalität** als elegante Grafik für soziale Medien
- **Persistente Design-Präferenzen**

### 📱 iOS 26+ Live Activities
- **Widget-Integration** für Lock Screen und Home Screen
- **Echtzeit Streak-Tracking** ohne App öffnen zu müssen
- **Tagesziel-Monitoring** mit visuellen Fortschrittsanzeigen
- **Intelligente Auto-Start** Funktionalität

### 🌙 Quote of the Day
- **30+ kuratierte deutsche Traumzitate** von Freud bis Hermann Hesse
- **Intelligente Lade-Logik**: Nur einmal täglich neue Inspiration
- **Offline-Funktionalität** für kontinuierliche Nutzung
- **Handverlesene Sammlung** philosophischer und psychologischer Traumweisheiten

## 🏗️ Technische Architektur

### Core Technologies
```swift
SwiftUI (iOS 26+)          // Modernes UI Framework mit Glassy Design
AVFoundation               // Audio-Aufnahme und -wiedergabe
Speech Framework           // KI-gestützte Sprachtranskription
ActivityKit               // Live Activities für Lock Screen
UserDefaults              // Lokale Datenpersistierung
Combine                   // Reactive Programming
```

### Architektur-Pattern
```
Dreams App
├── Single-Target Architektur
├── Widget Extension (DreamsWidget)
├── MVVM mit SwiftUI und ObservableObject
├── Lokale Datenpersistierung (UserDefaults)
└── Modular Component Structure
```

### Datenmodell
```swift
struct DreamEntry: Identifiable, Codable {
    let id: UUID
    var isPinned: Bool
    let date: Date
    var title: String
    var content: String
    var mood: Mood              // 🌌😊😢😡😱🔮
    var tags: [String]
    var sleepQuality: Int       // 1-5 Monde 🌙
    var audioMemos: [AudioMemo]
}

struct AudioMemo: Identifiable, Codable {
    let id: UUID
    let url: URL
    var transcript: String?
    var duration: TimeInterval
}
```

## 🎨 Design & UX

### Design-Philosophie
- **iOS 26 Glassy Design** als Grundlage für traumhafte Ästhetik
- **Dark Mode Only** für entspannende, nächtliche Atmosphäre
- **Konsistente Purple/Lila Akzentfarbe** durchgehend
- **Mond-Iconographie** statt traditioneller Sterne
- **Fließende Animationen** und intuitive Übergänge

### Navigation-Struktur
```
TabView (Haupt-Navigation)
├── Traumtagebuch
│   ├── Quote of the Day Widget
│   ├── Gepinnte Träume (Favoriten)
│   ├── Chronologische Traumliste
│   └── Search & Filter-Funktionen
└── Statistiken & Analytics
    ├── Interactive StatCards
    ├── GitGrid Aktivitäts-Visualisierung
    ├── DreamPass Preview & Sharing
    └── Insights & Trend-Analyse
```

## 🚀 Installation & Setup

### Voraussetzungen
- **iOS 26.0+** (Developer Beta empfohlen)
- **iPhone/iPad** mit Mikrofon-Zugriff
- **~50MB** freier Speicherplatz

### TestFlight Beta
```
🔗 Live Beta: https://testflight.apple.com/join/AU1CmRfH
```

Die App ist aktuell in der öffentlichen Beta-Phase über TestFlight verfügbar. Neue Builds werden regelmäßig mit Community-Feedback und neuen Features veröffentlicht.

### Lokale Entwicklung
```bash
git clone https://github.com/flexi03/Dreams.git
cd Dreams
open Dreams.xcodeproj
```

**Wichtig**: Benötigt Xcode 16+ mit iOS 26 SDK für vollständige Kompatibilität.

## 📖 Nutzung

### Grundfunktionen
1. **Traum hinzufügen**: Über '+' Button neuen Traum mit Text oder Audio erfassen
2. **Stimmung bewerten**: Emoji-basierte Mood-Auswahl für emotionale Einordnung
3. **Schlafqualität**: 1-5 Monde für detaillierte Schlafanalyse
4. **Tags erstellen**: Flexible Kategorisierung für bessere Organisation
5. **Audio aufnehmen**: Spontane Sprachmemos für authentic Traumerinnerungen

### Erweiterte Features
- **Träume pinnen**: Wichtige oder besondere Träume als Favoriten markieren
- **Statistiken erkunden**: Detaillierte Einblicke in persönliche Traummuster
- **DreamPass generieren**: Elegante Übersicht zum Teilen der Traumjournal-Aktivität
- **Live Activities**: Streak-Tracking direkt vom Lock Screen

## 🧪 Entwicklungs-Highlights

### Technische Innovationen
- **Erste Traumtagebuch-App** mit iOS 26 Glassy Design
- **Intelligente Audio-Text-Integration** mit visueller Content-Type-Unterscheidung
- **GitHub-inspirierte GitGrid** für Traumaktivitäts-Visualisierung
- **Innovative DreamPass-Funktion** für shareable Statistiken

### Gelöste Herausforderungen
1. **Swift Compiler Timeouts**: Optimierung komplexer Array-Operationen in Analyse-Funktionen
2. **NavigationStack Konflikte**: Globale Navigation-Architektur für Tab-übergreifende Konsistenz
3. **LiveActivity Management**: Conditional Auto-Start für bessere User Experience
4. **Toast-System Complexity**: Intelligente Debug-Filterung für verschiedene Benachrichtigungstypen

## 📊 Technische Spezifikationen

### Performance Metrics
- **App-Start**: <2s auf modernen Geräten
- **Audio-Latenz**: <100ms für Aufnahme-Start
- **UI-Responsiveness**: Konstante 60fps mit Glassy Effects
- **Memory Footprint**: ~30MB durchschnittliche Nutzung

### Datenmanagement
- **Lokale Persistierung** via UserDefaults mit JSON-Encoding
- **Audio-Dateien** mit URL-Referenzen und automatischem Cleanup
- **Offline-First Approach** für zuverlässige Nutzung ohne Internet
- **Daten-Migration** für nahtlose Updates zwischen App-Versionen

## 🌐 Zusätzliche Ressourcen

### Landing Page
🔗 **Live Website**: https://dreams.cinematicfelix.de

Moderne Projekt-Website mit:
- Detaillierte Feature-Übersicht
- App-Screenshots und Demo-Videos
- Open Source Codeeinblicke
- Direkter TestFlight-Download

### Dokumentation
📚 Umfassende Projektdokumentation verfügbar in `/Doku/`
- Technische Architektur-Details
- Entwicklungsprozess und Meilensteine
- UX-Design Entscheidungen
- Performance-Optimierungen

## 👨‍💻 Entwickler

**Felix Kircher**
- 🎓 **Hochschule Düsseldorf (HSD)** - Medieninformatik
- 📱 **Spezialisierung**: iOS/SwiftUI Entwicklung
- 🌐 **Website**: https://cinematicfelix.de
- 📧 **Kontakt**: felix@cinematicfelix.de

### Akademischer Kontext
Dieses Projekt entstand im Rahmen des Moduls **"Mediengestaltung 2"** mit dem Themenschwerpunkt "Traum". Die Entscheidung für eine native iOS-App basierte auf vorhandener SwiftUI-Erfahrung und dem Wunsch, moderne iOS-Technologien in einem kreativen, praktischen Kontext zu erkunden.

## 📄 Lizenz

MIT License - siehe [LICENSE](LICENSE) Datei für Details.

Dieses Projekt ist Open Source und wurde für Bildungszwecke entwickelt. Community-Beiträge und Feedback sind herzlich willkommen!

## 🔮 Roadmap

### Geplante Features
- **iCloud Sync** für geräteübergreifende Synchronisation
- **Apple Watch App** für schnelle Traum-Notizen
- **Erweiterte KI-Analyse** für automatische Traummustern-Erkennung
- **Social Features** zum anonymen Teilen von Insights

### Technische Evolution
- **iOS 27 Readiness** für kommende Apple-Features
- **Accessibility Improvements** für breitere Nutzbarkeit
- **Performance-Optimierungen** für ältere Geräte
- **Widget-Erweiterungen** für erweiterte Home Screen-Integration

---

**Dreams ist mehr als eine App - es ist ein Fenster in die Welt unserer nächtlichen Gedanken.** 🌙✨

*Entwickelt mit ❤️ an der Hochschule Düsseldorf als innovative Verbindung von akademischem Lernen und professioneller iOS-Entwicklung.*