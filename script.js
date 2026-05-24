/**
 * script.js — Portfolio interactions
 * Responsibilities:
 *   1. Navbar scroll behaviour (transparent → glass)
 *   2. Mobile hamburger menu toggle
 *   3. IntersectionObserver scroll-reveal for skill & project cards
 *   4. Active nav link highlighting based on scroll position
 */

'use strict';

/* ─── 1. Navbar scroll ──────────────────────────────────────── */
const navbar = document.getElementById('navbar');

function onScroll() {
  if (window.scrollY > 50) {
    navbar.classList.add('scrolled');
  } else {
    navbar.classList.remove('scrolled');
  }
  highlightActiveLink();
}

window.addEventListener('scroll', onScroll, { passive: true });
onScroll(); // run once on load


/* ─── 2. Hamburger menu ─────────────────────────────────────── */
const hamburger = document.getElementById('hamburger');
const navLinks  = document.getElementById('nav-links');

hamburger.addEventListener('click', () => {
  hamburger.classList.toggle('open');
  navLinks.classList.toggle('open');
});

// Close menu when a link is clicked
navLinks.querySelectorAll('a').forEach(link => {
  link.addEventListener('click', () => {
    hamburger.classList.remove('open');
    navLinks.classList.remove('open');
  });
});


/* ─── 3. Scroll-reveal (IntersectionObserver) ──────────────── */
const revealTargets = document.querySelectorAll('.skill-card, .project-card');

const revealObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        revealObserver.unobserve(entry.target); // fire once only
      }
    });
  },
  { threshold: 0.12 }
);

revealTargets.forEach(el => revealObserver.observe(el));


/* ─── 4. Active nav link on scroll ─────────────────────────── */
const sections  = document.querySelectorAll('section[id]');
const navAnchors = document.querySelectorAll('.nav-links a[href^="#"]');

function highlightActiveLink() {
  let current = '';
  sections.forEach(section => {
    const sectionTop = section.offsetTop - 100;
    if (window.scrollY >= sectionTop) {
      current = section.getAttribute('id');
    }
  });

  navAnchors.forEach(a => {
    a.style.color = '';
    if (a.getAttribute('href') === `#${current}`) {
      a.style.color = 'var(--text-primary)';
    }
  });
}
