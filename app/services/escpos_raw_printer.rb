# frozen_string_literal: true

require "open3"
require "tempfile"

# Convierte operaciones (estilo plugin Parzibyte) a bytes ESC/POS y envía a impresora en Windows.
# Sin plugin, sin páginas extra. Solo Windows.
class EscposRawPrinter
  ESC = "\x1B"
  GS = "\x1D"

  def self.operaciones_to_escpos(operaciones)
    buf = +""
    buf.force_encoding(Encoding::ASCII_8BIT)
    operaciones.each do |op|
      nombre = op["nombre"] || op[:nombre]
      args = op["argumentos"] || op[:argumentos] || []
      case nombre.to_s
      when "Iniciar"
        buf << "#{ESC}@"
      when "EstablecerAlineacion"
        n = (args[0].to_i rescue 0).clamp(0, 2)
        buf << "#{ESC}a#{n.chr}"
      when "EstablecerTamañoFuente"
        w = (args[0].to_i rescue 1).clamp(1, 8)
        h = (args[1].to_i rescue 1).clamp(1, 8)
        n = ((w - 1) << 4) | (h - 1)
        buf << "#{GS}!#{n.chr}"
      when "EstablecerEnfatizado"
        n = args[0] ? 1 : 0
        buf << "#{ESC}E#{n.chr}"
      when "EscribirTexto"
        t = (args[0].to_s).encode(Encoding::ASCII_8BIT, invalid: :replace, undef: :replace)
        buf << t
      when "Feed"
        n = (args[0].to_i rescue 1).clamp(0, 255)
        buf << "#{ESC}d#{n.chr}"
      when "Corte"
        # Corte completo (GS V 0) es el más compatible; avance antes para vaciar búfer
        buf << "#{ESC}d#{1.chr}"
        buf << "#{GS}V#{0.chr}"
      end
    end
    buf
  end

  def self.windows?
    RbConfig::CONFIG["host_os"] =~ /mswin|mingw|cygwin/i
  end

  def self.raw_print_to_windows(printer_name, raw_bytes)
    require "open3"
    require "tempfile"

    return { ok: false, message: "Solo Windows" } unless windows?
    return { ok: false, message: "Impresora en blanco" } if printer_name.to_s.strip.empty?

    tmp = Tempfile.new(["escpos", ".bin"])
    tmp.binmode
    tmp.write(raw_bytes)
    tmp.close
    path = tmp.path
    script = <<~PS1
      $printer = #{printer_name.to_s.inspect}
      $file = #{path.to_s.inspect}
      $bytes = [System.IO.File]::ReadAllBytes($file)
      Add-Type -TypeDefinition @"
      using System;
      using System.Runtime.InteropServices;
      public class RawPrinter {
        [DllImport("winspool.Drv", EntryPoint="OpenPrinterA", SetLastError=true)]
        public static extern bool OpenPrinter(string pPrinterName, out IntPtr phPrinter, IntPtr pDefault);
        [DllImport("winspool.Drv", EntryPoint="ClosePrinter", SetLastError=true)]
        public static extern bool ClosePrinter(IntPtr hPrinter);
        [DllImport("winspool.Drv", EntryPoint="StartDocPrinterA", SetLastError=true)]
        public static extern bool StartDocPrinter(IntPtr hPrinter, int level, IntPtr pDocInfo);
        [DllImport("winspool.Drv", EntryPoint="EndDocPrinter", SetLastError=true)]
        public static extern bool EndDocPrinter(IntPtr hPrinter);
        [DllImport("winspool.Drv", EntryPoint="StartPagePrinter", SetLastError=true)]
        public static extern bool StartPagePrinter(IntPtr hPrinter);
        [DllImport("winspool.Drv", EntryPoint="EndPagePrinter", SetLastError=true)]
        public static extern bool EndPagePrinter(IntPtr hPrinter);
        [DllImport("winspool.Drv", EntryPoint="WritePrinter", SetLastError=true)]
        public static extern bool WritePrinter(IntPtr hPrinter, IntPtr pBytes, int dwCount, out int dwWritten);
      }
"@
      $DOC_INFO = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(3 * [IntPtr]::Size)
      [System.Runtime.InteropServices.Marshal]::WriteIntPtr($DOC_INFO, 0, [System.Runtime.InteropServices.Marshal]::StringToCoTaskMemAnsi("Raw"))
      [System.Runtime.InteropServices.Marshal]::WriteIntPtr($DOC_INFO, [IntPtr]::Size, [IntPtr]::Zero)
      [System.Runtime.InteropServices.Marshal]::WriteIntPtr($DOC_INFO, 2 * [IntPtr]::Size, [System.Runtime.InteropServices.Marshal]::StringToCoTaskMemAnsi("RAW"))
      $hPrinter = [IntPtr]::Zero
      if (-not [RawPrinter]::OpenPrinter($printer, [ref]$hPrinter, [IntPtr]::Zero)) { exit 1 }
      try {
        if (-not [RawPrinter]::StartDocPrinter($hPrinter, 1, $DOC_INFO)) { exit 2 }
        if (-not [RawPrinter]::StartPagePrinter($hPrinter)) { exit 3 }
        $ptr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($bytes.Length)
        [System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $ptr, $bytes.Length)
        $written = 0
        $ok = [RawPrinter]::WritePrinter($hPrinter, $ptr, $bytes.Length, [ref]$written)
        [System.Runtime.InteropServices.Marshal]::FreeHGlobal($ptr)
        if (-not $ok) { exit 4 }
        [RawPrinter]::EndPagePrinter($hPrinter) | Out-Null
        [RawPrinter]::EndDocPrinter($hPrinter) | Out-Null
      } finally {
        [RawPrinter]::ClosePrinter($hPrinter) | Out-Null
      }
      [System.Runtime.InteropServices.Marshal]::FreeHGlobal($DOC_INFO)
    PS1
    out = nil
    err = nil
    exit_code = nil
    Open3.popen3("powershell", "-NoProfile", "-NonInteractive", "-Command", script) do |_stdin, stdout, stderr, wait_thr|
      out = stdout.read
      err = stderr.read
      exit_code = wait_thr.value&.exitstatus
    end
    tmp.unlink
    exit_code ||= -1
    if exit_code == 0
      { ok: true }
    else
      { ok: false, message: "Raw print falló (exit #{exit_code}). #{err.presence || out}".strip }
    end
  rescue StandardError => e
    tmp&.unlink
    { ok: false, message: e.message }
  end
end
