class HomeController < ApplicationController
  def index
    @orders = Order.all
    @new_order_id = params[:order_id] if params[:order_id].present?
    @current_order = Order.find(@new_order_id) if @new_order_id.present?
  end
end
