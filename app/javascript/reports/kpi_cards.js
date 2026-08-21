// kpi_cards.js — tarjetas de KPIs principales con flecha de crecimiento.
import { kpiSkeletonHTML } from 'reports/skeletons';

const CONFIG = [
  { key: 'revenue',    label: 'Ventas totales',   icon: 'bi-cash-stack',          bg: '#ede9fe', fg: '#7c3aed', money: true,  decimals: 0 },
  { key: 'orders',     label: 'Pedidos',           icon: 'bi-receipt',             bg: '#dbeafe', fg: '#1d4ed8', money: false, decimals: 0 },
  { key: 'avg_ticket', label: 'Ticket promedio',   icon: 'bi-ticket-perforated',   bg: '#fef3c7', fg: '#d97706', money: true,  decimals: 2 }
];

function growthBadge(growth, prev) {
  if (growth > 0) return `<span class="badge bg-success-subtle text-success border border-success-subtle">▲ ${growth}%</span>`;
  if (growth < 0) return `<span class="badge bg-danger-subtle text-danger border border-danger-subtle">▼ ${Math.abs(growth)}%</span>`;
  if (prev > 0) return `<span class="badge bg-secondary-subtle text-secondary">→ igual</span>`;
  return '';
}

function fmt(value, decimals, money) {
  const n = Number(value).toLocaleString('es-CO', { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
  return money ? `$${n}` : n;
}

export function renderLoading() {
  const el = document.getElementById('kpiCards');
  if (el) el.innerHTML = kpiSkeletonHTML();
}

export function renderKpis(kpis) {
  const el = document.getElementById('kpiCards');
  if (!el) return;

  const cards = CONFIG.map(c => {
    const d = kpis[c.key];
    return `
      <div class="col-6 col-xl-3">
        <div class="rp-card d-flex align-items-center gap-3 p-3 h-100">
          <div class="kpi-icon" style="background:${c.bg};color:${c.fg};"><i class="bi ${c.icon}"></i></div>
          <div class="min-w-0">
            <div class="kpi-lbl">${c.label}</div>
            <div class="kpi-val">${fmt(d.value, c.decimals, c.money)}</div>
            <div class="mt-1 d-flex align-items-center gap-1 flex-wrap">
              ${growthBadge(d.growth, d.prev)}
              <span class="text-muted" style="font-size:.68rem;">vs anterior</span>
            </div>
          </div>
        </div>
      </div>`;
  }).join('');

  const itemsSold = kpis.items_sold.value;
  const itemsCard = `
    <div class="col-6 col-xl-3">
      <div class="rp-card d-flex align-items-center gap-3 p-3 h-100">
        <div class="kpi-icon" style="background:#dcfce7;color:#16a34a;"><i class="bi bi-bag-check"></i></div>
        <div class="min-w-0">
          <div class="kpi-lbl">Ítems vendidos</div>
          <div class="kpi-val">${Number(itemsSold).toLocaleString('es-CO')}</div>
          <div class="mt-1"><span class="text-muted" style="font-size:.72rem;">unidades totales</span></div>
        </div>
      </div>
    </div>`;

  el.innerHTML = cards + itemsCard;
}
