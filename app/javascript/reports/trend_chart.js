// trend_chart.js — línea de tendencia con selector de granularidad y media
// móvil superpuesta (calculadas en SQL, ver Reports::TrendQuery).

let chartInstance = null;

export function initGranularityToggle(onChange) {
  const group = document.getElementById('granularityToggle');
  if (!group) return;
  group.querySelectorAll('button').forEach(btn => {
    btn.addEventListener('click', () => {
      group.querySelectorAll('button').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      onChange(btn.dataset.granularity);
    });
  });
}

export function renderTrend(trendData) {
  const el = document.getElementById('trendChart');
  if (!el) return;

  const labels     = trendData.map(d => d.bucket);
  const revenue    = trendData.map(d => d.revenue);
  const movingAvg  = trendData.map(d => d.moving_avg);

  if (chartInstance) chartInstance.destroy();

  const ctx = el.getContext('2d');
  const grad = ctx.createLinearGradient(0, 0, 0, 260);
  grad.addColorStop(0, 'rgba(99,102,241,.22)');
  grad.addColorStop(1, 'rgba(99,102,241,0)');

  const manyLabels = labels.length > 28;

  chartInstance = new Chart(ctx, {
    type: 'line',
    data: {
      labels,
      datasets: [
        {
          label: 'Ventas',
          data: revenue,
          borderColor: '#6366f1',
          backgroundColor: grad,
          borderWidth: 2.5,
          fill: true,
          tension: 0.35,
          pointRadius: manyLabels ? 0 : 3,
          pointHoverRadius: 7,
          pointBackgroundColor: '#6366f1',
          pointBorderColor: '#fff',
          pointBorderWidth: 2
        },
        {
          label: 'Media móvil',
          data: movingAvg,
          borderColor: '#f59e0b',
          borderDash: [5, 4],
          borderWidth: 2,
          fill: false,
          tension: 0.35,
          pointRadius: 0,
          pointHoverRadius: 0
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      interaction: { mode: 'index', intersect: false },
      plugins: {
        legend: {
          display: true, position: 'top', align: 'end',
          labels: { boxWidth: 10, font: { size: 11 }, color: '#64748b' }
        },
        tooltip: {
          backgroundColor: '#1e293b', titleColor: '#94a3b8', bodyColor: '#f8fafc',
          padding: 10, cornerRadius: 8,
          callbacks: {
            label: c => {
              if (c.datasetIndex !== 0) return '  Media móvil: $' + Number(c.raw).toLocaleString();
              const growth = trendData[c.dataIndex].pct_growth;
              const growthStr = (growth === null || growth === undefined)
                ? '' : ` (${growth > 0 ? '+' : ''}${growth}% vs período anterior)`;
              return '  Ventas: $' + Number(c.raw).toLocaleString() + growthStr;
            }
          }
        }
      },
      scales: {
        x: { grid: { display: false }, ticks: { color: '#94a3b8', font: { size: 11 }, maxTicksLimit: 12 } },
        y: {
          grid: { color: '#f1f5f9', drawBorder: false },
          ticks: { color: '#94a3b8', font: { size: 11 }, callback: v => (v === 0 ? '0' : '$' + v.toLocaleString()) }
        }
      }
    }
  });
}
