// secondary_charts.js — doughnuts pequeños: categoría, servicio, método de pago.

const PALETTE = ['#6366f1', '#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#06b6d4', '#f97316', '#84cc16', '#ec4899'];
const instances = {};

function renderDoughnut(id, labels, values, colors, legend) {
  const el = document.getElementById(id);
  if (!el) return;
  if (instances[id]) { instances[id].destroy(); instances[id] = null; }
  if (!labels.length) return;

  instances[id] = new Chart(el, {
    type: 'doughnut',
    data: { labels, datasets: [{ data: values, backgroundColor: colors, borderWidth: 2, borderColor: '#fff' }] },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      cutout: '62%',
      plugins: {
        legend: {
          display: legend, position: 'bottom',
          labels: { font: { size: 9 }, padding: 5, boxWidth: 9, color: '#64748b' }
        },
        tooltip: {
          backgroundColor: '#1e293b', titleColor: '#94a3b8', bodyColor: '#f8fafc',
          padding: 10, cornerRadius: 8,
          callbacks: { label: c => '  ' + c.label + ': $' + Number(c.raw).toLocaleString() }
        }
      }
    }
  });
}

export function renderSecondaryCharts(summary) {
  renderDoughnut('categoryChart', summary.by_category.labels, summary.by_category.values, PALETTE, false);
  renderDoughnut('servicioChart', summary.by_servicio.labels, summary.by_servicio.values, ['#6366f1', '#f59e0b', '#10b981'], true);
  renderDoughnut('pagoChart', summary.by_pago.labels, summary.by_pago.values, ['#10b981', '#3b82f6'], true);
};
