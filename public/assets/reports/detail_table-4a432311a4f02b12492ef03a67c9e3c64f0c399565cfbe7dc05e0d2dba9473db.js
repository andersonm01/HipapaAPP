// detail_table.js — tabla de detalle paginada.
import { rowsSkeletonHTML } from 'reports/skeletons';

export function renderLoading() {
  const tbody = document.getElementById('detailTableBody');
  if (tbody) tbody.innerHTML = rowsSkeletonHTML(7, 5);
}

export function renderOrdersTable(orders) {
  const tbody = document.getElementById('detailTableBody');
  if (!tbody) return;

  if (!orders.length) {
    tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted py-4">Sin pedidos en este período</td></tr>';
    return;
  }

  tbody.innerHTML = orders.map(o => `
    <tr>
      <td>${o.numero_orden || o.id}</td>
      <td>${o.cliente || ''}</td>
      <td>${o.mesero || ''}</td>
      <td>${o.tipo_servicio || ''}</td>
      <td>${o.tipo_pago || ''}</td>
      <td class="text-end fw-bold">$${Number(o.monto_pagado).toLocaleString()}</td>
      <td class="text-muted small">${o.created_at}</td>
    </tr>`).join('');
}

export function renderPagination(meta, onPageChange) {
  const summary  = document.getElementById('paginationSummary');
  const controls = document.getElementById('paginationControls');
  if (!summary || !controls) return;

  if (!meta.total) {
    summary.textContent = 'Sin resultados';
    controls.innerHTML = '';
    return;
  }

  const start = (meta.page - 1) * meta.per_page + 1;
  const end   = Math.min(meta.page * meta.per_page, meta.total);
  summary.textContent = `Mostrando ${start}–${end} de ${meta.total}`;

  const prevDisabled = meta.page <= 1 ? 'disabled' : '';
  const nextDisabled = meta.page >= meta.total_pages ? 'disabled' : '';
  controls.innerHTML = `
    <button type="button" class="rp-page-btn" id="rpPrevPage" ${prevDisabled}>‹ Anterior</button>
    <span class="rp-page-btn active">${meta.page} / ${meta.total_pages}</span>
    <button type="button" class="rp-page-btn" id="rpNextPage" ${nextDisabled}>Siguiente ›</button>
  `;

  const prevBtn = document.getElementById('rpPrevPage');
  const nextBtn = document.getElementById('rpNextPage');
  if (prevBtn) prevBtn.addEventListener('click', () => onPageChange(meta.page - 1));
  if (nextBtn) nextBtn.addEventListener('click', () => onPageChange(meta.page + 1));
};
