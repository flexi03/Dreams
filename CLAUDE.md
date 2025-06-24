# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dreams is an iOS dream journal app built entirely in SwiftUI. The app allows users to record dreams with voice memos, transcriptions, mood tracking, and detailed statistics. The project uses a single-target architecture with a widget extension.

## Development Commands

Since this is an Xcode project, there are no command-line build tools. All development is done through Xcode:

- **Build**: Use Xcode build (⌘+B) or build from scheme selector
- **Run**: Use Xcode run (⌘+R) to launch in simulator or device
- **Archive**: Product → Archive for App Store builds
- **Widget Extension**: Select "DreamsWidgetExtension" scheme to build widget

## Architecture

### Core Data Flow
- **DreamStoreSampleData**: ObservableObject that manages all dream entries using UserDefaults for persistence
- **Data Models**: Located in `Dreams/Views/Models/`
  - `DreamEntry`: Core data model with mood, sleep quality, tags, and audio memos
  - `AudioMemo`: Voice recording with transcription support
  - `Toast`: App-wide notification system

### View Architecture
The app follows a clear SwiftUI view hierarchy:

```
ContentView (TabView root)
├── DreamJournalView (Main dream list)
│   ├── AddDreamView (Dream creation form)
│   ├── DreamDetailView (Individual dream view)
│   └── DreamCard (List item component)
└── StatsView (Analytics and visualizations)
    └── GitGrid (GitHub-style activity visualization)
```

### Key Components
- **IntroductionView**: First-launch onboarding with video animation
- **ToastManager**: Global notification system with expandable details
- **AudioRecorderView**: Voice memo recording with Speech-to-Text
- **QuoteOfTheDay**: Localized German dream quotes system

### State Management
- Uses `@StateObject` and `@EnvironmentObject` for data flow
- `DreamStoreSampleData` is the single source of truth, injected via `.environmentObject(store)`
- Toast system uses singleton pattern with `ToastManager.shared`
- First-time launch state managed via `@AppStorage("isFirstStart")`

### App Features
- **Dark Mode Only**: App enforces `.preferredColorScheme(.dark)`
- **Deep Linking**: Supports "dreams://" URL scheme
- **Audio Integration**: Voice recording with automatic transcription via Speech framework
- **Widget Ready**: DreamsWidget extension prepared but not fully implemented
- **German Localization**: All UI text and quotes in German

### Data Persistence
- Uses UserDefaults with JSON encoding for dream storage (key: "dreams_v1")
- Audio files stored locally with URL references in AudioMemo objects
- No external database or cloud sync - purely local storage

### Development Notes
- Project uses SwiftUI lifecycle (`@main` DreamsApp)
- Minimum deployment target can be found in project.pbxproj
- Widget extension configured but requires completion of widget views
- Sample data automatically loaded on first launch for demo purposes