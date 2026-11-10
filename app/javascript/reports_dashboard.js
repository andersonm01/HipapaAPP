// reports_dashboard.js — orquesta el dashboard de /reportes: filtros, fetch
// a la API JSON y render de cada sección.
import { fetchSummary, fetchTrend, fetchOrders, csvExportUrl } from 'reports/api';
import { initFilters } from 'reports/filters';
import { renderKpis, renderLoading as kpiLoading } from 'reports/kpi_cards';
import { initGranularityToggle, renderTrend } from 'reports/trend_chart';
import { renderTopProducts } from 'reports/top_products_chart';
import { renderHeatmap } from 'reports/heatmap';
import { renderSellers, renderLoading as sellersLoading } from 'reports/sellers_table';
import { renderSecondaryCharts } from 'reports/secondary_charts';
import { renderInsights } from 'reports/insights';
import { renderOrdersTable, renderPagination, renderLoading as tableLoading } from 'reports/detail_table';

const PERIOD_LABELS = {
  today: 'Hoy', yesterday: 'Ayer', last_7_days: 'Últimos 7 días', month: 'Este mes',
  quarter: 'Trimestre', year: 'Este año', custom: 'Período personalizado'
};

let currentFilters = null;
let currentGranularity = 'day';

// Turbo reemplaza el <body> completo en cada navegación dentro de la app
// (nodos nuevos, sin listeners previos), así que re-inicializar en cada
// turbo:load es seguro: el guard de bootstrap() es por nodo, no global.
document.addEventListener('turbo:load', bootstrap);

// La PRIMERA vez que se entra a /reportes por una navegación Turbo este
// módulo todavía no existe: Turbo inserta el <script type="module"> del final
// de la vista DESPUÉS de renderizar y dispara turbo:load de inmediato, así que
// el listener de arriba se registraba cuando el evento ya había pasado y el
// dashboard quedaba vacío hasta recargar a mano. Por eso también arrancamos al
// evaluarse el módulo; el guard por nodo evita el doble init cuando los dos
// caminos se cruzan (en un reload normal el módulo corre antes de turbo:load).
bootstrap();

function bootstrap() {
  const root = document.getElementById('kpiCards');
  if (!root) return;                         // esta página no es /reportes
  if (root.dataset.rpBooted === '1') return; // ya inicializado para este DOM
  root.dataset.rpBooted = '1';
  waitForChart(initReportsDashboard);
}

// Chart.js se carga vía <script src> dentro de la vista de /reportes (no del
// <head> del layout). En un reload normal el navegador bloquea el parseo y
// ya está listo para cuando corre este módulo, pero en una navegación Turbo
// ese script se inserta de forma asíncrona: turbo:load puede disparar antes
// de que "Chart" exista, rompiendo todos los renders con Chart.js. Por eso
// esperamos explícitamente a que termine de cargar.
function waitForChart(cb) {
  if (window.Chart) { cb(); return; }
  const script = document.querySelector('script[src*="chart.js"]');
  if (!script) { cb(); return; }
  script.addEventListener('load', cb, { once: true });
}

function initReportsDashboard() {
  currentGranularity = 'day';
  initGranularityToggle(granularity => {
    currentGranularity = granularity;
    loadTrend();
  });

  currentFilters = initFilters(filters => {
    currentFilters = filters;
    loadAll();
  });

  loadAll();
}

function updatePeriodLabel() {
  const label = document.getElementById('periodLabel');
  if (!label) return;
  const name = PERIOD_LABELS[currentFilters.period] || currentFilters.period;
  const extra = (currentFilters.period === 'custom' && currentFilters.from && currentFilters.to)
    ? ` (${currentFilters.from} → ${currentFilters.to})`
    : '';
  label.innerHTML = `<i class="bi bi-calendar3 me-1"></i>Mostrando datos de: <strong>${name}</strong>${extra}`;
}

function updateCsvLinks() {
  const url = csvExportUrl(currentFilters);
  document.querySelectorAll('.rp-csv-link').forEach(a => { a.href = url; });
}

async function loadAll() {
  updatePeriodLabel();
  updateCsvLinks();
  kpiLoading();
  sellersLoading();
  tableLoading();

  try {
    const summary = await fetchSummary(currentFilters);
    renderKpis(summary.kpis);
    renderTopProducts(summary.top_products);
    renderHeatmap(summary.heatmap);
    renderSellers(summary.sellers);
    renderSecondaryCharts(summary);
    renderInsights(summary.insights);
  } catch (err) {
    console.error('Reportes: error al cargar el resumen', err);
  }

  loadTrend();
  loadOrdersPage(1);
}

async function loadTrend() {
  try {
    const trend = await fetchTrend(currentFilters, currentGranularity);
    renderTrend(trend.data);
  } catch (err) {
    console.error('Reportes: error al cargar la tendencia', err);
  }
}

async function loadOrdersPage(page) {
  try {
    const result = await fetchOrders(currentFilters, page, 25);
    renderOrdersTable(result.data);
    renderPagination(result.meta, loadOrdersPage);
  } catch (err) {
    console.error('Reportes: error al cargar el detalle', err);
  }
}
