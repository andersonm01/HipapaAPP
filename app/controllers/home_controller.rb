# Impresión directa ESC/POS (sin plugin)
require Rails.root.join("app/services/escpos_raw_printer.rb").to_s

class HomeController < ApplicationController
  def self.plugin_url
    ENV.fetch("PRINTER_PLUGIN_URL", "http://127.0.0.1:8000")
  end

  def index
    valor = 0 
    Order.where("id >= 62").each do |order|
      valor += order.order_items.sum(:precio_unitario)
    end
    puts "Total de valor de los productos: #{valor}"
    @orders = Order.where(status: 0).order(created_at: :desc)
    @closed_orders = Order.where(status: 1).order(created_at: :desc).limit(10)
    @new_order_id = params[:order_id].presence || params[:id].presence
    @current_order = Order.find(@new_order_id) if @new_order_id.present?
    @products = Product.where(activo: true).order(:nombre) if @current_order.present?
    @order_items = @current_order.order_items.includes(:product) if @current_order.present?
  end

  def printer_config
    @plugin_url = self.class.plugin_url
  end

  def printer_ping
    uri = URI("#{self.class.plugin_url}/version")
    response = Net::HTTP.get_response(uri)
    render body: response.body, content_type: "application/json"
  rescue StandardError => e
    render json: { error: true, message: e.message }, status: :service_unavailable
  end

  def printer_impresoras
    uri = URI("#{self.class.plugin_url}/impresoras")
    response = Net::HTTP.get_response(uri)
    render body: response.body, content_type: "application/json"
  rescue StandardError
    render json: [], status: :service_unavailable
  end

  def printer_imprimir
    uri = URI("#{self.class.plugin_url}/imprimir")
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 5
    http.read_timeout = 30
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body = request.raw_post
    response = http.request(req)
    render body: response.body, content_type: "application/json"
  rescue StandardError => e
    render json: { ok: false, message: e.message }, status: :service_unavailable
  end

  # Impresión directa ESC/POS en Windows (sin plugin, sin páginas extra)
  def printer_imprimir_raw
    payload = JSON.parse(request.raw_post)
    nombre_impresora = payload["nombreImpresora"].to_s.strip.presence || "POS-80"
    operaciones = payload["operaciones"]
    unless operaciones.is_a?(Array) && operaciones.any?
      return render json: { ok: false, message: "Faltan operaciones" }, status: :unprocessable_entity
    end

    raw_bytes = EscposRawPrinter.operaciones_to_escpos(operaciones)
    result = EscposRawPrinter.raw_print_to_windows(nombre_impresora, raw_bytes)

    if result[:ok]
      render json: { ok: true }
    else
      render json: { ok: false, message: result[:message] }, status: :unprocessable_entity
    end
  rescue JSON::ParserError
    render json: { ok: false, message: "JSON inválido" }, status: :bad_request
  rescue StandardError => e
    render json: { ok: false, message: e.message }, status: :internal_server_error
  end
end
