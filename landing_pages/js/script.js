// ===================================
// CyberPlaza Website JavaScript
// Futuristic Interactions & Animations
// ===================================

// === Initialize ===
document.addEventListener('DOMContentLoaded', () => {
    initNavigation();
    initScrollAnimations();
    initCounters();
    initChartAnimations();
    init3DEffects();
    initParallax();
});

// === Navigation ===
function initNavigation() {
    const nav = document.querySelector('.navbar');
    const hamburger = document.querySelector('.hamburger');
    const navMenu = document.querySelector('.nav-menu');
    
    // Scroll effect
    window.addEventListener('scroll', () => {
        if (window.scrollY > 100) {
            nav.style.background = 'rgba(10, 14, 39, 0.95)';
            nav.style.boxShadow = '0 10px 30px rgba(0, 0, 0, 0.3)';
        } else {
            nav.style.background = 'rgba(10, 14, 39, 0.8)';
            nav.style.boxShadow = 'none';
        }
    });
    
    // Mobile menu toggle
    if (hamburger) {
        hamburger.addEventListener('click', () => {
            hamburger.classList.toggle('active');
            navMenu.classList.toggle('active');
        });
    }
    
    // Smooth scroll for nav links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// === Scroll Animations ===
function initScrollAnimations() {
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);
    
    // Observe all cards and sections
    const elements = document.querySelectorAll('.glass-card, .feature-card, .timeline-item, .team-card');
    elements.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });
}

// === Animated Counters ===
function initCounters() {
    const counters = document.querySelectorAll('.stat-number');
    const speed = 2000; // Animation duration in ms
    
    const observerOptions = {
        threshold: 0.5
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const counter = entry.target;
                const target = parseFloat(counter.getAttribute('data-target'));
                const increment = target / (speed / 16); // 60fps
                let current = 0;
                
                const updateCounter = () => {
                    current += increment;
                    if (current < target) {
                        counter.textContent = Math.floor(current).toLocaleString();
                        requestAnimationFrame(updateCounter);
                    } else {
                        counter.textContent = target % 1 === 0 ? target.toLocaleString() : target.toFixed(1);
                    }
                };
                
                updateCounter();
                observer.unobserve(counter);
            }
        });
    }, observerOptions);
    
    counters.forEach(counter => observer.observe(counter));
}

// === Chart Animations ===
function initChartAnimations() {
    const chartBars = document.querySelectorAll('.chart-bar');
    
    const observerOptions = {
        threshold: 0.3
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const bar = entry.target;
                setTimeout(() => {
                    bar.style.width = `calc(${bar.parentElement.style.getPropertyValue('--percent')} * 1%)`;
                }, 200);
                observer.unobserve(bar);
            }
        });
    }, observerOptions);
    
    chartBars.forEach(bar => {
        bar.style.width = '0';
        bar.style.transition = 'width 1.5s cubic-bezier(0.65, 0, 0.35, 1)';
        observer.observe(bar);
    });
}

// === 3D Card Effects ===
function init3DEffects() {
    const cards = document.querySelectorAll('.card-3d, .glass-card');
    
    cards.forEach(card => {
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            
            const rotateX = (y - centerY) / 10;
            const rotateY = (centerX - x) / 10;
            
            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateZ(10px)`;
        });
        
        card.addEventListener('mouseleave', () => {
            card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) translateZ(0)';
        });
    });
}

// === Parallax Effect ===
function initParallax() {
    window.addEventListener('scroll', () => {
        const scrolled = window.pageYOffset;
        
        // Parallax for floating cards
        const floatingCards = document.querySelectorAll('.floating-card');
        floatingCards.forEach((card, index) => {
            const speed = 0.05 * (index + 1);
            card.style.transform = `translateY(${scrolled * speed}px)`;
        });
        
        // Parallax for hero background
        const heroBg = document.querySelector('.hero-bg');
        if (heroBg) {
            heroBg.style.transform = `translateY(${scrolled * 0.3}px)`;
        }
    });
}

// === Cursor Effect (Optional Premium Feature) ===
function initCursorEffect() {
    const cursor = document.createElement('div');
    cursor.classList.add('custom-cursor');
    document.body.appendChild(cursor);
    
    const cursorGlow = document.createElement('div');
    cursorGlow.classList.add('cursor-glow');
    document.body.appendChild(cursorGlow);
    
    document.addEventListener('mousemove', (e) => {
        cursor.style.left = e.clientX + 'px';
        cursor.style.top = e.clientY + 'px';
        
        cursorGlow.style.left = e.clientX + 'px';
        cursorGlow.style.top = e.clientY + 'px';
    });
    
    // Add hover effect for interactive elements
    const interactiveElements = document.querySelectorAll('a, button, .glass-card');
    interactiveElements.forEach(el => {
        el.addEventListener('mouseenter', () => {
            cursor.classList.add('cursor-hover');
            cursorGlow.classList.add('cursor-hover');
        });
        
        el.addEventListener('mouseleave', () => {
            cursor.classList.remove('cursor-hover');
            cursorGlow.classList.remove('cursor-hover');
        });
    });
}

// Uncomment to enable custom cursor
// initCursorEffect();

// === Button Ripple Effect ===
document.querySelectorAll('button').forEach(button => {
    button.addEventListener('click', function(e) {
        const ripple = document.createElement('span');
        const rect = this.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);
        const x = e.clientX - rect.left - size / 2;
        const y = e.clientY - rect.top - size / 2;
        
        ripple.style.width = ripple.style.height = size + 'px';
        ripple.style.left = x + 'px';
        ripple.style.top = y + 'px';
        ripple.classList.add('ripple');
        
        this.appendChild(ripple);
        
        setTimeout(() => ripple.remove(), 600);
    });
});

// === Floating Animation for Cards ===
function initFloatingCards() {
    const floatingCards = document.querySelectorAll('.floating-card');
    floatingCards.forEach((card, index) => {
        card.style.animationDelay = `${index * 0.5}s`;
    });
}

initFloatingCards();

// === Loading Screen (Optional) ===
function initLoadingScreen() {
    const loading = document.createElement('div');
    loading.classList.add('loading-screen');
    loading.innerHTML = `
        <div class="loading-content">
            <div class="logo">
                <span class="logo-cyber">CYBER</span><span class="logo-plaza">PLAZA</span>
            </div>
            <div class="loading-bar">
                <div class="loading-progress"></div>
            </div>
        </div>
    `;
    document.body.appendChild(loading);
    
    window.addEventListener('load', () => {
        setTimeout(() => {
            loading.style.opacity = '0';
            setTimeout(() => loading.remove(), 500);
        }, 1000);
    });
}

// Uncomment to enable loading screen
// initLoadingScreen();

// === Dynamic Background Particles ===
function initParticles() {
    const hero = document.querySelector('.hero');
    const particlesContainer = document.createElement('div');
    particlesContainer.classList.add('particles');
    hero.appendChild(particlesContainer);
    
    for (let i = 0; i < 50; i++) {
        const particle = document.createElement('div');
        particle.classList.add('particle');
        particle.style.left = Math.random() * 100 + '%';
        particle.style.top = Math.random() * 100 + '%';
        particle.style.animationDuration = (Math.random() * 10 + 5) + 's';
        particle.style.animationDelay = Math.random() * 5 + 's';
        particlesContainer.appendChild(particle);
    }
}

// Uncomment to enable particles
// initParticles();

// === Smooth Reveal on Scroll ===
const revealElements = document.querySelectorAll('.feature-card, .stream-card, .timeline-item');
const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry, index) => {
        if (entry.isIntersecting) {
            setTimeout(() => {
                entry.target.classList.add('revealed');
            }, index * 100);
        }
    });
}, { threshold: 0.1 });

revealElements.forEach(el => revealObserver.observe(el));

// === Add CSS for Ripple Effect ===
const style = document.createElement('style');
style.textContent = `
    .ripple {
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.6);
        transform: scale(0);
        animation: ripple-animation 0.6s ease-out;
        pointer-events: none;
    }
    
    @keyframes ripple-animation {
        to {
            transform: scale(2);
            opacity: 0;
        }
    }
    
    .custom-cursor {
        width: 20px;
        height: 20px;
        border: 2px solid #00D4FF;
        border-radius: 50%;
        position: fixed;
        pointer-events: none;
        z-index: 9999;
        transform: translate(-50%, -50%);
        transition: all 0.1s ease;
    }
    
    .cursor-glow {
        width: 40px;
        height: 40px;
        background: radial-gradient(circle, rgba(0, 212, 255, 0.2) 0%, transparent 70%);
        border-radius: 50%;
        position: fixed;
        pointer-events: none;
        z-index: 9998;
        transform: translate(-50%, -50%);
        transition: all 0.15s ease;
    }
    
    .cursor-hover {
        transform: translate(-50%, -50%) scale(1.5);
    }
    
    .particles {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
        pointer-events: none;
    }
    
    .particle {
        position: absolute;
        width: 2px;
        height: 2px;
        background: #00D4FF;
        border-radius: 50%;
        animation: particle-float linear infinite;
        box-shadow: 0 0 10px #00D4FF;
    }
    
    @keyframes particle-float {
        0% {
            transform: translateY(0) translateX(0);
            opacity: 0;
        }
        10% {
            opacity: 1;
        }
        90% {
            opacity: 1;
        }
        100% {
            transform: translateY(-100vh) translateX(50px);
            opacity: 0;
        }
    }
    
    .loading-screen {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: #0A0E27;
        z-index: 10000;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: opacity 0.5s;
    }
    
    .loading-content {
        text-align: center;
    }
    
    .loading-bar {
        width: 300px;
        height: 4px;
        background: rgba(255, 255, 255, 0.1);
        border-radius: 2px;
        margin-top: 30px;
        overflow: hidden;
    }
    
    .loading-progress {
        height: 100%;
        background: linear-gradient(90deg, #0052FF, #00D4FF);
        width: 0;
        animation: loading 2s ease-in-out forwards;
    }
    
    @keyframes loading {
        to {
            width: 100%;
        }
    }
    
    .revealed {
        opacity: 1 !important;
        transform: translateY(0) !important;
    }
`;
document.head.appendChild(style);

// === Performance Optimization ===
// Debounce function for scroll events
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

// Optimized scroll handler
const optimizedScroll = debounce(() => {
    // Your scroll logic here
}, 10);

window.addEventListener('scroll', optimizedScroll);

console.log('🚀 CyberPlaza Website Initialized');
console.log('💎 Futuristic UI Loaded Successfully');
