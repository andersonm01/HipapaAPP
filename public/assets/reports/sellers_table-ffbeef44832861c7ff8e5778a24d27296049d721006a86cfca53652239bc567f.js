// sellers_table.js — ranking de ventas por mesero.
import { rowsSkeletonHTML } from 'reports/skeletons';

function initial(name) {
  return (name || '?').trim().charAt(0).toUpperCase() || '?';
}

export function renderLoading() {
  const tbody = document.getElementById('sellersTableBody');
  if (tbody) tbody.innerHTML = rowsSkeletonHTML(4, 3);
}

export function renderSellers(sellers) {
  const tbody = document.getElementById('sellersTableBody');
  if (!tbody) return;

  if (!sellers.length) {
    tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-4">Sin datos para este período</td></tr>';
    return;
  }

  tbody.innerHTML = sellers.map(m => `
    <tr>
      <td>
        <span class="badge rounded-circle text-white me-1"
              style="width:22px;height:22px;font-size:.62rem;background:#6366f1;
                     display:inline-flex;align-items:center;justify-content:center;">
          ${initial(m.mesero)}
        </span>
        <span class="fw-semibold">${m.mesero}</span>
      </td>
      <td class="text-end text-muted">${m.orders}</td>
      <td class="text-end fw-bold">$${Number(m.revenue).toLocaleString()}</td>
      <td class="text-end text-muted small d-none d-sm-table-cell">
        $${Number(m.avg).toLocaleString(undefined, { maximumFractionDigits: 2 })}
      </td>
    </tr>`).join('');
};
