# frozen_string_literal: true

class ReportsController < ApplicationController
  def index
    @periodo = params[:periodo].presence || "dia"
    @fecha = params[:fecha].presence ? Date.parse(params[:fecha]) : Date.current

    base = Order.where(status: 1)
    rango = rango_para_periodo(@fecha, @periodo)
    @orders = base.where(created_at: rango)

    # Agrupar productos vendidos: { product_id => { nombre, cantidad, total } }
    @productos_vendidos = OrderItem
      .joins(:order, :product)
      .where(orders: { id: @orders.select(:id) })
      .group("products.id", "products.nombre")
      .select(
        "products.id",
        "products.nombre",
        "SUM(order_items.cantidad) AS cantidad_total",
        "SUM(order_items.cantidad * order_items.precio_unitario) AS monto_total"
      )
      .order("cantidad_total DESC")

    @total_general = @productos_vendidos.sum { |p| p.monto_total.to_d }
  end

  private

  def rango_para_periodo(fecha, periodo)
    case periodo.to_s
    when "dia"
      fecha.beginning_of_day..fecha.end_of_day
    when "semana"
      fecha.beginning_of_week..fecha.end_of_week
    when "mes"
      fecha.beginning_of_month..fecha.end_of_month
    when "año", "anio"
      fecha.beginning_of_year..fecha.end_of_year
    else
      fecha.beginning_of_day..fecha.end_of_day
    end
  end
end
