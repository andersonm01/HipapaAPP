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

// Duración total aproximada del timbre, en ms — quien llame a
// playNewWebOrderChime() puede esperar este tiempo antes de recargar la
// página para no cortar el sonido a mitad.
export const NEW_WEB_ORDER_CHIME_MS = 850;

export function playNewWebOrderChime() {
  try {
    const ctx = getContext();
    if (!ctx) return;
    if (ctx.state === 'suspended') ctx.resume().catch(() => {});

    tone(ctx, 880,  0,    0.18, 0.3);  // La5
    tone(ctx, 1175, 0.16, 0.28, 0.3);  // Re6
    tone(ctx, 1568, 0.34, 0.42, 0.25); // Sol6
  } catch (e) {
    console.warn('No se pudo reproducir el sonido de pedido nuevo:', e);
  }
}
