// top_products_chart.js — ranking de productos, barras horizontales.

let chartInstance = null;

export function renderTopProducts(products) {
  const el = document.getElementById('topProductsChart');
  if (!el) return;
  if (chartInstance) chartInstance.destroy();

  // Reverse: en una barra horizontal Chart.js dibuja de abajo hacia arriba,
  // así el #1 queda arriba.
  const top = products.slice(0, 8).reverse();

  chartInstance = new Chart(el, {
    type: 'bar',
    data: {
      labels: top.map(p => p.nombre),
      datasets: [{
        data: top.map(p => p.revenue),
        backgroundColor: '#6366f1',
        borderRadius: 4,
        borderSkipped: false
      }]
    },
    options: {
      indexAxis: 'y',
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false },
        tooltip: {
          backgroundColor: '#1e293b', titleColor: '#94a3b8', bodyColor: '#f8fafc',
          padding: 10, cornerRadius: 8,
          callbacks: { label: c => '  $' + Number(c.raw).toLocaleString() }
        }
      },
      scales: {
        x: {
          grid: { color: '#f1f5f9', drawBorder: false },
          ticks: { color: '#94a3b8', font: { size: 10 }, callback: v => '$' + v.toLocaleString() }
        },
        y: { grid: { display: false }, ticks: { color: '#475569', font: { size: 10.5 } } }
      }
    }
  });
};
