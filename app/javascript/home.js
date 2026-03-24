// Home page JavaScript functionality

function initHome() {
  // Click en filas de orden
  const orderRows = document.querySelectorAll('.order-row');
  orderRows.forEach(function(row) {
    row.addEventListener('click', function() {
      const orderId = this.getAttribute('data-order-id');
      if (orderId) {
        window.location.href = '/pedido/' + orderId;
      }
    });
  });

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
  // Tipo de servicio: enviar formulario al cambiar selección
  const tipoServicioForm = document.getElementById('tipoServicioForm');
  if (tipoServicioForm) {
    tipoServicioForm.querySelectorAll('input[name="tipo_servicio"]').forEach(function(radio) {
      radio.addEventListener('change', function() {
        tipoServicioForm.submit();
      });
    });
  }

  // Búsqueda de productos (solo si el pedido no está cerrado)
  const productSearch = document.getElementById('productSearch');
  if (productSearch && !isOrderClosed) {
    function filterProducts(searchTerm) {
      const term = (searchTerm || '').toLowerCase();
      const productItems = document.querySelectorAll('.product-item');
      productItems.forEach(function(item) {
        const productName = (item.getAttribute('data-product-name') || '').toLowerCase();
        const productCategory = (item.getAttribute('data-product-category') || '').toLowerCase();
        if (term === '') {
          // Sin búsqueda: solo mostrar categoría "papas"
          item.style.display = (productCategory === 'papas') ? '' : 'none';
        } else {
          // Con búsqueda: buscar en todos por nombre
          item.style.display = productName.includes(term) ? '' : 'none';
        }
      });
    }
    // Estado inicial: sin texto, solo Papas
    filterProducts('');
    productSearch.addEventListener('input', function() {
      filterProducts(this.value);
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
      itemDiv.className = 'sel-item';
      itemDiv.innerHTML = `
        <div class="sel-item-header">
          <div>
            <div class="sel-item-name">${product.product_name}</div>
            <div class="sel-item-qty-text">${product.cantidad} × $${product.precio.toFixed(2)}</div>
          </div>
          <button type="button" class="btn-remove remove-product-btn" data-index="${index}" title="Quitar">×</button>
        </div>
        <input type="text" class="sel-comment-input product-comment"
               data-index="${index}"
               placeholder="Comentario (ej: sin cebolla)..."
               value="${product.comentario}">
        <div class="sel-item-controls">
          <div class="sel-item-qty">
            <button type="button" class="btn-qty quantity-btn" data-index="${index}" data-action="decrease">−</button>
            <span style="font-weight:700;font-size:0.875rem;min-width:1.25rem;text-align:center;">${product.cantidad}</span>
            <button type="button" class="btn-qty quantity-btn" data-index="${index}" data-action="increase">+</button>
          </div>
          <span class="sel-item-total">$${(product.cantidad * product.precio).toFixed(2)}</span>
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

  // Etiqueta de tipo de servicio para comanda
  function etiquetaTipoServicio(val) {
    if (val === 'llevar') return 'Para llevar';
    if (val === 'domicilio') return 'Domicilio';
    return 'En mesa';
  }

  function escaparHtml(str) {
    if (str == null || str === '') return '';
    var div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
  }

  const IMPRESORA = document.body.getAttribute('data-impresora-termica') || localStorage.getItem('hipapa_impresora') || 'POS-80';
  const tamanoFuente = 2;

  // Imprimir comanda: QZ Tray (producción) con fallback a Rails backend (Windows local).
  function printComanda(items, onAfterPrint) {
    const orderId = orderData.orderId || '-';
    const cliente = (orderData.cliente || '-').toString();
    const mesero = (orderData.mesero || '-').toString();
    const tipoServicio = etiquetaTipoServicio(orderData.tipoServicio || 'mesa');
    const fecha = orderData.createdAt || new Date().toLocaleString('es-CL', { day: '2-digit', month: '2-digit', year: '2-digit', hour: '2-digit', minute: '2-digit' });

    var operaciones = [
      { nombre: 'Iniciar', argumentos: [] },
      { nombre: 'EstablecerAlineacion', argumentos: [0] },
      { nombre: 'EstablecerTamañoFuente', argumentos: [tamanoFuente, tamanoFuente] },
      { nombre: 'EstablecerEnfatizado', argumentos: [true] },
      { nombre: 'EstablecerEnfatizado', argumentos: [false] },
      { nombre: 'EstablecerTamañoFuente', argumentos: [tamanoFuente, tamanoFuente] },
      { nombre: 'EscribirTexto', argumentos: ['Pedido #' + orderId + '\n'] },
      { nombre: 'Feed', argumentos: [1] },
      { nombre: 'EstablecerAlineacion', argumentos: [0] },
      { nombre: 'EstablecerTamañoFuente', argumentos: [1, 1] },
      { nombre: 'EscribirTexto', argumentos: ['Cliente: ' + cliente + '\n'] },
      { nombre: 'EscribirTexto', argumentos: ['Servicio: ' + tipoServicio + '\n'] },
      { nombre: 'EscribirTexto', argumentos: ['Fecha:   ' + fecha + '\n'] },
      { nombre: 'EstablecerTamañoFuente', argumentos: [tamanoFuente, tamanoFuente] },
      { nombre: 'Feed', argumentos: [1] }
    ];
    items.forEach(function(p) {
      operaciones.push({ nombre: 'EscribirTexto', argumentos: [p.cantidad + ' x ' + p.product_name + '\n'] });
      var c = (p.comentario && p.comentario.trim()) ? p.comentario.trim() : '';
      if (c) operaciones.push({ nombre: 'EscribirTexto', argumentos: ['  Salsas: ' + c + '\n'] });
    });
    operaciones.push(
      { nombre: 'Feed', argumentos: [1] },
      { nombre: 'EstablecerAlineacion', argumentos: [1] },
      { nombre: 'Feed', argumentos: [4] },
      { nombre: 'Corte', argumentos: [0] }
    );

    var printMode = localStorage.getItem('hipapa_print_mode') || 'qztray';

    if (printMode === 'webserial') {
      // ── Web Serial: directo al puerto COM, sin software adicional
      import('webserial_printer').then(function(ws) {
        ws.printRaw(operaciones)
          .then(function() {
            if (onAfterPrint) onAfterPrint();
          })
          .catch(function(err) {
            var msg = err && err.message ? err.message : 'Error al imprimir';
            alert('⚠️ No se pudo imprimir.\n\n' + msg + '\n\nVe a Impresora → Configurar para revisar el puerto serial.');
            if (onAfterPrint) onAfterPrint();
          });
      }).catch(function() {
        alert('Error al cargar el módulo de impresión serial.');
        if (onAfterPrint) onAfterPrint();
      });

    } else if (printMode !== 'rails' && typeof qz !== 'undefined') {
      // ── QZ Tray
      import('qztray_printer').then(function(qzPrinter) {
        var impresora = qzPrinter.getSavedPrinter() || IMPRESORA;
        qzPrinter.printRaw(impresora, operaciones)
          .then(function() {
            if (onAfterPrint) onAfterPrint();
          })
          .catch(function(err) {
            var msg = err && err.message ? err.message : 'Error al imprimir con QZ Tray';
            alert(
              '⚠️ No se pudo imprimir.\n\n' + msg +
              '\n\n¿QZ Tray está ejecutándose? Busca el ícono en la bandeja del sistema.\n' +
              'Si no lo tienes instalado, ve a Impresora → Configurar.'
            );
            if (onAfterPrint) onAfterPrint();
          });
      }).catch(function() {
        alert('Error al cargar el módulo de impresión.');
        if (onAfterPrint) onAfterPrint();
      });

    } else {
      // ── Rails backend (solo Windows local)
      var payload = { serial: '', nombreImpresora: IMPRESORA, operaciones: operaciones };
      fetch('/printer/imprimir_raw', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
        },
        body: JSON.stringify(payload)
      })
        .then(function(r) { return r.json().then(function(data) { return { ok: r.ok, data: data }; }); })
        .then(function(res) {
          if (res.ok && res.data && res.data.ok) { if (onAfterPrint) onAfterPrint(); return; }
          var msg = (res.data && res.data.message) ? res.data.message : 'Error al imprimir. Revisa la configuración.';
          alert(msg);
          if (onAfterPrint) onAfterPrint();
        })
        .catch(function() {
          alert('No se pudo enviar a la impresora. Verifica la configuración en Impresora.');
          if (onAfterPrint) onAfterPrint();
        });
    }
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
        productIdInput.name = 'order_items[' + index + '][product_id]';
        productIdInput.value = product.product_id;
        confirmForm.appendChild(productIdInput);

        const cantidadInput = document.createElement('input');
        cantidadInput.type = 'hidden';
        cantidadInput.name = 'order_items[' + index + '][cantidad]';
        cantidadInput.value = product.cantidad;
        confirmForm.appendChild(cantidadInput);

        const comentarioInput = document.createElement('input');
        comentarioInput.type = 'hidden';
        comentarioInput.name = 'order_items[' + index + '][comentario]';
        comentarioInput.value = product.comentario || '';
        confirmForm.appendChild(comentarioInput);
      });

      // Imprimir comanda y luego enviar formulario
      printComanda(selectedProducts, function() {
        confirmForm.submit();
      });
    });
  }

  // Cálculo de vuelto en el modal de cerrar pedido
  const montoPagadoInput = document.getElementById('monto_pagado');
  const vueltoAmount = document.getElementById('vueltoAmount');
  const vueltoInput = document.getElementById('vuelto');
  const vueltoContainer = document.getElementById('vueltoContainer');
  const vueltoCard = document.getElementById('vueltoCard'); // may be null — handled safely
  const vueltoLabel = document.getElementById('vueltoLabel');
  const tipoPagoInputs = document.querySelectorAll('input[name="tipo_pago"]');

  if (montoPagadoInput && vueltoAmount && vueltoInput && vueltoContainer) {
    function calculateVuelto() {
      const montoPagado = parseFloat(montoPagadoInput.value) || 0;
      const tipoPago = document.querySelector('input[name="tipo_pago"]:checked')?.value;

      if (tipoPago === 'transferencia') {
        vueltoInput.value = '0';
        vueltoContainer.style.display = 'none';
      } else {
        vueltoContainer.style.display = 'block';

        if (montoPagado >= orderTotal) {
          const vuelto = montoPagado - orderTotal;
          vueltoAmount.textContent = '$' + vuelto.toFixed(2);
          vueltoInput.value = vuelto.toFixed(2);
          vueltoAmount.style.color = '#15803d';
          if (vueltoLabel) { vueltoLabel.textContent = 'Vuelto a devolver:'; vueltoLabel.style.color = '#15803d'; }
          if (vueltoCard)  { vueltoCard.style.background = '#f0fdf4'; vueltoCard.style.borderColor = '#bbf7d0'; }
        } else {
          const falta = orderTotal - montoPagado;
          vueltoAmount.textContent = '$' + falta.toFixed(2);
          vueltoInput.value = '0';
          vueltoAmount.style.color = '#b91c1c';
          if (vueltoLabel) { vueltoLabel.textContent = 'Falta por pagar:'; vueltoLabel.style.color = '#b91c1c'; }
          if (vueltoCard)  { vueltoCard.style.background = '#fef2f2'; vueltoCard.style.borderColor = '#fecaca'; }
        }
      }
    }

    montoPagadoInput.addEventListener('input', calculateVuelto);

    tipoPagoInputs.forEach(function(input) {
      input.addEventListener('change', function() {
        if (this.value === 'transferencia') {
          montoPagadoInput.value = orderTotal.toFixed(2);
          montoPagadoInput.readOnly = true;
          montoPagadoInput.style.background = '#f8fafc';
        } else {
          montoPagadoInput.readOnly = false;
          montoPagadoInput.style.background = '';
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

  // ActionCable - Suscripción para actualizaciones en tiempo real
  if (typeof App !== 'undefined' && App.cable) {
    const ordersChannel = App.cable.subscriptions.create("OrdersChannel", {
      connected() {
        console.log("Conectado al canal de órdenes");
      },
      
      disconnected() {
        console.log("Desconectado del canal de órdenes");
      },
      
      received(data) {
        console.log("Datos recibidos:", data);
        
        if (data.type === "order_created") {
          // No recargar si ya estamos viendo ese pedido (evita perder ?order_id= en la URL)
          const currentPath = window.location.pathname;
          const urlParams = new URLSearchParams(window.location.search);
          const orderIdInUrl = urlParams.get('order_id');
          const isOnThisPedido = currentPath.startsWith('/pedido/') && data.order && String(data.order.id) === currentPath.replace(/^\/pedido\//, '');
          const isOnRootWithOrderId = (currentPath === '/' || currentPath === '') && orderIdInUrl && data.order && String(data.order.id) === orderIdInUrl;
          if (!isOnThisPedido && !isOnRootWithOrderId) location.reload();
        } else if (data.type === "order_updated") {
          // Orden actualizada - actualizar si es la orden actual
          if (orderId && data.order.id === orderId) {
            // Actualizar el total si estamos viendo esta orden
            const totalElement = document.querySelector('.card-footer .fw-bold:last-child');
            if (totalElement && data.order.total) {
              totalElement.textContent = '$' + parseFloat(data.order.total).toFixed(2);
            }
            // Recargar para mostrar productos actualizados
            location.reload();
          } else {
            // Si no es la orden actual, recargar para actualizar las tablas
            location.reload();
          }
        } else if (data.type === "order_closed") {
          // Orden cerrada - recargar para actualizar las tablas
          location.reload();
        }
      }
    });
  }
};

document.addEventListener('turbo:load', initHome);
