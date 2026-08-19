// Landing page: navbar móvil, navbar sólido al hacer scroll, filtro de menú por categoría, scroll-reveal.

function initLandingNavbar() {
  const navbar = document.querySelector('[data-landing-navbar]');
  if (!navbar) return;

  function onScroll() {
    navbar.classList.toggle('scrolled', window.scrollY > 12);
  }
  onScroll();
  window.addEventListener('scroll', onScroll, { passive: true });

  const toggle = document.querySelector('[data-landing-nav-toggle]');
  const panel = document.querySelector('[data-landing-nav-panel]');
  const overlay = document.querySelector('[data-landing-nav-overlay]');

  function closeMenu() {
    if (panel) panel.classList.remove('open');
    if (overlay) overlay.classList.remove('open');
    if (toggle) toggle.setAttribute('aria-expanded', 'false');
    document.documentElement.classList.remove('no-scroll');
  }

  function openMenu() {
    if (panel) panel.classList.add('open');
    if (overlay) overlay.classList.add('open');
    if (toggle) toggle.setAttribute('aria-expanded', 'true');
    document.documentElement.classList.add('no-scroll');
  }

  if (toggle) {
    toggle.addEventListener('click', function() {
      const isOpen = panel && panel.classList.contains('open');
      if (isOpen) closeMenu(); else openMenu();
    });
  }
  if (overlay) overlay.addEventListener('click', closeMenu);
  if (panel) {
    panel.querySelectorAll('a').forEach(function(link) {
      link.addEventListener('click', closeMenu);
    });
  }
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeMenu();
  });
}

function initMenuTabs() {
  const tabsWrap = document.querySelector('[data-menu-tabs]');
  const grid = document.querySelector('[data-menu-grid]');
  if (!tabsWrap || !grid) return;

  const tabs = tabsWrap.querySelectorAll('[data-menu-tab]');
  const items = grid.querySelectorAll('[data-menu-category]');

  function showCategory(category) {
    items.forEach(function(item) {
      const show = category === 'all' || item.getAttribute('data-menu-category') === category;
      item.style.display = show ? '' : 'none';
    });
  }

  tabs.forEach(function(tab) {
    tab.addEventListener('click', function() {
      tabs.forEach(function(t) { t.classList.remove('active'); });
      tab.classList.add('active');
      showCategory(tab.getAttribute('data-menu-tab'));
    });
  });

  // Filtrar de entrada según la pestaña marcada como activa en el HTML
  // (por defecto, la primera categoría — Papas).
  const initialTab = tabsWrap.querySelector('.landing-menu-tab.active');
  if (initialTab) showCategory(initialTab.getAttribute('data-menu-tab'));
}

function initScrollReveal() {
  const items = document.querySelectorAll('[data-reveal]');
  if (!items.length) return;

  if (typeof IntersectionObserver === 'undefined') {
    items.forEach(function(el) { el.classList.add('revealed'); });
    return;
  }

  const observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        entry.target.classList.add('revealed');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });

  items.forEach(function(el) { observer.observe(el); });
}

// Enlaces internos tipo "#nosotros" hacen scroll suave sin tocar la URL.
// Si dejamos que el navegador navegue de forma nativa a un ancla, el
// #hash queda pegado en la barra de direcciones y el navegador lo guarda
// en el historial — en el celular eso hace que el autocompletado del
// dominio termine sugiriendo la página ya scrolleada a esa sección en
// vez de la portada.
function initAnchorLinks() {
  document.querySelectorAll('.landing-body a[href^="#"]').forEach(function(link) {
    const hash = link.getAttribute('href');
    if (!hash || hash.length < 2) return;

    link.addEventListener('click', function(e) {
      const target = document.querySelector(hash);
      if (!target) return;
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });
}

function initLanding() {
  if (!document.querySelector('.landing-body')) return;
  initLandingNavbar();
  initMenuTabs();
  initScrollReveal();
  initAnchorLinks();
}

document.addEventListener('turbo:load', initLanding);
