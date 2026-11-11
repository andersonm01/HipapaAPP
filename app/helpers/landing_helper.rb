# Helpers de la home pública (landing). Centralizan el formato de precios y
# los enlaces externos (WhatsApp, Google Maps) para que los partials queden
# limpios y todos armen las URLs igual.
module LandingHelper
  # Mismo formato de precio que ya usaba la landing y el menú público.
  def hp_precio(valor)
    "$#{number_with_precision(valor, precision: 0, delimiter: ',')}"
  end

  def hp_telefono_link(telefono)
    "tel:#{telefono.to_s.gsub(/\D/, '')}"
  end

  # wa.me con mensaje opcional pre-cargado.
  def hp_whatsapp_url(numero, texto = nil)
    numero = numero.to_s.gsub(/\D/, '')
    return nil if numero.blank?

    url = "https://wa.me/#{numero}"
    url += "?text=#{ERB::Util.url_encode(texto)}" if texto.present?
    url
  end

  def hp_maps_url(direccion)
    "https://www.google.com/maps/search/?api=1&query=#{ERB::Util.url_encode(direccion)}"
  end

  def hp_maps_directions_url(direccion)
    "https://www.google.com/maps/dir/?api=1&destination=#{ERB::Util.url_encode(direccion)}"
  end

  # Mapa embebido sin API key (modo "output=embed" de Google Maps).
  def hp_maps_embed_url(direccion)
    "https://www.google.com/maps?q=#{ERB::Util.url_encode(direccion)}&output=embed"
  end
end
