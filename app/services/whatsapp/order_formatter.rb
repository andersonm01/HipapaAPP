module Whatsapp
  class OrderFormatter
    def initialize(items:, customer_info:, business_phone: nil)
      @items         = items
      @customer_info = customer_info
      @business_phone = business_phone || BusinessSetting.current.whatsapp_negocio
    end

    def message
      lines = ["*Pedido Hi Papa* 🍔", ""]

      @items.each do |item|
        lines << "• #{item[:cantidad]}x #{item[:nombre]} — $#{format_price(item[:precio] * item[:cantidad])}"
        lines << "  _#{item[:notas]}_" if item[:notas].present?
        if item[:salsas]&.any?
          lines << "  Salsas: #{item[:salsas].join(', ')}"
        end
      end

      lines << ""
      lines << "*Total: $#{format_price(total)}*"
      lines << "*Tipo: #{tipo_label}*"
      lines << "*Cliente: #{@customer_info[:nombre]}*" if @customer_info[:nombre].present?
      lines << "*Dirección: #{@customer_info[:direccion]}*" if @customer_info[:direccion].present?
      lines << "*Notas: #{@customer_info[:notas]}*"         if @customer_info[:notas].present?

      lines.join("\n")
    end

    def whatsapp_url
      encoded = URI.encode_www_form_component(message)
      "https://wa.me/#{clean_phone}?text=#{encoded}"
    end

    private

    def total
      @items.sum { |i| i[:precio].to_f * i[:cantidad].to_i }
    end

    def tipo_label
      case @customer_info[:tipo_servicio]
      when 'domicilio' then 'Domicilio'
      when 'llevar'    then 'Para llevar'
      else                  'En mesa'
      end
    end

    def format_price(n)
      format('%.0f', n)
    end

    def clean_phone
      @business_phone.to_s.gsub(/\D/, '')
    end
  end
end
