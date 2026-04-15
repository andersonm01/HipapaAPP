/**
 * Online cart for Hi Papa public menu.
 * Persists to localStorage. Fires 'cart:updated' events.
 */
class OnlineCart {
  constructor() {
    this._items = JSON.parse(localStorage.getItem('hipapa_cart') || '[]');
    this._render();
  }

  get items() { return this._items; }

  add(productId, nombre, precio, cantidad = 1) {
    const existing = this._items.find(i => i.product_id === productId);
    if (existing) {
      existing.cantidad += cantidad;
    } else {
      this._items.push({ product_id: productId, nombre, precio, cantidad, notas: '', salsas: [] });
    }
    this._save();
    this._render();
  }

  remove(productId) {
    this._items = this._items.filter(i => i.product_id !== productId);
    this._save();
    this._render();
  }

  updateQuantity(productId, cantidad) {
    const item = this._items.find(i => i.product_id === productId);
    if (!item) return;
    if (cantidad <= 0) { this.remove(productId); return; }
    item.cantidad = cantidad;
    this._save();
    this._render();
  }

  updateSauces(productId, salsas) {
    const item = this._items.find(i => i.product_id === productId);
    if (item) { item.salsas = salsas; this._save(); }
  }

  clear() {
    this._items = [];
    this._save();
    this._render();
  }

  get total() {
    return this._items.reduce((sum, i) => sum + (parseFloat(i.precio) * i.cantidad), 0);
  }

  get count() {
    return this._items.reduce((sum, i) => sum + i.cantidad, 0);
  }

  _save() {
    localStorage.setItem('hipapa_cart', JSON.stringify(this._items));
    document.dispatchEvent(new CustomEvent('cart:updated', { detail: this }));
  }

  _render() {
    // Update badge
    const badge = document.getElementById('cart-count');
    if (badge) badge.textContent = this.count;

    // Update total
    const totalEl = document.getElementById('cart-total');
    if (totalEl) totalEl.textContent = `$${this.total.toLocaleString('es-CO', { maximumFractionDigits: 0 })}`;

    // Update items list
    const listEl = document.getElementById('cart-items');
    if (!listEl) return;

    if (this._items.length === 0) {
      listEl.innerHTML = '<p class="text-gray-400 text-sm text-center py-4">Tu carrito está vacío</p>';
      return;
    }

    listEl.innerHTML = this._items.map(item => `
      <div class="flex items-center gap-2 bg-gray-50 rounded-lg p-2">
        <div class="flex-1 min-w-0">
          <p class="text-sm font-semibold truncate">${item.nombre}</p>
          ${item.salsas?.length ? `<p class="text-xs text-gray-400">${item.salsas.join(', ')}</p>` : ''}
          <p class="text-xs font-bold" style="color: var(--pub-brand, #f59e0b);">$${(item.precio * item.cantidad).toLocaleString('es-CO', { maximumFractionDigits: 0 })}</p>
        </div>
        <div class="flex items-center gap-1 shrink-0">
          <button onclick="window._cart.updateQuantity(${item.product_id}, ${item.cantidad - 1})"
                  class="w-6 h-6 rounded-full bg-gray-200 text-gray-700 font-bold text-sm leading-none">−</button>
          <span class="w-5 text-center text-sm font-bold">${item.cantidad}</span>
          <button onclick="window._cart.updateQuantity(${item.product_id}, ${item.cantidad + 1})"
                  class="w-6 h-6 rounded-full bg-gray-200 text-gray-700 font-bold text-sm leading-none">+</button>
        </div>
      </div>
    `).join('');
  }
}

const cart = new OnlineCart();
window._cart = cart;  // Expose for inline onclick handlers
export default cart;
