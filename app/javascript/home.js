// Home page JavaScript functionality

document.addEventListener('DOMContentLoaded', function() {
  // Obtener datos desde data attributes
  const orderDataElement = document.getElementById('order-data');
  if (!orderDataElement) return;

  const orderData = JSON.parse(orderDataElement.textContent);
  const orderId = orderData.orderId || null;
  const orderStatus = orderData.orderStatus || 0;
  const orderTotal = orderData.orderTotal || 0;
  const isOrderClosed = orderStatus !== 0;

  // Lista temporal de productos seleccionados
  let selectedProducts = [];

  // Click en filas de orden
  const orderRows = document.querySelectorAll('.order-row');
  orderRows.forEach(function(row) {
    row.addEventListener('click', function() {
      const orderId = this.getAttribute('data-order-id');
      if (orderId) {
        const url = new URL(window.location.href);
        url.searchParams.set('order_id', orderId);
        window.location.href = url.toString();
      }
    });
  });

  // Búsqueda de productos (solo si el pedido no está cerrado)
  const productSearch = document.getElementById('productSearch');
  if (productSearch && !isOrderClosed) {
    productSearch.addEventListener('input', function() {
      const searchTerm = this.value.toLowerCase();
      const productItems = document.querySelectorAll('.product-item');
      
      productItems.forEach(function(item) {
        const productName = item.getAttribute('data-product-name');
        if (productName.includes(searchTerm)) {
          item.style.display = '';
        } else {
          item.style.display = 'none';
        }
      });
    });
  }

  // Agregar producto a la lista temporal (solo si el pedido no está cerrado)
  if (!isOrderClosed) {
    const addProductButtons = document.querySelectorAll('.add-product-btn');
    addProductButtons.forEach(function(btn) {
      btn.addEventListener('click', function() {
        const productId = this.getAttribute('data-product-id');
        const productName = this.getAttribute('data-product-name');
        const productPrecio = parseFloat(this.getAttribute('data-product-precio'));
        
        // Verificar si el producto ya está en la lista
        const existingIndex = selectedProducts.findIndex(p => p.product_id === productId);
        
        if (existingIndex >= 0) {
          // Si existe, incrementar cantidad
          selectedProducts[existingIndex].cantidad += 1;
        } else {
          // Si no existe, agregar nuevo
          selectedProducts.push({
            product_id: productId,
            product_name: productName,
            precio: productPrecio,
            cantidad: 1,
            comentario: ''
          });
        }
        
        updateSelectedProductsList();
      });
    });
  }

  // Actualizar lista de productos seleccionados
  function updateSelectedProductsList() {
    const container = document.getElementById('selectedProductsContainer');
    const list = document.getElementById('selectedProductsList');
    const confirmBtn = document.getElementById('confirmProductsBtn');
    const selectedTotalContainer = document.getElementById('selectedTotalContainer');
    const selectedTotal = document.getElementById('selectedTotal');
    
    // Calcular el total primero
    let total = 0;
    selectedProducts.forEach(function(product) {
      total += product.cantidad * product.precio;
    });
    
    // Actualizar el total siempre, incluso si no hay productos
    if (selectedTotal) {
      selectedTotal.textContent = '$' + total.toFixed(2);
    }
    
    if (selectedProducts.length === 0) {
      if (container) container.style.display = 'none';
      if (confirmBtn) confirmBtn.disabled = true;
      if (selectedTotalContainer) selectedTotalContainer.style.display = 'none';
      return;
    }
    
    if (container) container.style.display = 'block';
    if (confirmBtn) confirmBtn.disabled = false;
    if (selectedTotalContainer) selectedTotalContainer.style.display = 'flex';
    
    if (list) list.innerHTML = '';
    
    selectedProducts.forEach(function(product, index) {
      const itemDiv = document.createElement('div');
      itemDiv.className = 'mb-3 p-2 bg-light rounded';
      itemDiv.innerHTML = `
        <div class="d-flex justify-content-between align-items-start mb-2">
          <div class="flex-grow-1">
            <div class="fw-bold">${product.product_name}</div>
            <small class="text-muted">Cant: ${product.cantidad} x $${product.precio.toFixed(2)}</small>
          </div>
          <div>
            <button type="button" class="btn btn-sm btn-danger remove-product-btn" data-index="${index}">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="currentColor" class="bi bi-x" viewBox="0 0 16 16">
                <path d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z"/>
              </svg>
            </button>
          </div>
        </div>
        <div class="mb-2">
          <label class="form-label small fw-bold">Comentario:</label>
          <input type="text" class="form-control form-control-sm product-comment" 
                 data-index="${index}" 
                 placeholder="Agregar comentario..." 
                 value="${product.comentario}">
        </div>
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <button type="button" class="btn btn-sm btn-outline-secondary quantity-btn" data-index="${index}" data-action="decrease">-</button>
            <span class="mx-2 fw-bold">${product.cantidad}</span>
            <button type="button" class="btn btn-sm btn-outline-secondary quantity-btn" data-index="${index}" data-action="increase">+</button>
          </div>
          <div class="fw-bold">$${(product.cantidad * product.precio).toFixed(2)}</div>
        </div>
      `;
      if (list) list.appendChild(itemDiv);
    });
    
    // Asegurar que el total se actualice después de renderizar
    if (selectedTotal) {
      selectedTotal.textContent = '$' + total.toFixed(2);
    }
    
    // Event listeners para comentarios
    document.querySelectorAll('.product-comment').forEach(function(input) {
      input.addEventListener('input', function() {
        const index = parseInt(this.getAttribute('data-index'));
        selectedProducts[index].comentario = this.value;
      });
    });
    
    // Event listeners para botones de cantidad
    document.querySelectorAll('.quantity-btn').forEach(function(btn) {
      btn.addEventListener('click', function() {
        const index = parseInt(this.getAttribute('data-index'));
        const action = this.getAttribute('data-action');
        
        if (action === 'increase') {
          selectedProducts[index].cantidad += 1;
        } else if (action === 'decrease' && selectedProducts[index].cantidad > 1) {
          selectedProducts[index].cantidad -= 1;
        }
        
        updateSelectedProductsList();
      });
    });
    
    // Event listeners para eliminar productos
    document.querySelectorAll('.remove-product-btn').forEach(function(btn) {
      btn.addEventListener('click', function() {
        const index = parseInt(this.getAttribute('data-index'));
        selectedProducts.splice(index, 1);
        updateSelectedProductsList();
      });
    });
  }

  // Formulario de confirmación
  const confirmForm = document.getElementById('confirmProductsForm');
  if (confirmForm) {
    confirmForm.addEventListener('submit', function(e) {
      e.preventDefault();
      
      if (selectedProducts.length === 0) {
        alert('No hay productos para confirmar.');
        return;
      }
      
      // Crear campos hidden para cada producto
      selectedProducts.forEach(function(product, index) {
        const productIdInput = document.createElement('input');
        productIdInput.type = 'hidden';
        productIdInput.name = `order_items[${index}][product_id]`;
        productIdInput.value = product.product_id;
        confirmForm.appendChild(productIdInput);
        
        const cantidadInput = document.createElement('input');
        cantidadInput.type = 'hidden';
        cantidadInput.name = `order_items[${index}][cantidad]`;
        cantidadInput.value = product.cantidad;
        confirmForm.appendChild(cantidadInput);
        
        const comentarioInput = document.createElement('input');
        comentarioInput.type = 'hidden';
        comentarioInput.name = `order_items[${index}][comentario]`;
        comentarioInput.value = product.comentario || '';
        confirmForm.appendChild(comentarioInput);
      });
      
      // Enviar formulario
      confirmForm.submit();
    });
  }

  // Cálculo de vuelto en el modal de cerrar pedido
  const montoPagadoInput = document.getElementById('monto_pagado');
  const vueltoAmount = document.getElementById('vueltoAmount');
  const vueltoInput = document.getElementById('vuelto');
  const vueltoContainer = document.getElementById('vueltoContainer');
  const vueltoCard = document.getElementById('vueltoCard');
  const vueltoLabel = document.getElementById('vueltoLabel');
  const tipoPagoInputs = document.querySelectorAll('input[name="tipo_pago"]');

  if (montoPagadoInput && vueltoAmount && vueltoInput && vueltoContainer) {
    function calculateVuelto() {
      const montoPagado = parseFloat(montoPagadoInput.value) || 0;
      const tipoPago = document.querySelector('input[name="tipo_pago"]:checked')?.value;
      
      if (tipoPago === 'transferencia') {
        // Transferencia: no hay vuelto, ocultar contenedor
        vueltoInput.value = '0';
        vueltoContainer.style.display = 'none';
      } else {
        // Efectivo: calcular vuelto
        vueltoContainer.style.display = 'block';
        
        if (montoPagado >= orderTotal) {
          const vuelto = montoPagado - orderTotal;
          vueltoAmount.textContent = '$' + vuelto.toFixed(2);
          vueltoInput.value = vuelto.toFixed(2);
          vueltoAmount.classList.remove('text-danger');
          vueltoAmount.classList.add('text-success');
          vueltoLabel.textContent = 'Vuelto a devolver:';
          vueltoLabel.classList.remove('text-danger');
          vueltoLabel.classList.add('text-success');
          vueltoCard.classList.remove('border-danger');
          vueltoCard.classList.add('border-success');
        } else {
          const falta = orderTotal - montoPagado;
          vueltoAmount.textContent = '$' + falta.toFixed(2);
          vueltoInput.value = '0';
          vueltoAmount.classList.remove('text-success');
          vueltoAmount.classList.add('text-danger');
          vueltoLabel.textContent = 'Falta por pagar:';
          vueltoLabel.classList.remove('text-success');
          vueltoLabel.classList.add('text-danger');
          vueltoCard.classList.remove('border-success');
          vueltoCard.classList.add('border-danger');
        }
      }
    }

    montoPagadoInput.addEventListener('input', calculateVuelto);
    
    tipoPagoInputs.forEach(function(input) {
      input.addEventListener('change', function() {
        if (this.value === 'transferencia') {
          montoPagadoInput.value = orderTotal.toFixed(2);
          montoPagadoInput.readOnly = true;
          montoPagadoInput.classList.add('bg-light');
        } else {
          montoPagadoInput.readOnly = false;
          montoPagadoInput.classList.remove('bg-light');
        }
        calculateVuelto();
      });
    });

    // Calcular al abrir el modal
    const closeOrderModal = document.getElementById('closeOrderModal');
    if (closeOrderModal) {
      closeOrderModal.addEventListener('shown.bs.modal', function() {
        calculateVuelto();
      });
    }
  }
});
