// ===== DREAMS WEBSITE JAVASCRIPT =====

// DOM Content Loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeNavigation();
    initializeScrollEffects();
    initializeLazyLoading();
    initializeAnimations();
    initializeCodeCarousel();
});


// ===== NAVIGATION =====
function initializeNavigation() {
    const navToggle = document.getElementById('navToggle');
    const navbar = document.querySelector('.navbar');
    const navLinks = document.querySelector('.nav-links');
    
    // Mobile menu toggle
    if (navToggle && navLinks) {
        navToggle.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const isActive = navLinks.classList.contains('nav-active');
            
            if (isActive) {
                // Close menu
                navLinks.classList.remove('nav-active');
                navToggle.classList.remove('nav-toggle-active');
                document.body.style.overflow = '';
            } else {
                // Open menu
                navLinks.classList.add('nav-active');
                navToggle.classList.add('nav-toggle-active');
                document.body.style.overflow = 'hidden';
            }
        });
        
        // Close menu when clicking on nav links
        const navLinkElements = navLinks.querySelectorAll('.nav-link');
        navLinkElements.forEach(link => {
            link.addEventListener('click', function() {
                navLinks.classList.remove('nav-active');
                navToggle.classList.remove('nav-toggle-active');
                document.body.style.overflow = '';
            });
        });
        
        // Close menu when clicking outside
        document.addEventListener('click', function(e) {
            if (!navbar.contains(e.target) && navLinks.classList.contains('nav-active')) {
                navLinks.classList.remove('nav-active');
                navToggle.classList.remove('nav-toggle-active');
                document.body.style.overflow = '';
            }
        });
        
        // Close menu on escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape' && navLinks.classList.contains('nav-active')) {
                navLinks.classList.remove('nav-active');
                navToggle.classList.remove('nav-toggle-active');
                document.body.style.overflow = '';
            }
        });
    }
    
    // Navbar scroll effect
    window.addEventListener('scroll', function() {
        if (window.scrollY > 50) {
            navbar.classList.add('nav-scrolled');
        } else {
            navbar.classList.remove('nav-scrolled');
        }
        
        // Update active navigation item
        updateActiveNavigation();
    });
    
    // Smooth scroll for navigation links
    const smoothScrollLinks = document.querySelectorAll('a[href^="#"]');
    smoothScrollLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            const targetElement = document.querySelector(targetId);
            
            if (targetElement) {
                const offsetTop = targetElement.offsetTop - 80; // Account for fixed navbar
                window.scrollTo({
                    top: offsetTop,
                    behavior: 'smooth'
                });
                
                // Close mobile menu if open
                if (navLinks.classList.contains('nav-active')) {
                    navLinks.classList.remove('nav-active');
                    navToggle.classList.remove('nav-toggle-active');
                }
            }
        });
    });
    
    // Initial active navigation update
    updateActiveNavigation();
}

// Update active navigation item based on scroll position
function updateActiveNavigation() {
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav-link[href^="#"]');
    
    let currentSection = '';
    const scrollPos = window.scrollY + 100; // Offset for fixed navbar
    
    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.offsetHeight;
        
        if (scrollPos >= sectionTop && scrollPos < sectionTop + sectionHeight) {
            currentSection = section.getAttribute('id');
        }
    });
    
    // If we're at the top of the page, don't highlight anything
    if (window.scrollY < 50) {
        currentSection = '';
    }
    
    // Update nav links
    navLinks.forEach(link => {
        link.classList.remove('active');
        const href = link.getAttribute('href');
        if (href === `#${currentSection}`) {
            link.classList.add('active');
        }
    });
}

// ===== SCROLL EFFECTS =====
function initializeScrollEffects() {
    // Parallax effect for hero section
    const hero = document.querySelector('.hero');
    const heroContent = document.querySelector('.hero-content');
    
    if (hero && heroContent) {
        window.addEventListener('scroll', function() {
            const scrolled = window.pageYOffset;
            const parallaxSpeed = 0.5;
            
            if (scrolled < hero.offsetHeight) {
                heroContent.style.transform = `translateY(${scrolled * parallaxSpeed}px)`;
            }
        });
    }
    
    // Phone mockup rotation effect
    const phoneMockup = document.querySelector('.phone-mockup');
    
    if (phoneMockup) {
        window.addEventListener('scroll', function() {
            const scrolled = window.pageYOffset;
            const heroHeight = document.querySelector('.hero').offsetHeight;
            const rotationProgress = Math.min(scrolled / heroHeight, 1);
            const rotation = 15 - (rotationProgress * 10); // From 15deg to 5deg
            
            phoneMockup.style.transform = `rotate(${rotation}deg)`;
        });
    }
}

// ===== LAZY LOADING =====
function initializeLazyLoading() {
    const images = document.querySelectorAll('img[data-src]');
    
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.remove('lazy');
                imageObserver.unobserve(img);
            }
        });
    });
    
    images.forEach(img => imageObserver.observe(img));
}

// ===== ANIMATIONS =====
function initializeAnimations() {
    // Intersection Observer for fade-in animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
            }
        });
    }, observerOptions);
    
    // Elements to animate
    const animateElements = document.querySelectorAll('.feature-card, .screenshot-item, .about-card, .highlight-item');
    animateElements.forEach(el => {
        el.classList.add('animate-element');
        observer.observe(el);
    });
    
    // Stagger animation for feature cards
    const featureCards = document.querySelectorAll('.feature-card');
    featureCards.forEach((card, index) => {
        card.style.animationDelay = `${index * 0.1}s`;
    });
    
    // Hero text animation
    const heroTitle = document.querySelector('.hero-title');
    const heroDescription = document.querySelector('.hero-description');
    const heroButtons = document.querySelector('.hero-buttons');
    
    if (heroTitle && heroDescription && heroButtons) {
        setTimeout(() => heroTitle.classList.add('animate-in'), 200);
        setTimeout(() => heroDescription.classList.add('animate-in'), 400);
        setTimeout(() => heroButtons.classList.add('animate-in'), 600);
    }
}

// ===== UTILITY FUNCTIONS =====

// Throttle function for scroll events
function throttle(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Debounce function for resize events
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// ===== PERFORMANCE OPTIMIZATIONS =====

// Optimize scroll events
const optimizedScrollHandler = throttle(function() {
    // Any scroll-based functionality goes here
}, 16); // ~60fps

window.addEventListener('scroll', optimizedScrollHandler);

// Optimize resize events
const optimizedResizeHandler = debounce(function() {
    // Any resize-based functionality goes here
}, 250);

window.addEventListener('resize', optimizedResizeHandler);

// ===== ANALYTICS & TRACKING =====

// Track button clicks
function trackButtonClick(buttonName, destination) {
    // Analytics tracking would go here
    console.log(`Button clicked: ${buttonName} -> ${destination}`);
}

// Add click tracking to main CTA buttons
document.addEventListener('DOMContentLoaded', function() {
    const testflightButtons = document.querySelectorAll('a[href*="testflight.apple.com"]');
    testflightButtons.forEach(button => {
        button.addEventListener('click', function() {
            trackButtonClick('TestFlight Download', this.href);
        });
    });
});

// ===== ACCESSIBILITY ENHANCEMENTS =====

// Keyboard navigation for mobile menu
document.addEventListener('keydown', function(e) {
    const navToggle = document.getElementById('navToggle');
    const navLinks = document.querySelector('.nav-links');
    
    if (e.key === 'Escape' && navLinks.classList.contains('nav-active')) {
        navLinks.classList.remove('nav-active');
        navToggle.classList.remove('nav-toggle-active');
        navToggle.focus();
    }
});

// Focus management for skip links
function addSkipLink() {
    const skipLink = document.createElement('a');
    skipLink.href = '#main-content';
    skipLink.textContent = 'Zum Hauptinhalt springen';
    skipLink.className = 'skip-link';
    skipLink.style.cssText = `
        position: absolute;
        top: -40px;
        left: 6px;
        background: var(--primary);
        color: white;
        padding: 8px;
        text-decoration: none;
        border-radius: 4px;
        z-index: 1000;
        transition: top 0.3s;
    `;
    
    skipLink.addEventListener('focus', function() {
        this.style.top = '6px';
    });
    
    skipLink.addEventListener('blur', function() {
        this.style.top = '-40px';
    });
    
    document.body.insertBefore(skipLink, document.body.firstChild);
}

// Initialize accessibility features
document.addEventListener('DOMContentLoaded', addSkipLink);

// ===== ERROR HANDLING =====

// Global error handler for images
document.addEventListener('error', function(e) {
    if (e.target.tagName === 'IMG') {
        e.target.style.display = 'none';
        console.warn('Image failed to load:', e.target.src);
    }
}, true);

// ===== MODERN BROWSER FEATURES =====

// Preload critical resources
function preloadCriticalResources() {
    const criticalImages = [
        'assets/images/app-icon.png',
        'assets/images/app-icon-180.png'
    ];
    
    criticalImages.forEach(src => {
        const link = document.createElement('link');
        link.rel = 'preload';
        link.as = 'image';
        link.href = src;
        document.head.appendChild(link);
    });
}

// Initialize modern features
document.addEventListener('DOMContentLoaded', preloadCriticalResources);

// ===== THEME DETECTION =====

// Detect system dark mode preference
function detectColorScheme() {
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
        document.documentElement.setAttribute('data-theme', 'dark');
    }
    
    // Listen for changes
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
        document.documentElement.setAttribute('data-theme', e.matches ? 'dark' : 'light');
    });
}

// Initialize theme detection
document.addEventListener('DOMContentLoaded', detectColorScheme);

// ===== CODE CAROUSEL =====

const codeSnippets = [
    {
        title: "DreamEntry.swift",
        content: `<div class="code-line">
    <span class="line-number">1</span>
    <span class="code-text"><span class="code-keyword">struct</span> <span class="code-type">DreamEntry</span>: <span class="code-protocol">Identifiable</span>, <span class="code-protocol">Codable</span> {</span>
</div>
<div class="code-line">
    <span class="line-number">2</span>
    <span class="code-text">    <span class="code-keyword">let</span> <span class="code-property">id</span>: <span class="code-type">UUID</span></span>
</div>
<div class="code-line">
    <span class="line-number">3</span>
    <span class="code-text">    <span class="code-keyword">var</span> <span class="code-property">isPinned</span>: <span class="code-type">Bool</span> = <span class="code-keyword">false</span></span>
</div>
<div class="code-line">
    <span class="line-number">4</span>
    <span class="code-text">    <span class="code-keyword">let</span> <span class="code-property">date</span>: <span class="code-type">Date</span></span>
</div>
<div class="code-line">
    <span class="line-number">5</span>
    <span class="code-text">    <span class="code-keyword">var</span> <span class="code-property">title</span>: <span class="code-type">String</span></span>
</div>
<div class="code-line">
    <span class="line-number">6</span>
    <span class="code-text">    <span class="code-keyword">var</span> <span class="code-property">content</span>: <span class="code-type">String</span></span>
</div>
<div class="code-line">
    <span class="line-number">7</span>
    <span class="code-text">    <span class="code-keyword">var</span> <span class="code-property">mood</span>: <span class="code-type">Mood</span> <span class="code-comment">// cosmic, happy, nightmare, etc.</span></span>
</div>
<div class="code-line">
    <span class="line-number">8</span>
    <span class="code-text">    <span class="code-keyword">var</span> <span class="code-property">tags</span>: [<span class="code-type">String</span>]</span>
</div>
<div class="code-line">
    <span class="line-number">9</span>
    <span class="code-text">    <span class="code-keyword">var</span> <span class="code-property">sleepQuality</span>: <span class="code-type">Int</span> <span class="code-comment">// 1-5 moon rating</span></span>
</div>
<div class="code-line">
    <span class="line-number">10</span>
    <span class="code-text">    <span class="code-keyword">var</span> <span class="code-property">audioMemos</span>: [<span class="code-type">AudioMemo</span>]</span>
</div>
<div class="code-line">
    <span class="line-number">11</span>
    <span class="code-text">}</span>
</div>`
    },
    {
        title: "AudioRecorderView.swift",
        content: `<div class="code-line">
    <span class="line-number">1</span>
    <span class="code-text"><span class="code-keyword">@MainActor</span></span>
</div>
<div class="code-line">
    <span class="line-number">2</span>
    <span class="code-text"><span class="code-keyword">class</span> <span class="code-type">AudioRecorder</span>: <span class="code-protocol">ObservableObject</span> {</span>
</div>
<div class="code-line">
    <span class="line-number">3</span>
    <span class="code-text">    <span class="code-keyword">@Published</span> <span class="code-keyword">var</span> <span class="code-property">isRecording</span> = <span class="code-keyword">false</span></span>
</div>
<div class="code-line">
    <span class="line-number">4</span>
    <span class="code-text">    <span class="code-keyword">@Published</span> <span class="code-keyword">var</span> <span class="code-property">transcript</span> = <span class="code-string">""</span></span>
</div>
<div class="code-line">
    <span class="line-number">5</span>
    <span class="code-text">    <span class="code-keyword">@Published</span> <span class="code-keyword">var</span> <span class="code-property">recordingLevel</span>: <span class="code-type">Float</span> = <span class="code-number">0.0</span></span>
</div>
<div class="code-line">
    <span class="line-number">6</span>
    <span class="code-text">    </span>
</div>
<div class="code-line">
    <span class="line-number">7</span>
    <span class="code-text">    <span class="code-keyword">private</span> <span class="code-keyword">var</span> <span class="code-property">audioEngine</span> = <span class="code-type">AVAudioEngine</span>()</span>
</div>
<div class="code-line">
    <span class="line-number">8</span>
    <span class="code-text">    <span class="code-keyword">private</span> <span class="code-keyword">var</span> <span class="code-property">speechRecognizer</span> = <span class="code-type">SFSpeechRecognizer</span>(<span class="code-property">locale</span>: <span class="code-type">Locale</span>(<span class="code-property">identifier</span>: <span class="code-string">"de-DE"</span>))!</span>
</div>
<div class="code-line">
    <span class="line-number">9</span>
    <span class="code-text">    <span class="code-keyword">private</span> <span class="code-keyword">var</span> <span class="code-property">recognitionRequest</span>: <span class="code-type">SFSpeechAudioBufferRecognitionRequest</span>?</span>
</div>
<div class="code-line">
    <span class="line-number">10</span>
    <span class="code-text">    </span>
</div>
<div class="code-line">
    <span class="line-number">11</span>
    <span class="code-text">    <span class="code-keyword">func</span> <span class="code-function">startRecording</span>() <span class="code-keyword">async</span> {</span>
</div>
<div class="code-line">
    <span class="line-number">12</span>
    <span class="code-text">        <span class="code-keyword">guard</span> <span class="code-keyword">await</span> <span class="code-function">requestPermissions</span>() <span class="code-keyword">else</span> { <span class="code-keyword">return</span> }</span>
</div>`
    },
    {
        title: "StatsCalculator.swift",
        content: `<div class="code-line">
    <span class="line-number">1</span>
    <span class="code-text"><span class="code-keyword">extension</span> <span class="code-type">DreamStoreSampleData</span> {</span>
</div>
<div class="code-line">
    <span class="line-number">2</span>
    <span class="code-text">    <span class="code-keyword">var</span> <span class="code-property">currentStreak</span>: <span class="code-type">Int</span> {</span>
</div>
<div class="code-line">
    <span class="line-number">3</span>
    <span class="code-text">        <span class="code-keyword">let</span> <span class="code-property">calendar</span> = <span class="code-type">Calendar</span>.<span class="code-property">current</span></span>
</div>
<div class="code-line">
    <span class="line-number">4</span>
    <span class="code-text">        <span class="code-keyword">let</span> <span class="code-property">today</span> = <span class="code-type">Date</span>()</span>
</div>
<div class="code-line">
    <span class="line-number">5</span>
    <span class="code-text">        <span class="code-keyword">var</span> <span class="code-property">streak</span> = <span class="code-number">0</span></span>
</div>
<div class="code-line">
    <span class="line-number">6</span>
    <span class="code-text">        <span class="code-keyword">var</span> <span class="code-property">currentDate</span> = <span class="code-property">today</span></span>
</div>
<div class="code-line">
    <span class="line-number">7</span>
    <span class="code-text">        </span>
</div>
<div class="code-line">
    <span class="line-number">8</span>
    <span class="code-text">        <span class="code-keyword">while</span> <span class="code-keyword">true</span> {</span>
</div>
<div class="code-line">
    <span class="line-number">9</span>
    <span class="code-text">            <span class="code-keyword">let</span> <span class="code-property">hasDreamToday</span> = <span class="code-property">dreams</span>.<span class="code-function">contains</span> {</span>
</div>
<div class="code-line">
    <span class="line-number">10</span>
    <span class="code-text">                <span class="code-property">calendar</span>.<span class="code-function">isDate</span>(<span class="code-property">$0</span>.<span class="code-property">date</span>, <span class="code-property">inSameDayAs</span>: <span class="code-property">currentDate</span>)</span>
</div>
<div class="code-line">
    <span class="line-number">11</span>
    <span class="code-text">            }</span>
</div>
<div class="code-line">
    <span class="line-number">12</span>
    <span class="code-text">            <span class="code-keyword">if</span> <span class="code-property">hasDreamToday</span> { <span class="code-property">streak</span> += <span class="code-number">1</span> } <span class="code-keyword">else</span> { <span class="code-keyword">break</span> }</span>
</div>`
    },
    {
        title: "QuoteOfTheDay.swift",
        content: `<div class="code-line">
    <span class="line-number">1</span>
    <span class="code-text"><span class="code-keyword">struct</span> <span class="code-type">QuoteOfTheDay</span>: <span class="code-protocol">View</span> {</span>
</div>
<div class="code-line">
    <span class="line-number">2</span>
    <span class="code-text">    <span class="code-keyword">@State</span> <span class="code-keyword">private</span> <span class="code-keyword">var</span> <span class="code-property">currentQuote</span>: <span class="code-type">DreamQuote</span>?</span>
</div>
<div class="code-line">
    <span class="line-number">3</span>
    <span class="code-text">    <span class="code-keyword">@State</span> <span class="code-keyword">private</span> <span class="code-keyword">var</span> <span class="code-property">showingDetail</span> = <span class="code-keyword">false</span></span>
</div>
<div class="code-line">
    <span class="line-number">4</span>
    <span class="code-text">    </span>
</div>
<div class="code-line">
    <span class="line-number">5</span>
    <span class="code-text">    <span class="code-keyword">var</span> <span class="code-property">body</span>: <span class="code-keyword">some</span> <span class="code-type">View</span> {</span>
</div>
<div class="code-line">
    <span class="line-number">6</span>
    <span class="code-text">        <span class="code-type">VStack</span>(<span class="code-property">alignment</span>: .<span class="code-property">leading</span>, <span class="code-property">spacing</span>: <span class="code-number">12</span>) {</span>
</div>
<div class="code-line">
    <span class="line-number">7</span>
    <span class="code-text">            <span class="code-type">Text</span>(<span class="code-string">"Zitat des Tages"</span>)</span>
</div>
<div class="code-line">
    <span class="line-number">8</span>
    <span class="code-text">                .<span class="code-function">font</span>(.<span class="code-property">headline</span>)</span>
</div>
<div class="code-line">
    <span class="line-number">9</span>
    <span class="code-text">                .<span class="code-function">foregroundStyle</span>(.<span class="code-property">secondary</span>)</span>
</div>
<div class="code-line">
    <span class="line-number">10</span>
    <span class="code-text">            </span>
</div>
<div class="code-line">
    <span class="line-number">11</span>
    <span class="code-text">            <span class="code-keyword">if</span> <span class="code-keyword">let</span> <span class="code-property">quote</span> = <span class="code-property">currentQuote</span> {</span>
</div>
<div class="code-line">
    <span class="line-number">12</span>
    <span class="code-text">                <span class="code-type">VStack</span>(<span class="code-property">alignment</span>: .<span class="code-property">leading</span>) {</span>
</div>`
    },
    {
        title: "DreamActivityManager.swift",
        content: `<div class="code-line">
    <span class="line-number">1</span>
    <span class="code-text"><span class="code-keyword">@available</span>(<span class="code-type">iOS</span> <span class="code-number">26.0</span>, *)</span>
</div>
<div class="code-line">
    <span class="line-number">2</span>
    <span class="code-text"><span class="code-keyword">class</span> <span class="code-type">DreamActivityManager</span>: <span class="code-protocol">ObservableObject</span> {</span>
</div>
<div class="code-line">
    <span class="line-number">3</span>
    <span class="code-text">    <span class="code-keyword">@Published</span> <span class="code-keyword">var</span> <span class="code-property">isLiveActivityActive</span> = <span class="code-keyword">false</span></span>
</div>
<div class="code-line">
    <span class="line-number">4</span>
    <span class="code-text">    <span class="code-keyword">private</span> <span class="code-keyword">var</span> <span class="code-property">currentActivity</span>: <span class="code-type">Activity</span>&lt;<span class="code-type">DreamStreakAttributes</span>&gt;?</span>
</div>
<div class="code-line">
    <span class="line-number">5</span>
    <span class="code-text">    </span>
</div>
<div class="code-line">
    <span class="line-number">6</span>
    <span class="code-text">    <span class="code-keyword">func</span> <span class="code-function">startLiveActivity</span>(<span class="code-property">currentStreak</span>: <span class="code-type">Int</span>, <span class="code-property">todayGoal</span>: <span class="code-type">Bool</span>) {</span>
</div>
<div class="code-line">
    <span class="line-number">7</span>
    <span class="code-text">        <span class="code-keyword">guard</span> <span class="code-type">ActivityAuthorizationInfo</span>().<span class="code-property">areActivitiesEnabled</span> <span class="code-keyword">else</span> {</span>
</div>
<div class="code-line">
    <span class="line-number">8</span>
    <span class="code-text">            <span class="code-function">print</span>(<span class="code-string">"Live Activities sind nicht aktiviert"</span>)</span>
</div>
<div class="code-line">
    <span class="line-number">9</span>
    <span class="code-text">            <span class="code-keyword">return</span></span>
</div>
<div class="code-line">
    <span class="line-number">10</span>
    <span class="code-text">        }</span>
</div>
<div class="code-line">
    <span class="line-number">11</span>
    <span class="code-text">        </span>
</div>
<div class="code-line">
    <span class="line-number">12</span>
    <span class="code-text">        <span class="code-keyword">let</span> <span class="code-property">attributes</span> = <span class="code-type">DreamStreakAttributes</span>()</span>
</div>`
    },
    {
        title: "DreamPassRenderer.swift",
        content: `<div class="code-line">
    <span class="line-number">1</span>
    <span class="code-text"><span class="code-keyword">@MainActor</span></span>
</div>
<div class="code-line">
    <span class="line-number">2</span>
    <span class="code-text"><span class="code-keyword">class</span> <span class="code-type">DreamPassRenderer</span> {</span>
</div>
<div class="code-line">
    <span class="line-number">3</span>
    <span class="code-text">    <span class="code-keyword">static</span> <span class="code-keyword">func</span> <span class="code-function">renderToImage</span>(<span class="code-property">view</span>: <span class="code-keyword">some</span> <span class="code-type">View</span>) -> <span class="code-type">UIImage</span>? {</span>
</div>
<div class="code-line">
    <span class="line-number">4</span>
    <span class="code-text">        <span class="code-keyword">let</span> <span class="code-property">controller</span> = <span class="code-type">UIHostingController</span>(<span class="code-property">rootView</span>: <span class="code-property">view</span>)</span>
</div>
<div class="code-line">
    <span class="line-number">5</span>
    <span class="code-text">        <span class="code-property">controller</span>.<span class="code-property">view</span>.<span class="code-property">backgroundColor</span> = <span class="code-type">UIColor</span>.<span class="code-property">clear</span></span>
</div>
<div class="code-line">
    <span class="line-number">6</span>
    <span class="code-text">        </span>
</div>
<div class="code-line">
    <span class="line-number">7</span>
    <span class="code-text">        <span class="code-keyword">let</span> <span class="code-property">targetSize</span> = <span class="code-type">CGSize</span>(<span class="code-property">width</span>: <span class="code-number">400</span>, <span class="code-property">height</span>: <span class="code-number">600</span>)</span>
</div>
<div class="code-line">
    <span class="line-number">8</span>
    <span class="code-text">        <span class="code-property">controller</span>.<span class="code-property">view</span>.<span class="code-property">bounds</span> = <span class="code-type">CGRect</span>(<span class="code-property">origin</span>: .<span class="code-property">zero</span>, <span class="code-property">size</span>: <span class="code-property">targetSize</span>)</span>
</div>
<div class="code-line">
    <span class="line-number">9</span>
    <span class="code-text">        </span>
</div>
<div class="code-line">
    <span class="line-number">10</span>
    <span class="code-text">        <span class="code-keyword">let</span> <span class="code-property">renderer</span> = <span class="code-type">UIGraphicsImageRenderer</span>(<span class="code-property">size</span>: <span class="code-property">targetSize</span>)</span>
</div>
<div class="code-line">
    <span class="line-number">11</span>
    <span class="code-text">        <span class="code-keyword">return</span> <span class="code-property">renderer</span>.<span class="code-function">image</span> { <span class="code-property">context</span> <span class="code-keyword">in</span></span>
</div>
<div class="code-line">
    <span class="line-number">12</span>
    <span class="code-text">            <span class="code-property">controller</span>.<span class="code-property">view</span>.<span class="code-function">drawHierarchy</span>(<span class="code-property">in</span>: <span class="code-property">controller</span>.<span class="code-property">view</span>.<span class="code-property">bounds</span>, <span class="code-property">afterScreenUpdates</span>: <span class="code-keyword">true</span>)</span>
</div>`
    }
];

let currentCodeIndex = 0;
let codeAutoRotateInterval;
let codeCarouselIsAnimating = false;

function initializeCodeCarousel() {
    const codeStack = document.getElementById('codeStack');
    if (!codeStack) return;
    
    // Create all code windows
    codeSnippets.forEach((snippet, index) => {
        const codeWindow = document.createElement('div');
        codeWindow.className = 'code-window';
        codeWindow.innerHTML = `
            <div class="code-header">
                <div class="code-dots">
                    <span class="dot red"></span>
                    <span class="dot yellow"></span>
                    <span class="dot green"></span>
                </div>
                <span class="code-title">${snippet.title}</span>
            </div>
            <div class="code-content">${snippet.content}</div>
        `;
        codeStack.appendChild(codeWindow);
    });
    
    // Create indicators
    const indicatorsContainer = document.getElementById('codeIndicators');
    if (indicatorsContainer) {
        codeSnippets.forEach((_, index) => {
            const indicator = document.createElement('div');
            indicator.className = `code-indicator ${index === 0 ? 'active' : ''}`;
            indicator.addEventListener('click', () => {
                showCodeCarousel(index);
                // Auto-Rotation direkt wieder starten
                setTimeout(startCodeAutoRotate, 100);
            });
            indicatorsContainer.appendChild(indicator);
        });
    }
    
    // Navigation buttons
    const prevBtn = document.getElementById('prevCode');
    const nextBtn = document.getElementById('nextCode');
    
    if (prevBtn) {
        prevBtn.addEventListener('click', () => {
            showCodeCarousel(currentCodeIndex - 1);
            // Auto-Rotation direkt wieder starten
            setTimeout(startCodeAutoRotate, 100);
        });
    }
    
    if (nextBtn) {
        nextBtn.addEventListener('click', () => {
            showCodeCarousel(currentCodeIndex + 1);
            // Auto-Rotation direkt wieder starten
            setTimeout(startCodeAutoRotate, 100);
        });
    }
    
    // Swipe-Funktionalität entfernt - nur Buttons für Navigation
    
    // Keyboard navigation
    document.addEventListener('keydown', (e) => {
        if (codeStack.matches(':hover') || document.activeElement.closest('.code-carousel')) {
            if (e.key === 'ArrowLeft') {
                e.preventDefault();
                showCodeCarousel(currentCodeIndex - 1);
                resetCodeAutoRotate();
            } else if (e.key === 'ArrowRight') {
                e.preventDefault();
                showCodeCarousel(currentCodeIndex + 1);
                resetCodeAutoRotate();
            }
        }
    });
    
    // Set initial stack order
    updateStackOrder();
    
    // Start auto rotation
    startCodeAutoRotate();
}

// Swipe-Handler entfernt - nur Button-Navigation

function showCodeCarousel(index) {
    // Prevent double animations
    if (codeCarouselIsAnimating) return;
    
    // Handle wrap around
    if (index < 0) index = codeSnippets.length - 1;
    if (index >= codeSnippets.length) index = 0;
    
    if (index === currentCodeIndex) return;
    
    codeCarouselIsAnimating = true;
    
    // Aktuelle Karte fade-out (wie bei Swipe-Animation)
    const currentCard = document.querySelector('.code-window:nth-child(' + (currentCodeIndex + 1) + ')');
    if (currentCard) {
        currentCard.style.transition = 'all 0.5s ease-out';
        currentCard.style.opacity = '0';
        currentCard.style.transform = 'scale(0.8)';
    }
    
    // Index updaten
    currentCodeIndex = index;
    
    // Nach kurzer Pause neue Karten anordnen
    setTimeout(() => {
        // Alle Karten zurücksetzen
        document.querySelectorAll('.code-window').forEach(window => {
            window.style.transition = 'all 0.6s ease-out';
            window.style.transform = '';
            window.style.opacity = '';
            window.style.zIndex = '';
        });
        
        // Stack-Order setzen
        updateStackOrder();
        
        // Update indicators
        document.querySelectorAll('.code-indicator').forEach((indicator, i) => {
            indicator.classList.toggle('active', i === index);
        });
        
        // Animation lock freigeben
        setTimeout(() => {
            codeCarouselIsAnimating = false;
        }, 600);
    }, 250);
}

function updateStackOrder() {
    const codeWindows = document.querySelectorAll('.code-window');
    
    codeWindows.forEach((window, index) => {
        // Calculate position in stack relative to current index
        let stackPosition = (index - currentCodeIndex + codeSnippets.length) % codeSnippets.length;
        
        // Add consistent transition for smooth animation
        window.style.transition = 'all 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94)';
        
        if (stackPosition === 0) {
            // Front card
            window.style.zIndex = 10;
            window.style.transform = 'translateY(0px) scale(1) rotateY(0deg)';
            window.style.opacity = '1';
        } else if (stackPosition === 1) {
            // Second card
            window.style.zIndex = 9;
            window.style.transform = 'translateY(15px) scale(0.95) rotateY(-8deg)';
            window.style.opacity = '0.8';
        } else if (stackPosition === 2) {
            // Third card
            window.style.zIndex = 8;
            window.style.transform = 'translateY(30px) scale(0.9) rotateY(-16deg)';
            window.style.opacity = '0.6';
        } else if (stackPosition === 3) {
            // Fourth card
            window.style.zIndex = 7;
            window.style.transform = 'translateY(45px) scale(0.85) rotateY(-24deg)';
            window.style.opacity = '0.4';
        } else {
            // Hidden cards - ganz nach hinten
            window.style.zIndex = 0;
            window.style.transform = 'translateY(80px) scale(0.75) rotateY(-40deg)';
            window.style.opacity = '0.1';
        }
        
        // Clear transition after animation to prevent conflicts
        setTimeout(() => {
            window.style.transition = '';
        }, 900);
    });
}

function startCodeAutoRotate() {
    // Zuerst alte Rotation stoppen
    clearInterval(codeAutoRotateInterval);
    
    // Neue konsistente Rotation starten
    codeAutoRotateInterval = setInterval(() => {
        showCodeCarousel(currentCodeIndex + 1);
    }, 5000); // Konsistente 5 Sekunden
}

function stopCodeAutoRotate() {
    clearInterval(codeAutoRotateInterval);
}

