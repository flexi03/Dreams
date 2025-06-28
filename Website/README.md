# Dreams Website

Moderne Landing Page für die Dreams Traumtagebuch iOS-App.

## 📁 Struktur

```
Website/
├── index.html              # Haupt-Landing Page
├── assets/
│   ├── css/
│   │   └── style.css       # Hauptstyles mit CSS Custom Properties
│   ├── js/
│   │   └── script.js       # Interaktivität und Animationen
│   └── images/
│       ├── app-icon.png    # Haupt-App-Icon (1024x1024)
│       ├── app-icon-180.png # Kleineres App-Icon (180x180)
│       ├── screenshot1.jpg # App Screenshots (einfügen)
│       ├── screenshot2.jpg
│       ├── screenshot3.jpg
│       └── screenshot4.jpg
└── README.md               # Diese Datei
```

## 🎨 Design-Features

### Moderne UI/UX
- **iOS 26 inspiriert**: Glassy Design und moderne Ästhetik
- **Purple Theme**: Dreams-passende Farbpalette
- **Responsive**: Mobile-first Design
- **Accessibility**: WCAG-konform mit Skip-Links und Fokus-States

### Animationen
- **Scroll-basierte Parallax-Effekte**
- **Intersection Observer** für Fade-in Animationen
- **Floating Phone Mockup** im Hero-Bereich
- **Hover-Effekte** auf Cards und Buttons

### Performance
- **Lazy Loading** für Bilder
- **Throttled/Debounced** Event Handler
- **Preloading** kritischer Ressourcen
- **Modern CSS** mit Custom Properties

## 📱 Responsive Breakpoints

- **Desktop**: 1200px+
- **Tablet**: 768px - 1199px
- **Mobile**: < 768px
- **Small Mobile**: < 480px

## 🚀 Setup & Deployment

### Lokale Entwicklung
1. Ordner in Webserver einbinden (z.B. XAMPP, MAMP)
2. `index.html` öffnen
3. Screenshots in `assets/images/` einfügen

### Produktions-Deployment
1. Alle Dateien auf Webserver hochladen
2. Domain auf `index.html` zeigen lassen
3. HTTPS aktivieren (für Service Worker)

## 📸 Screenshots hinzufügen

Platziere die App-Screenshots als:
- `screenshot1.jpg` - Haupt-App-Ansicht (Traumtagebuch)
- `screenshot2.jpg` - Statistiken/Analytics
- `screenshot3.jpg` - DreamPass Feature
- `screenshot4.jpg` - Audio/Transkription Feature

**Empfohlene Größe**: 300x600px (iPhone-Format)

## 🎯 SEO & Meta Tags

- **Open Graph** Tags für Social Media
- **Twitter Cards** Support
- **Semantic HTML** Struktur
- **Structured Data** bereit für Google

## 🔧 Anpassungen

### Farben ändern
Editiere CSS Custom Properties in `style.css`:
```css
:root {
    --primary: #8b5cf6;        /* Haupt-Purple */
    --primary-dark: #7c3aed;   /* Dunkleres Purple */
    --primary-light: #a78bfa;  /* Helleres Purple */
}
```

### Content anpassen
Alle Texte direkt in `index.html` editierbar.

### Links aktualisieren
- TestFlight Link: In allen `href="https://testflight.apple.com/join/AU1CmRfH"`
- Entwickler-Website: `https://cinematicfelix.de`
- E-Mail: `felix@cinematicfelix.de`

## 🌐 Browser-Support

- **Chrome/Safari/Edge**: Vollständig unterstützt
- **Firefox**: Vollständig unterstützt
- **IE11**: Basis-Funktionalität (ohne moderne CSS Features)

## 📊 Analytics Integration

Bereit für:
- Google Analytics 4
- Umami Analytics
- Plausible Analytics

Code in `script.js` `trackButtonClick()` Funktion.

## 🔒 Privacy & GDPR

- **Keine Cookies** standardmäßig
- **Keine externen Tracker**
- **Lokale Ressourcen** bevorzugt
- GDPR-ready bei Analytics-Integration

## 🎨 Design-Tokens

### Spacing
```css
--spacing-xs: 0.5rem   /* 8px */
--spacing-sm: 1rem     /* 16px */
--spacing-md: 1.5rem   /* 24px */
--spacing-lg: 2rem     /* 32px */
--spacing-xl: 3rem     /* 48px */
```

### Typography
- **Font**: Inter (Google Fonts)
- **Weights**: 300, 400, 500, 600, 700, 800
- **Scale**: Modular Scale basiert

### Shadows
- **Glass-morphism** Effekte
- **Elevation** System
- **Purple Glow** für Hover-States

## 📄 Lizenz

Diese Website ist Teil des Dreams-Projekts von Felix Kircher (HSD Mediengestaltung 2 Modul).

---

**Live-Website**: https://dreams.cinematicfelix.de  
**TestFlight**: https://testflight.apple.com/join/AU1CmRfH