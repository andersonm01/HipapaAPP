// Monitor de Cocina — timers, alertas de color, ActionCable

// ── Helpers ──────────────────────────────────────────────────────────────────

function elapsedMinutes(isoTimestamp) {
  return Math.floor((Date.now() - new Date(isoTimestamp).getTime()) / 60000);
}

function timerLabel(minutes) {
  if (minutes < 1) return 'Hace menos de 1 min';
  return 'Hace ' + minutes + ' min';
}

// ── Timer + color de alerta ───────────────────────────────────────────────────

function updateTimers() {
  document.querySelectorAll('.kitchen-card[data-created-at]').forEach(function (card) {
    var minutes  = elapsedMinutes(card.dataset.createdAt);

    // Texto del timer
    var timerEl = card.querySelector('[data-timer]');
    if (timerEl) {
      timerEl.textContent = timerLabel(minutes);
      timerEl.className   = 'kitchen-timer' +
        (minutes >= 15 ? ' timer-critical' : minutes >= 10 ? ' timer-warning' : '');
    }

    // Barra de alerta
    var alertBar = card.querySelector('[data-alert-bar]');
    if (alertBar) {
      if (minutes >= 15) {
        alertBar.className   = 'kitchen-alert-bar critical';
        alertBar.textContent = '🔴 CRITICO — lleva ' + minutes + ' minutos';
      } else if (minutes >= 10) {
        alertBar.className   = 'kitchen-alert-bar warning';
        alertBar.textContent = '⚠️ ADVERTENCIA — lleva ' + minutes + ' minutos';
      } else {
        alertBar.className   = 'kitchen-alert-bar';
        alertBar.textContent = '';
      }
    }

    // Estado visual de la card: fondo + borde (más oscuro que el fondo)
    card.classList.remove('state-warning', 'state-critical');
    if (minutes >= 15) {
      card.classList.add('state-critical');
      card.style.backgroundColor = '#fef2f2';  // rojo claro
      card.style.border = '2px solid #dc2626'; // rojo oscuro
    } else if (minutes >= 10) {
      card.classList.add('state-warning');
      card.style.backgroundColor = '#fffbeb'; // ámbar claro
      card.style.border = '2px solid #d97706'; // ámbar oscuro
    } else {
      card.style.backgroundColor = '#f0fdf4'; // verde claro
      card.style.border = '2px solid #22c55e'; // verde oscuro
    }
  });
}

// ── Reloj ─────────────────────────────────────────────────────────────────────

function updateClock() {
  var el = document.getElementById('cocina-reloj');
  if (el) {
    el.textContent = new Date().toLocaleTimeString('es-CL', {
      hour: '2-digit', minute: '2-digit', second: '2-digit'
    });
  }
}

// ── Init ──────────────────────────────────────────────────────────────────────

function initCocina() {
  if (!document.getElementById('cocina-monitor')) return;

  updateTimers();
  updateClock();

  // Timers: cada 5s (granularidad "Hace X min" no necesita más)
  setInterval(updateTimers, 5000);
  setInterval(updateClock,  1000);

  // Polling fallback: recarga cada 30s por si ActionCable falla
  var pollId = setInterval(function () { location.reload(); }, 30000);

  // ActionCable — recarga inmediata cuando llegan eventos
  if (typeof App !== 'undefined' && App.cable) {
    clearInterval(pollId); // ActionCable disponible, no necesitamos polling agresivo

    App.cable.subscriptions.create('CocinaChannel', {
      connected: function () {
        console.log('[Cocina] Canal cocina conectado');
      },
      disconnected: function () {
        console.log('[Cocina] Canal cocina desconectado — activando polling');
        pollId = setInterval(function () { location.reload(); }, 15000);
      },
      received: function (data) {
        if (data.type === 'kitchen_status_updated') location.reload();
      }
    });

    App.cable.subscriptions.create('OrdersChannel', {
      received: function (data) {
        if (data.type === 'order_created' || data.type === 'order_updated') {
          location.reload();
        }
      }
    });
  }
}

document.addEventListener('turbo:load',     initCocina);
document.addEventListener('DOMContentLoaded', initCocina);
