// qztray_printer.js
// Bridge entre las operaciones ESC/POS del app y QZ Tray (wss://localhost:8181).
// `qz` es un global inyectado por qz-tray.min.js cargado en el layout.
//
// Uso:
//   import { printRaw, getPrinters, getSavedPrinter, savePrinter } from 'qztray_printer';
//   await printRaw('POS-80', operaciones);

const STORAGE_KEY = 'hipapa_impresora_qz';

// ─── Conexión ────────────────────────────────────────────────────────────────

let _connectPromise = null;

async function connect() {
  if (typeof qz === 'undefined') {
    throw new Error('QZ Tray JS no cargado. Verifica la conexión a internet o recarga la página.');
  }
  if (qz.websocket.isActive()) return;
  if (_connectPromise) return _connectPromise;

  // Modo sin firma de código: QZ Tray mostrará un popup "¿Permitir esta conexión?"
  // la primera vez. El usuario elige "Permitir siempre" y no vuelve a aparecer.
  qz.security.setCertificatePromise((resolve) => resolve());
  qz.security.setSignatureAlgorithm('SHA512');
  qz.security.setSignaturePromise(() => (resolve) => resolve());

  _connectPromise = qz.websocket
    .connect({ retries: 3, delay: 0.5 })
    .then(() => { _connectPromise = null; })
    .catch((err) => { _connectPromise = null; throw err; });

  return _connectPromise;
}

// ─── Impresoras ──────────────────────────────────────────────────────────────

/** Devuelve array de nombres de impresoras disponibles en el PC. */
async function getPrinters() {
  await connect();
  return await qz.printers.find();
}

/** Nombre guardado en localStorage, o null. */
function getSavedPrinter() {
  return localStorage.getItem(STORAGE_KEY) || null;
}

/** Persiste el nombre de impresora en localStorage. */
function savePrinter(name) {
  if (name) localStorage.setItem(STORAGE_KEY, name);
  else localStorage.removeItem(STORAGE_KEY);
}

// ─── Encoder ESC/POS ─────────────────────────────────────────────────────────
// Puerto exacto de EscposRawPrinter#operaciones_to_escpos (Ruby → JS).

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
          // ISO-8859-1 / Windows-1252: la mayoría de impresoras POS lo esperan
          buf.push(code < 256 ? code : 0x3F /* '?' */);
        }
        break;
      }

      case 'Feed': {
        const n = Math.min(Math.max(parseInt(args[0]) || 1, 0), 255);
        buf.push(ESC, 0x64, n);
        break;
      }

      case 'Corte':
        buf.push(ESC, 0x64, 1); // avance previo
        buf.push(GS, 0x56, 0);  // corte completo
        break;
    }
  }

  return buf;
}

// ─── Impresión ───────────────────────────────────────────────────────────────

/**
 * Envía operaciones ESC/POS a la impresora a través de QZ Tray.
 * @param {string} printerName  Nombre exacto de la impresora (ej: "POS-80")
 * @param {Array}  operaciones  Array de { nombre, argumentos } igual al formato del backend
 */
async function printRaw(printerName, operaciones) {
  await connect();

  const bytes = operacionesToBytes(operaciones);

  // QZ Tray acepta base64 para datos raw binarios
  const raw = bytes.map(b => String.fromCharCode(b)).join('');
  const b64 = btoa(raw);

  const config = qz.configs.create(printerName);
  await qz.print(config, [{ type: 'raw', format: 'command', flavor: 'base64', data: b64 }]);
}

/**
 * Imprime y usa el printer guardado en localStorage si no se especifica uno.
 * Lanza excepción si QZ Tray no está disponible o la impresora no existe.
 */
async function printComandaQZ(operaciones) {
  const printer = getSavedPrinter();
  if (!printer) throw new Error('No hay impresora configurada. Ve a Impresora → Configurar.');
  await printRaw(printer, operaciones);
}

export { connect, getPrinters, getSavedPrinter, savePrinter, printRaw, printComandaQZ };
