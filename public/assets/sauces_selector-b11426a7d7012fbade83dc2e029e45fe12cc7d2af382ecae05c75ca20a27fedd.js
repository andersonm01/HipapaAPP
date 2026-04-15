/**
 * Sauce selector for POS order form.
 * Renders sauce checkboxes in a modal-style panel.
 * Used in home.js when confirming order items.
 */

export function renderSauceSelector(containerId, sauces, selectedIds = []) {
  const container = document.getElementById(containerId);
  if (!container || !sauces?.length) return;

  container.innerHTML = sauces.map(sauce => `
    <label class="sauce-option cursor-pointer flex items-center gap-2 p-1.5 rounded-lg hover:bg-gray-50 transition">
      <input type="checkbox"
             class="sauce-checkbox sr-only"
             name="sauce_ids[]"
             value="${sauce.id}"
             ${selectedIds.includes(sauce.id) ? 'checked' : ''}>
      <span class="sauce-dot w-4 h-4 rounded-full border-2 flex-shrink-0 transition"
            style="background-color: ${sauce.color}; border-color: ${sauce.color};"></span>
      <span class="text-sm font-medium text-gray-700">${sauce.nombre}</span>
    </label>
  `).join('');

  // Toggle visual state
  container.querySelectorAll('.sauce-checkbox').forEach(cb => {
    const dot = cb.nextElementSibling;
    updateDotState(dot, cb.checked);
    cb.addEventListener('change', () => updateDotState(dot, cb.checked));
  });
}

function updateDotState(dot, checked) {
  if (checked) {
    dot.style.boxShadow = `0 0 0 3px white, 0 0 0 5px ${dot.style.backgroundColor}`;
    dot.style.transform = 'scale(1.2)';
  } else {
    dot.style.boxShadow = '';
    dot.style.transform = '';
  }
}

export function getSelectedSauceIds(containerId) {
  const container = document.getElementById(containerId);
  if (!container) return [];
  return [...container.querySelectorAll('.sauce-checkbox:checked')].map(cb => parseInt(cb.value));
};
