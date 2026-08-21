// heatmap.js — mapa de calor día×hora, hecho a mano con un grid CSS (sin
// librería: más confiable que cargar Nivo por CDN sin bundler).

const DAYS_ES = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

function heatColor(ratio) {
  if (ratio <= 0) return '#f1f5f9';
  const alpha = 0.12 + 0.78 * Math.min(ratio, 1);
  return `rgba(99,102,241,${alpha.toFixed(2)})`;
}

export function renderHeatmap(cells) {
  const container = document.getElementById('heatmapContainer');
  if (!container) return;

  const revenueByKey = {};
  let max = 0;
  cells.forEach(c => {
    revenueByKey[`${c.dow}-${c.hour}`] = c.revenue;
    if (c.revenue > max) max = c.revenue;
  });

  const headerCells = ['<div></div>'];
  for (let h = 0; h < 24; h++) {
    headerCells.push(`<div class="heatmap-hourlbl">${h % 3 === 0 ? h : ''}</div>`);
  }

  const rows = [];
  for (let d = 0; d < 7; d++) {
    const dayCells = [`<div class="heatmap-daylbl">${DAYS_ES[d]}</div>`];
    for (let h = 0; h < 24; h++) {
      const revenue = revenueByKey[`${d}-${h}`] || 0;
      const ratio = max > 0 ? revenue / max : 0;
      const title = `${DAYS_ES[d]} ${String(h).padStart(2, '0')}:00 — $${revenue.toLocaleString()}`;
      dayCells.push(`<div class="heatmap-cell" style="background:${heatColor(ratio)};" title="${title}"></div>`);
    }
    rows.push(dayCells.join(''));
  }

  container.innerHTML = `<div class="heatmap-grid">${headerCells.join('')}${rows.join('')}</div>`;
}
