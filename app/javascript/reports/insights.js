// insights.js — panel de "Análisis automático" (Reports::InsightsService).

export function renderInsights(insights) {
  const card  = document.getElementById('insightsCard');
  const list  = document.getElementById('insightsList');
  const count = document.getElementById('insightsCount');
  if (!card || !list || !count) return;

  if (!insights || !insights.length) {
    card.style.display = 'none';
    return;
  }

  card.style.display = '';
  count.textContent = `${insights.length} hallazgo${insights.length !== 1 ? 's' : ''}`;
  list.innerHTML = insights.map(i => `
    <div class="col-md-6">
      <div class="insight-item ${i.type}">${i.text}</div>
    </div>`).join('');
}
