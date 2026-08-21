// filters.js — barra de filtros: presets de fecha + selects. Se re-adjunta
// en cada turbo:load porque Turbo reemplaza el <body> completo en cada
// navegación (nodos nuevos, sin listeners previos) — no hace falta guard.

export function initFilters(onChange) {
  const state = {
    period: 'month', from: '', to: '',
    mesero: '', categoria: '', product_id: '', tipo_servicio: '', tipo_pago: ''
  };

  const periodNav = document.getElementById('periodNav');
  const customRow = document.getElementById('customRangeRow');
  const fromInput = document.getElementById('filterFrom');
  const toInput   = document.getElementById('filterTo');
  const applyBtn  = document.getElementById('customRangeApply');

  function setActivePeriod(period) {
    periodNav.querySelectorAll('.pn-btn').forEach(b => b.classList.toggle('active', b.dataset.period === period));
    customRow.style.display = period === 'custom' ? 'flex' : 'none';
  }

  periodNav.querySelectorAll('.pn-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const period = btn.dataset.period;
      state.period = period;
      setActivePeriod(period);
      if (period !== 'custom') {
        state.from = '';
        state.to = '';
        onChange({ ...state });
      }
    });
  });

  applyBtn.addEventListener('click', () => {
    if (!fromInput.value || !toInput.value) return;
    state.from = fromInput.value;
    state.to = toInput.value;
    onChange({ ...state });
  });

  const selectIds = {
    filterMesero: 'mesero',
    filterCategoria: 'categoria',
    filterProducto: 'product_id',
    filterTipoServicio: 'tipo_servicio',
    filterTipoPago: 'tipo_pago'
  };

  Object.entries(selectIds).forEach(([elId, key]) => {
    const el = document.getElementById(elId);
    if (!el) return;
    el.addEventListener('change', () => {
      state[key] = el.value;
      onChange({ ...state });
    });
  });

  setActivePeriod(state.period);
  return state;
};
