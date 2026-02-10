class PrinterController < ApplicationController
  PLUGIN_URL = "http://127.0.0.1:8000"

  def config
  end

  def ping
    uri = URI("#{PLUGIN_URL}/version")
    response = Net::HTTP.get_response(uri)
    render json: response.body, status: :ok
  rescue StandardError => e
    render json: { error: true, message: e.message }, status: :service_unavailable
  end

  def impresoras
    uri = URI("#{PLUGIN_URL}/impresoras")
    response = Net::HTTP.get_response(uri)
    render json: response.body, status: :ok
  rescue StandardError
    render json: [], status: :service_unavailable
  end

  def imprimir
    uri = URI("#{PLUGIN_URL}/imprimir")
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 5
    http.read_timeout = 30
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body = request.raw_post
    response = http.request(req)
    render json: response.body, status: :ok
  rescue StandardError => e
    render json: { ok: false, message: e.message }, status: :service_unavailable
  end
end
