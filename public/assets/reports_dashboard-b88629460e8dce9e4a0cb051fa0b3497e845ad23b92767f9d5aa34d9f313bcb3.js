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
  today: 'Hoy', last_7_days: 'Últimos 7 días', month: 'Este mes',
  quarter: 'Trimestre', year: 'Este año', custom: 'Período personalizado'
};

let currentFilters = null;
let currentGranularity = 'day';

// Turbo reemplaza el <body> completo en cada navegación dentro de la app
// (nodos nuevos, sin listeners previos), así que re-inicializar en cada
// turbo:load es seguro y necesario — no hace falta un guard "ya inicializado".
document.addEventListener('turbo:load', initReportsDashboard);

function initReportsDashboard() {
  if (!document.getElementById('kpiCards')) return; // esta página no es /reportes

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
};
