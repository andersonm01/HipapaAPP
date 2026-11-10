// Sidebar navigation: collapse toggle, mobile off-canvas, submenu groups.
const COLLAPSE_KEY = 'hipapa_sidebar_collapsed';
const GROUPS_KEY = 'hipapa_sidebar_open_groups';

function readOpenGroups() {
  try {
    return JSON.parse(localStorage.getItem(GROUPS_KEY) || '[]');
  } catch (e) {
    return [];
  }
}

function initSidebar() {
  const sidebar = document.querySelector('[data-sidebar]');
  if (!sidebar) return;
  // Guard por nodo: Turbo reemplaza el <body> en cada navegación, así que un
  // sidebar nuevo siempre se inicializa, pero el mismo nodo nunca dos veces
  // (enganchar los toggles dos veces los dejaría abriendo y cerrando a la vez).
  if (sidebar.dataset.sidebarInit === '1') return;
  sidebar.dataset.sidebarInit = '1';

  // ---- Collapse toggle (desktop/tablet) ----
  const collapseBtn = document.querySelector('[data-sidebar-collapse-toggle]');
  if (collapseBtn) {
    // Sync in case this render happened without the blocking <head> script (Turbo navigation).
    const collapsed = localStorage.getItem(COLLAPSE_KEY) === '1';
    document.documentElement.classList.toggle('sidebar-collapsed', collapsed);

    collapseBtn.addEventListener('click', function() {
      const isCollapsed = document.documentElement.classList.toggle('sidebar-collapsed');
      try { localStorage.setItem(COLLAPSE_KEY, isCollapsed ? '1' : '0'); } catch (e) {}
      collapseBtn.setAttribute('aria-label', isCollapsed ? 'Expandir menú' : 'Contraer menú');
    });
  }

  // ---- Mobile off-canvas ----
  const toggleBtn = document.querySelector('[data-sidebar-toggle]');
  const closeBtn = document.querySelector('[data-sidebar-close]');
  const overlay = document.querySelector('[data-sidebar-overlay]');

  function openMobile() {
    sidebar.classList.add('mobile-open');
    if (overlay) overlay.classList.add('mobile-open');
    document.documentElement.classList.add('no-scroll');
    if (toggleBtn) toggleBtn.setAttribute('aria-expanded', 'true');
  }

  function closeMobile() {
    sidebar.classList.remove('mobile-open');
    if (overlay) overlay.classList.remove('mobile-open');
    document.documentElement.classList.remove('no-scroll');
    if (toggleBtn) toggleBtn.setAttribute('aria-expanded', 'false');
  }

  if (toggleBtn) toggleBtn.addEventListener('click', openMobile);
  if (closeBtn) closeBtn.addEventListener('click', closeMobile);
  if (overlay) overlay.addEventListener('click', closeMobile);

  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && sidebar.classList.contains('mobile-open')) closeMobile();
  });

  // Closing on link click keeps the off-canvas menu from staying open while
  // the browser paints the next (Turbo-navigated) page underneath it.
  sidebar.querySelectorAll('.sidebar-link, .sidebar-sublink').forEach(function(link) {
    link.addEventListener('click', closeMobile);
  });

  // ---- Submenu groups ----
  const openGroups = readOpenGroups();
  sidebar.querySelectorAll('[data-sidebar-group]').forEach(function(group) {
    const name = group.getAttribute('data-group-name');
    if (!group.classList.contains('open') && openGroups.includes(name)) {
      group.classList.add('open');
    }
  });

  sidebar.querySelectorAll('[data-sidebar-group-toggle]').forEach(function(btn) {
    btn.addEventListener('click', function() {
      const group = btn.closest('[data-sidebar-group]');
      if (!group) return;
      const name = group.getAttribute('data-group-name');
      const isOpen = group.classList.toggle('open');

      const stored = readOpenGroups().filter(function(n) { return n !== name; });
      if (isOpen) stored.push(name);
      try { localStorage.setItem(GROUPS_KEY, JSON.stringify(stored)); } catch (e) {}
    });
  });
}

// sidebar.js se importa desde un <script type="module"> al final del layout,
// que es asíncrono: en la primera carga con la caché fría Turbo puede terminar
// de renderizar y disparar "turbo:load" ANTES de que este módulo llegue a
// registrar el listener de abajo — initSidebar() nunca corre y el menú queda
// muerto (los grupos no abren) hasta recargar, donde el módulo ya está en
// caché y alcanza a llegar a tiempo. Si el documento ya terminó de parsear
// cuando corre este código, turbo:load ya pasó: hay que inicializar ahora.
// Mismo arreglo que en home.js y reports_dashboard.js.
if (document.readyState !== 'loading') {
  initSidebar();
}
document.addEventListener('turbo:load', initSidebar);
