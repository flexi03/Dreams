// ===== DREAMS WEBSITE JAVASCRIPT =====

// DOM Content Loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeNavigation();
    initializeScrollEffects();
    initializeLazyLoading();
    initializeAnimations();
});

// ===== NAVIGATION =====
function initializeNavigation() {
    const navToggle = document.getElementById('navToggle');
    const navbar = document.querySelector('.navbar');
    const navLinks = document.querySelector('.nav-links');
    
    // Mobile menu toggle
    if (navToggle) {
        navToggle.addEventListener('click', function() {
            navLinks.classList.toggle('nav-active');
            navToggle.classList.toggle('nav-toggle-active');
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