class OrdersController < ApplicationController
  def create
    Rails.logger.debug "Params recibidos: #{params.inspect}"
    @order = Order.new(order_params)
    Rails.logger.debug "Order creado: #{@order.inspect}"
    
    if @order.save
      Rails.logger.debug "Order guardado exitosamente"
      redirect_to root_path(order_id: @order.id), notice: 'Pedido creado exitosamente.'
    else
      Rails.logger.debug "Errores: #{@order.errors.full_messages}"
      flash[:alert] = "Error al crear el pedido: #{@order.errors.full_messages.join(', ')}"
      redirect_to root_path
    end
  end

  private

  def order_params
    # form_with con url: envía los parámetros directamente, no anidados
    params.permit(:cliente, :mesero, :comentario)
  end
end
