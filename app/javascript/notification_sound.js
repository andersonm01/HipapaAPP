// Sonido de notificación para pedidos nuevos desde la web (pedidos online).
// Sintetizado con Web Audio API (sin archivo de audio externo) para no
// depender de un asset ni de licencias — un timbre de 3 notas ascendentes.

let sharedCtx = null;

function getContext() {
  const Ctx = window.AudioContext || window.webkitAudioContext;
  if (!Ctx) return null;
  if (!sharedCtx) sharedCtx = new Ctx();
  return sharedCtx;
}

function tone(ctx, freq, startOffset, duration, peakGain) {
  const osc  = ctx.createOscillator();
  const gain = ctx.createGain();
  const now  = ctx.currentTime + startOffset;

  osc.type = 'sine';
  osc.frequency.value = freq;

  gain.gain.setValueAtTime(0, now);
  gain.gain.linearRampToValueAtTime(peakGain, now + 0.02);
  gain.gain.exponentialRampToValueAtTime(0.0001, now + duration);

  osc.connect(gain).connect(ctx.destination);
  osc.start(now);
  osc.stop(now + duration + 0.05);
}

function playTones(ctx) {
  tone(ctx, 880,  0,    0.18, 0.3);  // La5
  tone(ctx, 1175, 0.16, 0.28, 0.3);  // Re6
  tone(ctx, 1568, 0.34, 0.42, 0.25); // Sol6
}

// ── Log persistido (sobrevive a location.reload(), que borra la consola) ──
const LOG_KEY = 'hipapa_chime_log';

function persistLog(msg) {
  try {
    const list = JSON.parse(sessionStorage.getItem(LOG_KEY) || '[]');
    list.push(new Date().toLocaleTimeString() + ' — ' + msg);
    sessionStorage.setItem(LOG_KEY, JSON.stringify(list.slice(-15)));
  } catch (e) { /* sessionStorage no disponible, no es crítico */ }
}

// Llamar una vez al cargar cada página (home.js/cocina.js) para imprimir en
// consola lo que pasó con el timbre ANTES del último reload — si no, esos
// console.log/warn se pierden porque location.reload() limpia la consola.
export function flushChimeLog() {
  try {
    const list = JSON.parse(sessionStorage.getItem(LOG_KEY) || '[]');
    if (list.length) {
      console.log('[notification_sound] Actividad del timbre antes del último reload:');
      list.forEach((line) => console.log('  ' + line));
      sessionStorage.removeItem(LOG_KEY);
    }
  } catch (e) { /* noop */ }
}

// Duración total aproximada del timbre, en ms — quien llame a
// playNewWebOrderChime() puede esperar este tiempo antes de recargar la
// página para no cortar el sonido a mitad.
export const NEW_WEB_ORDER_CHIME_MS = 850;

export function playNewWebOrderChime() {
  try {
    const ctx = getContext();
    if (!ctx) {
      persistLog('Web Audio no disponible en este navegador (AudioContext undefined).');
      return;
    }

    persistLog('playNewWebOrderChime() llamado, ctx.state=' + ctx.state);

    if (ctx.state === 'suspended') {
      // Los navegadores solo permiten sacar un AudioContext de "suspended"
      // como resultado directo de un gesto del usuario (click, tecla, touch).
      // Si nadie interactuó con la página todavía, este resume() no va a
      // desbloquear nada y el timbre queda mudo.
      ctx.resume().then(() => {
        persistLog('resume() resolvió, ctx.state=' + ctx.state);
        if (ctx.state === 'running') playTones(ctx);
      }).catch((e) => persistLog('resume() falló: ' + e));
      return;
    }

    playTones(ctx);
  } catch (e) {
    persistLog('Excepción al reproducir: ' + e);
    console.warn('No se pudo reproducir el sonido de pedido nuevo:', e);
  }
}

// Desbloquea el AudioContext en la primera interacción del usuario con la
// página (click, tecla o touch) para que playNewWebOrderChime() pueda sonar
// más tarde sin gesto adicional cuando llegue el evento por ActionCable.
// Además del resume(), reproduce un tono realmente inaudible (ganancia ~0)
// DENTRO del mismo gesto — en iOS/Safari, resume() solo no siempre alcanza;
// hace falta arrancar al menos un nodo de audio en el gesto mismo para que
// el motor de audio quede desbloqueado para reproducciones futuras.
export function unlockAudioOnFirstInteraction() {
  const ctx = getContext();
  if (!ctx) return;

  const tryUnlock = () => {
    if (ctx.state === 'suspended') ctx.resume().catch(() => {});
    try {
      const osc  = ctx.createOscillator();
      const gain = ctx.createGain();
      gain.gain.value = 0.00001;
      osc.connect(gain).connect(ctx.destination);
      osc.start(ctx.currentTime);
      osc.stop(ctx.currentTime + 0.01);
    } catch (e) { /* noop */ }
    persistLog('unlockAudioOnFirstInteraction() ejecutado, ctx.state=' + ctx.state);
  };
  ['click', 'keydown', 'touchstart'].forEach((evt) => {
    document.addEventListener(evt, tryUnlock, { once: true, passive: true });
  });
}

// Gancho manual para probar el timbre desde la consola del navegador sin
// depender de que llegue un pedido real: abrir la consola en /mostrador o
// /cocina, hacer click en cualquier parte de la página y escribir
// hipapaTestChime() — si tampoco suena así, el problema es del dispositivo/
// navegador (volumen, pestaña muteada, salida de audio), no del código.
if (typeof window !== 'undefined') {
  window.hipapaTestChime = playNewWebOrderChime;
}
