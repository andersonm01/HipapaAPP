class HomeController < ApplicationController
  def index
    @orders = Order.where(status: 0).order(created_at: :desc)
    @closed_orders = Order.where(status: 1).order(created_at: :desc).limit(10)
    @new_order_id = params[:order_id] if params[:order_id].present?
    @current_order = Order.find(@new_order_id) if @new_order_id.present?
    @products = Product.where(activo: true).order(:nombre) if @current_order.present?
    @order_items = @current_order.order_items.includes(:product) if @current_order.present?
  end
end
