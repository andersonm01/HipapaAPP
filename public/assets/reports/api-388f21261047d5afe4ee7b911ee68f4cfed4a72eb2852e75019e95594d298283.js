// api.js — helpers fetch para el dashboard de reportes.

function apiBase() {
  return document.getElementById('reports-data')?.dataset.apiBase || '/api/v1/reports';
}

function buildQuery(filters, extra = {}) {
  const params = new URLSearchParams();
  Object.entries({ ...filters, ...extra }).forEach(([key, value]) => {
    if (value !== null && value !== undefined && value !== '') params.set(key, value);
  });
  return params.toString();
}

async function getJSON(url) {
  const res = await fetch(url, { headers: { Accept: 'application/json' } });
  if (!res.ok) {
    let message = `Error al cargar datos (${res.status})`;
    try {
      const data = await res.json();
      if (data && data.error) message = data.error;
    } catch { /* respuesta sin JSON, usar mensaje genérico */ }
    throw new Error(message);
  }
  return res.json();
}

export function fetchSummary(filters) {
  return getJSON(`${apiBase()}/summary?${buildQuery(filters)}`);
}

export function fetchTrend(filters, granularity) {
  return getJSON(`${apiBase()}/trend?${buildQuery(filters, { granularity })}`);
}

export function fetchOrders(filters, page, perPage) {
  return getJSON(`${apiBase()}/orders?${buildQuery(filters, { page, per_page: perPage })}`);
}

export function csvExportUrl(filters) {
  return `${apiBase()}/orders_csv?${buildQuery(filters)}`;
};
