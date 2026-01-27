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

  def confirm_items
    @order = Order.find(params[:id])
    
    # Verificar que el pedido no esté cerrado
    if @order.status != 0
      redirect_to root_path(order_id: @order.id), alert: 'No se pueden agregar productos a un pedido cerrado.'
      return
    end
    
    # Recibir array de productos con comentarios
    if params[:order_items].present?
      params[:order_items].each do |key, item_params|
        product = Product.find(item_params[:product_id])
        cantidad = item_params[:cantidad].to_i
        cantidad = 1 if cantidad < 1
        comentario = item_params[:comentario].to_s.strip
        
        # Buscar si ya existe el producto en la orden
        order_item = @order.order_items.find_by(product_id: product.id)
        
        if order_item
          # Si existe, actualizar cantidad y comentario
          new_comentario = if order_item.comentario.present? && comentario.present?
            "#{order_item.comentario}; #{comentario}"
          elsif comentario.present?
            comentario
          else
            order_item.comentario
          end
          
          order_item.update(
            cantidad: order_item.cantidad + cantidad,
            comentario: new_comentario
          )
        else
          # Si no existe, crear nuevo item
          @order.order_items.create(
            product: product,
            cantidad: cantidad,
            precio_unitario: product.precio,
            comentario: comentario
          )
        end
      end
      
      redirect_to root_path(order_id: @order.id), notice: 'Productos confirmados exitosamente.'
    else
      redirect_to root_path(order_id: @order.id), alert: 'No hay productos para confirmar.'
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Error en confirm_items: #{e.message}"
    redirect_to root_path, alert: 'Error: No se encontró la orden o el producto.'
  end

  def close_order
    @order = Order.find(params[:id])
    
    monto_pagado = params[:monto_pagado].to_f
    tipo_pago = params[:tipo_pago]
    vuelto = params[:vuelto].to_f
    
    if @order.update(
      status: 1,
      monto_pagado: monto_pagado,
      tipo_pago: tipo_pago,
      vuelto: vuelto
    )
      redirect_to root_path, notice: 'Pedido cerrado exitosamente.'
    else
      redirect_to root_path, alert: "Error al cerrar el pedido: #{@order.errors.full_messages.join(', ')}"
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Error en close_order: #{e.message}"
    redirect_to root_path, alert: 'Error: No se encontró la orden.'
  end

  private

  def order_params
    # form_with con url: envía los parámetros directamente, no anidados
    params.permit(:cliente, :mesero, :comentario)
  end
end
