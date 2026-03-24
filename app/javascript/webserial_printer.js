// webserial_printer.js
// Impresión ESC/POS directo via Web Serial API — sin software adicional.
// Compatible con Chrome/Edge 89+.
// Requiere que la impresora aparezca como puerto COM/serial en Windows
// (impresoras con chip USB-serial: CH340, CH341, CP210x, FTDI, etc.)

const STORAGE_KEY = 'hipapa_webserial_port';
const DEFAULT_BAUD = 9600;
const DEFAULT_FLOW = 'none'; // 'none' | 'hardware'

// ─── Soporte ─────────────────────────────────────────────────────────────────

export function isSupported() {
  return 'serial' in navigator;
}

// ─── Persistencia del puerto ─────────────────────────────────────────────────

export function getSavedPortInfo() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEY)) || null;
  } catch {
    return null;
  }
}

function savePortInfo(port, baudRate) {
  const info = port.getInfo();
  const existing = getSavedPortInfo() || {};
  localStorage.setItem(STORAGE_KEY, JSON.stringify({
    usbVendorId:  info.usbVendorId  ?? null,
    usbProductId: info.usbProductId ?? null,
    baudRate:     baudRate || existing.baudRate || DEFAULT_BAUD,
    flowControl:  existing.flowControl || DEFAULT_FLOW
  }));
}

export function saveBaudRate(baud) {
  const info = getSavedPortInfo() || {};
  info.baudRate = parseInt(baud) || DEFAULT_BAUD;
  localStorage.setItem(STORAGE_KEY, JSON.stringify(info));
}

export function saveFlowControl(flow) {
  const info = getSavedPortInfo() || {};
  info.flowControl = (flow === 'hardware') ? 'hardware' : 'none';
  localStorage.setItem(STORAGE_KEY, JSON.stringify(info));
}

export function clearSavedPort() {
  localStorage.removeItem(STORAGE_KEY);
}

// ─── Selección de puerto ──────────────────────────────────────────────────────

/** Muestra el diálogo del navegador para elegir puerto. Requiere gesto del usuario. */
export async function requestPort(baudRate) {
  const port = await navigator.serial.requestPort();
  savePortInfo(port, baudRate || DEFAULT_BAUD);
  return port;
}

/** Devuelve el puerto previamente autorizado, o null si no hay ninguno. */
async function findSavedPort() {
  const ports = await navigator.serial.getPorts();
  if (!ports.length) return null;

  const saved = getSavedPortInfo();
  if (saved && (saved.usbVendorId != null || saved.usbProductId != null)) {
    const match = ports.find(p => {
      const info = p.getInfo();
      return info.usbVendorId === saved.usbVendorId &&
             info.usbProductId === saved.usbProductId;
    });
    if (match) return match;
  }

  // Si solo hay un puerto autorizado, usarlo directamente
  if (ports.length === 1) return ports[0];
  return null;
}

// ─── Encoder ESC/POS ─────────────────────────────────────────────────────────
// Mismo formato que qztray_printer.js — compatible con las operaciones del backend.

function operacionesToBytes(operaciones) {
  const ESC = 0x1B, GS = 0x1D;
  const buf = [];

  for (const op of operaciones) {
    const nombre = op.nombre || '';
    const args   = op.argumentos || [];

    switch (nombre) {
      case 'Iniciar':
        buf.push(ESC, 0x40);
        break;

      case 'EstablecerAlineacion': {
        const n = Math.min(Math.max(parseInt(args[0]) || 0, 0), 2);
        buf.push(ESC, 0x61, n);
        break;
      }

      case 'EstablecerTamañoFuente': {
        const w = Math.min(Math.max(parseInt(args[0]) || 1, 1), 8);
        const h = Math.min(Math.max(parseInt(args[1]) || 1, 1), 8);
        buf.push(GS, 0x21, ((w - 1) << 4) | (h - 1));
        break;
      }

      case 'EstablecerEnfatizado':
        buf.push(ESC, 0x45, args[0] ? 1 : 0);
        break;

      case 'EscribirTexto': {
        const text = (args[0] || '').toString();
        for (let i = 0; i < text.length; i++) {
          const code = text.charCodeAt(i);
          buf.push(code < 256 ? code : 0x3F /* '?' para chars fuera de latin-1 */);
        }
        break;
      }

      case 'Feed': {
        const n = Math.min(Math.max(parseInt(args[0]) || 1, 0), 255);
        buf.push(ESC, 0x64, n);
        break;
      }

      case 'Corte':
        buf.push(ESC, 0x64, 1);
        buf.push(GS, 0x56, 0);
        break;
    }
  }

  return buf;
}

// ─── Impresión ────────────────────────────────────────────────────────────────

/**
 * Envía operaciones ESC/POS a la impresora via Web Serial.
 * Usa el puerto previamente autorizado en la página de configuración.
 */
export async function printRaw(operaciones) {
  if (!isSupported()) {
    throw new Error('Web Serial no es compatible. Usa Chrome o Edge (versión 89+).');
  }

  const port = await findSavedPort();
  if (!port) {
    throw new Error('No hay puerto serial configurado. Ve a Impresora → Configurar y selecciona el puerto.');
  }

  const saved = getSavedPortInfo();
  const baudRate = saved?.baudRate || DEFAULT_BAUD;
  const bytes = new Uint8Array(operacionesToBytes(operaciones));

  // Si el puerto ya está abierto (error previo sin cerrar), intentar cerrar primero
  try { await port.close(); } catch { /* ya estaba cerrado */ }

  const flowControl = (saved?.flowControl === 'hardware') ? 'hardware' : 'none';
  await port.open({ baudRate, dataBits: 8, stopBits: 1, parity: 'none', flowControl });

  try {
    const writer = port.writable.getWriter();
    await writer.write(bytes);
    // Esperar a que el SO vacíe el buffer serial antes de cerrar el puerto.
    // writer.write() completa cuando los bytes entran al buffer del navegador,
    // no cuando salen físicamente por el cable. Sin este delay el puerto
    // se cierra antes de que terminen de enviarse.
    await new Promise(r => setTimeout(r, 600));
    writer.releaseLock();
  } finally {
    await port.close();
  }
}
