// Landing pública de Hi Papa: navbar, menú móvil, filtro del menú por
// categoría, scroll reveal, parallax, barra de progreso, scroll-spy y el
// botón flotante de WhatsApp.
//
// Sin librerías: todo se apoya en IntersectionObserver + un único listener
// de scroll pasivo que escribe en un rAF, así que no hay layout thrashing
// ni dependencias que mantener.

const REDUCED_MOTION = typeof window.matchMedia === 'function' &&
  window.matchMedia('(prefers-reduced-motion: reduce)').matches;

/* ---------------------------------------------------------------
   Navbar: fondo sólido al bajar, drawer móvil y hamburguesa
   --------------------------------------------------------------- */
function initLandingNavbar(state) {
  const navbar = document.querySelector('[data-landing-navbar]');
  if (!navbar) return;

  state.navbar = navbar;

  const toggle = document.querySelector('[data-landing-nav-toggle]');
  const panel = document.querySelector('[data-landing-nav-panel]');
  const overlay = document.querySelector('[data-landing-nav-overlay]');

  function closeMenu() {
    if (panel) panel.classList.remove('open');
    if (overlay) overlay.classList.remove('open');
    if (toggle) {
      toggle.classList.remove('open');
      toggle.setAttribute('aria-expanded', 'false');
      toggle.setAttribute('aria-label', 'Abrir menú');
    }
    document.documentElement.classList.remove('no-scroll');
  }

  function openMenu() {
    if (panel) panel.classList.add('open');
    if (overlay) overlay.classList.add('open');
    if (toggle) {
      toggle.classList.add('open');
      toggle.setAttribute('aria-expanded', 'true');
      toggle.setAttribute('aria-label', 'Cerrar menú');
    }
    document.documentElement.classList.add('no-scroll');
  }

  if (toggle) {
    toggle.addEventListener('click', function () {
      if (panel && panel.classList.contains('open')) closeMenu(); else openMenu();
    });
  }
  if (overlay) overlay.addEventListener('click', closeMenu);
  if (panel) {
    panel.querySelectorAll('a').forEach(function (link) {
      link.addEventListener('click', closeMenu);
    });
  }
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeMenu();
  });
}

/* ---------------------------------------------------------------
   Menú: filtro por categoría
   --------------------------------------------------------------- */
function initMenuTabs() {
  const tabsWrap = document.querySelector('[data-menu-tabs]');
  const grid = document.querySelector('[data-menu-grid]');
  if (!tabsWrap || !grid) return;

  const tabs = Array.prototype.slice.call(tabsWrap.querySelectorAll('[data-menu-tab]'));
  const items = Array.prototype.slice.call(grid.querySelectorAll('[data-menu-category]'));
  if (!tabs.length || !items.length) return;

  function showCategory(category) {
    let visible = 0;
    items.forEach(function (item) {
      const show = item.getAttribute('data-menu-category') === category;
      item.style.display = show ? '' : 'none';
      if (!show) return;

      // Reinicia la animación de entrada de la tarjeta, escalonada, para que
      // cambiar de categoría se sienta como una transición y no como un salto.
      if (!REDUCED_MOTION) {
        item.style.animation = 'none';
        void item.offsetWidth; // fuerza reflow para poder relanzar la animación
        item.style.animation = '';
        item.style.animationDelay = Math.min(visible, 10) * 35 + 'ms';
      }
      visible += 1;
    });
  }

  tabs.forEach(function (tab) {
    tab.addEventListener('click', function () {
      tabs.forEach(function (t) {
        t.classList.remove('active');
        t.setAttribute('aria-selected', 'false');
      });
      tab.classList.add('active');
      tab.setAttribute('aria-selected', 'true');
      showCategory(tab.getAttribute('data-menu-tab'));
    });
  });

  const activo = tabsWrap.querySelector('.landing-menu-tab.active') || tabs[0];
  showCategory(activo.getAttribute('data-menu-tab'));
}

/* ---------------------------------------------------------------
   Scroll reveal
   --------------------------------------------------------------- */
function initScrollReveal() {
  const nodes = document.querySelectorAll('[data-reveal]');
  if (!nodes.length) return;

  // Sin IntersectionObserver (o con movimiento reducido) se muestra todo ya.
  if (REDUCED_MOTION || !('IntersectionObserver' in window)) {
    nodes.forEach(function (el) { el.classList.add('revealed'); });
    return;
  }

  const observer = new IntersectionObserver(function (entries) {
    entries.forEach(function (entry) {
      if (!entry.isIntersecting) return;
      const el = entry.target;
      const delay = parseInt(el.getAttribute('data-reveal-delay') || '0', 10);
      if (delay) el.style.transitionDelay = delay + 'ms';
      el.classList.add('revealed');
      observer.unobserve(el);
    });
  }, { threshold: 0.12, rootMargin: '0px 0px -7% 0px' });

  nodes.forEach(function (el) { observer.observe(el); });
}

/* ---------------------------------------------------------------
   Enlaces internos: deja el scroll suave nativo (las secciones ya
   tienen scroll-margin-top) y solo limpia el foco del drawer.
   --------------------------------------------------------------- */
function initAnchorLinks() {
  document.querySelectorAll('a[href^="#"]').forEach(function (link) {
    link.addEventListener('click', function (e) {
      const id = link.getAttribute('href');
      if (!id || id === '#') return;
      const target = document.querySelector(id);
      if (!target) return;
      e.preventDefault();
      target.scrollIntoView({ behavior: REDUCED_MOTION ? 'auto' : 'smooth', block: 'start' });
      history.replaceState(null, '', id);
    });
  });
}

/* ---------------------------------------------------------------
   Todo lo que depende del scroll, en un solo listener + rAF:
   navbar sólida, barra de progreso, parallax, scroll-spy y el FAB.
   --------------------------------------------------------------- */
function initScrollEffects(state) {
  const progress = document.querySelector('[data-scroll-progress]');
  const fab = document.querySelector('[data-wa-fab]');
  const parallaxEls = REDUCED_MOTION ? [] : Array.prototype.slice.call(document.querySelectorAll('[data-parallax]'));
  const navLinks = Array.prototype.slice.call(document.querySelectorAll('[data-nav-link]'));
  const sections = navLinks
    .map(function (link) { return document.getElementById(link.getAttribute('data-nav-link')); })
    .filter(Boolean);

  let ticking = false;

  function update() {
    ticking = false;
    const y = window.scrollY || window.pageYOffset || 0;

    if (state.navbar) state.navbar.classList.toggle('scrolled', y > 24);

    if (progress) {
      const alto = document.documentElement.scrollHeight - window.innerHeight;
      progress.style.transform = 'scaleX(' + (alto > 0 ? Math.min(y / alto, 1) : 0) + ')';
    }

    if (fab) fab.classList.toggle('visible', y > 420);

    parallaxEls.forEach(function (el) {
      const factor = parseFloat(el.getAttribute('data-parallax')) || 0.15;
      el.style.transform = 'translate3d(0,' + (y * factor).toFixed(1) + 'px,0)';
    });

    if (sections.length) {
      // La sección activa es la última cuyo inicio ya pasó la línea del navbar.
      const linea = y + window.innerHeight * 0.35;
      let actual = sections[0];
      sections.forEach(function (sec) {
        if (sec.offsetTop <= linea) actual = sec;
      });
      navLinks.forEach(function (link) {
        link.classList.toggle('active', link.getAttribute('data-nav-link') === actual.id);
      });
    }
  }

  function onScroll() {
    if (ticking) return;
    ticking = true;
    window.requestAnimationFrame(update);
  }

  window.addEventListener('scroll', onScroll, { passive: true });
  window.addEventListener('resize', onScroll, { passive: true });
  update();
}

function initLanding() {
  const body = document.querySelector('.landing-body');
  if (!body) return;
  // Guard por nodo: evita duplicar los listeners de scroll, los observers y
  // los handlers de los tabs si initLanding() llega a correr dos veces sobre
  // el mismo DOM. Turbo reemplaza el <body> en cada navegación, así que una
  // landing nueva sí se inicializa.
  if (body.dataset.landingInit === '1') return;
  body.dataset.landingInit = '1';

  const state = { navbar: null };
  initLandingNavbar(state);
  initMenuTabs();
  initScrollReveal();
  initAnchorLinks();
  initScrollEffects(state);
}

// landing.js se importa desde un <script type="module">, que es asíncrono: en
// la primera carga con la caché fría (por ejemplo después de un deploy, cuando
// cambian los digests) Turbo puede renderizar y disparar turbo:load ANTES de
// que el módulo llegue a registrar el listener de abajo, y la landing quedaba
// sin tabs de menú ni scroll reveal hasta recargar. Si el documento ya terminó
// de parsear cuando corre esto, hay que inicializar ahora mismo.
// Mismo arreglo que en home.js, sidebar.js, cocina.js y reports_dashboard.js.
if (document.readyState !== 'loading') {
  initLanding();
}
document.addEventListener('turbo:load', initLanding);
