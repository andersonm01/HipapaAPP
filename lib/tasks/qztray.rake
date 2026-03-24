# lib/tasks/qztray.rake
# Genera el par de claves RSA para firmar conexiones de QZ Tray.
# Uso: bin/rails qztray:generate_cert
namespace :qztray do
  desc "Genera certificado autofirmado para identificar el sitio ante QZ Tray"
  task generate_cert: :environment do
    require 'openssl'

    dir       = Rails.root.join('config', 'qztray')
    cert_path = dir.join('certificate.pem')
    key_path  = dir.join('private_key.pem')

    FileUtils.mkdir_p(dir)

    if cert_path.exist? && key_path.exist?
      puts "El certificado ya existe en #{dir}."
      puts "Elimina los archivos manualmente si deseas regenerarlos."
      next
    end

    key = OpenSSL::PKey::RSA.new(2048)

    cert = OpenSSL::X509::Certificate.new
    cert.version    = 2
    cert.serial     = 1
    cert.subject    = OpenSSL::X509::Name.parse('/CN=HipapaAPP/O=Hipapa POS/C=CO')
    cert.issuer     = cert.subject
    cert.public_key = key.public_key
    cert.not_before = Time.now
    cert.not_after  = Time.now + (10 * 365 * 24 * 60 * 60)
    cert.sign(key, OpenSSL::Digest::SHA256.new)

    File.write(key_path,  key.to_pem)
    File.write(cert_path, cert.to_pem)

    puts "Certificado generado:"
    puts "  Llave privada : #{key_path}"
    puts "  Certificado   : #{cert_path}"
    puts ""
    puts "Reinicia el servidor Rails. La proxima vez que imprimas, QZ Tray"
    puts "preguntara una sola vez 'Hipapa POS quiere conectarse'. Haz clic en"
    puts "'Allow always' y no volvera a preguntar."
  end
end
