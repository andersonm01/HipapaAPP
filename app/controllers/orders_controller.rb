class OrdersController < ApplicationController
  # El formulario "Nuevo Pedido" crea la orden y confirma los productos
  # elegidos en un solo paso (fetch con Accept: json), en vez del flujo
  # anterior de crear la orden vacía y confirmar productos por separado.
  def create
    Rails.logger.debug "Params recibidos: #{params.inspect}"
    @order = Order.new(order_params)

    ActiveRecord::Base.transaction do
      @order.save!
      apply_order_items(@order, params[:order_items]) if params[:order_items].present?
    end

    Rails.logger.debug "Order guardado exitosamente"
    ActionCable.server.broadcast("orders_channel", {
      type: "order_created",
      order: {
        id: @order.id,
        cliente: @order.cliente,
        total: @order.total,
        status: @order.status,
        created_at: @order.created_at.strftime("%d/%m/%Y %H:%M:%S")
      }
    })

    respond_to do |format|
      format.json do
        render json: {
          id: @order.id,
          cliente: @order.cliente,
          tipo_servicio: @order.tipo_servicio,
          created_at: @order.created_at.strftime("%d/%m/%y %H:%M")
        }
      end
      format.html do
        # Redirigir por JavaScript para que la URL ?order_id= no se pierda (Turbo/navegador)
        flash[:notice] = 'Pedido creado exitosamente.'
        render html: <<~HTML.html_safe, layout: false, content_type: 'text/html'
          <!DOCTYPE html>
          <html><head><meta charset="utf-8"><title>Redirigiendo...</title></head>
          <body>
          <script>window.location.replace("#{mostrador_path(order_id: @order.id)}");</script>
          <p>Redirigiendo...</p>
          </body></html>
        HTML
      end
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    Rails.logger.debug "Errores: #{e.message}"
    mensaje = @order.errors.any? ? @order.errors.full_messages.join(', ') : e.message
    respond_to do |format|
      format.json { render json: { error: mensaje }, status: :unprocessable_entity }
      format.html do
        flash[:alert] = "Error al crear el pedido: #{mensaje}"
        redirect_to mostrador_path
      end
    end
  end

  def confirm_items
    @order = Order.find(params[:id])

    # Verificar que el pedido esté abierto
    unless @order.open?
      redirect_to pedido_path(@order.id), alert: 'No se pueden agregar productos a un pedido cerrado o cancelado.'
      return
    end

    # Tipo de servicio: viaja en el mismo formulario que los productos, así
    # se guarda junto con ellos al confirmar (sin recargar ni perder la
    # selección de productos aún no confirmados).
    servicio_actualizado = false
    tipo_servicio = params[:tipo_servicio].to_s
    if %w[mesa llevar domicilio].include?(tipo_servicio) && tipo_servicio != @order.tipo_servicio
      @order.update(tipo_servicio: tipo_servicio)
      servicio_actualizado = true
    end

    # Recibir array de productos con comentarios
    if params[:order_items].present?
      apply_order_items(@order, params[:order_items])

      # Si la orden ya estaba entregada, vuelve a aparecer en cocina con nuevos productos
      @order.update(kitchen_status: 'preparing') if @order.kitchen_status == 'delivered'

      # Transmitir actualización en tiempo real
      ActionCable.server.broadcast("orders_channel", {
        type: "order_updated",
        order: {
          id: @order.id,
          total: @order.total,
          status: @order.status
        }
      })
      ActionCable.server.broadcast("cocina_channel", {
        type: "kitchen_status_updated",
        order_id: @order.id,
        kitchen_status: @order.kitchen_status
      })

      redirect_to pedido_path(@order.id), notice: 'Productos confirmados exitosamente.'
    elsif servicio_actualizado
      ActionCable.server.broadcast("orders_channel", {
        type: "order_updated",
        order: { id: @order.id, total: @order.total, status: @order.status }
      })
      redirect_to pedido_path(@order.id), notice: 'Tipo de servicio actualizado.'
    else
      redirect_to pedido_path(@order.id), alert: 'No hay productos ni cambios de servicio para confirmar.'
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Error en confirm_items: #{e.message}"
    redirect_to mostrador_path, alert: 'Error: No se encontró la orden o el producto.'
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error en confirm_items: #{e.message}"
    redirect_to pedido_path(@order.id), alert: "Error al confirmar productos: #{e.message}"
  end

  def close_order
    @order = Order.find(params[:id])

    monto_pagado = params[:monto_pagado].to_f
    tipo_pago    = params[:tipo_pago]
    vuelto       = params[:vuelto].to_f
    customer_id  = params[:customer_id].presence

    ActiveRecord::Base.transaction do
      @order.update!(
        status:      Order::STATUS_CLOSED,
        monto_pagado: monto_pagado,
        tipo_pago:   tipo_pago,
        vuelto:      vuelto,
        total:       @order.total_calculado,
        customer_id: customer_id,
        user_id:     current_user&.id
      )

      # Generar factura
      Invoices::GeneratorService.new(@order).call

      # Descontar stock
      Stock::DeductService.new(@order).call

      # Registrar en caja si hay una abierta
      caja = CashRegister.caja_abierta_para(current_user)
      Cash::RegisterService.new(caja).record_sale(@order) if caja
    end

    ActionCable.server.broadcast("orders_channel", {
      type: "order_closed",
      order: { id: @order.id, status: @order.status, total: @order.total }
    })

    redirect_to mostrador_path, notice: 'Pedido cerrado exitosamente.'
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Error en close_order: #{e.message}"
    redirect_to mostrador_path, alert: 'Error: No se encontró la orden.'
  rescue => e
    Rails.logger.error "Error en close_order: #{e.message}"
    redirect_to mostrador_path, alert: "Error al cerrar el pedido: #{e.message}"
  end

  def cancel_order
    @order = Order.find(params[:id])
    unless @order.open?
      redirect_to pedido_path(@order.id), alert: 'Solo se pueden cancelar pedidos abiertos.'
      return
    end
    motivo = params[:cancel_reason].to_s.strip
    if @order.update(status: Order::STATUS_CANCELLED, cancel_reason: motivo, cancelled_at: Time.current)
      ActionCable.server.broadcast("orders_channel", {
        type: "order_cancelled",
        order: { id: @order.id }
      })
      redirect_to mostrador_path, notice: "Pedido ##{@order.id} cancelado."
    else
      redirect_to pedido_path(@order.id), alert: "Error al cancelar el pedido."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to mostrador_path, alert: 'No se encontró el pedido.'
  end

  def destroy_item
    @order = Order.find(params[:id])
    unless @order.open?
      redirect_to pedido_path(@order.id), alert: 'No se pueden eliminar productos de un pedido cerrado o cancelado.'
      return
    end
    item = @order.order_items.find(params[:item_id])
    item.destroy
    ActionCable.server.broadcast("orders_channel", {
      type: "order_updated",
      order: { id: @order.id, total: @order.reload.total, status: @order.status }
    })
    redirect_to pedido_path(@order.id), notice: 'Producto eliminado del pedido.'
  rescue ActiveRecord::RecordNotFound
    redirect_to pedido_path(@order.id), alert: 'No se encontró el producto en este pedido.'
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to mostrador_path, notice: 'Pedido eliminado.'
  rescue ActiveRecord::RecordNotFound
    redirect_to mostrador_path, alert: 'No se encontró el pedido.'
  end

  def update_kitchen_status
    @order = Order.find(params[:id])
    new_status = params[:kitchen_status].to_s
    unless Order::KITCHEN_STATUSES.include?(new_status)
      redirect_to cocina_path, alert: 'Estado de cocina invalido.'
      return
    end
    if @order.update(kitchen_status: new_status)
      ActionCable.server.broadcast("cocina_channel", {
        type: "kitchen_status_updated",
        order_id: @order.id,
        kitchen_status: new_status
      })
      redirect_to cocina_path
    else
      redirect_to cocina_path, alert: 'Error al actualizar el estado de cocina.'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to cocina_path, alert: 'No se encontro la orden.'
  end

  def update_servicio
    @order = Order.find(params[:id])
    unless @order.open?
      redirect_to pedido_path(@order.id), alert: 'No se puede cambiar el tipo de servicio en un pedido cerrado o cancelado.'
      return
    end
    tipo = params[:tipo_servicio].to_s
    unless %w[mesa llevar domicilio].include?(tipo)
      redirect_to pedido_path(@order.id), alert: 'Tipo de servicio no válido.'
      return
    end
    if @order.update(tipo_servicio: tipo)
      redirect_to pedido_path(@order.id), notice: 'Tipo de servicio actualizado.'
    else
      redirect_to pedido_path(@order.id), alert: 'Error al actualizar.'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to mostrador_path, alert: 'No se encontró el pedido.'
  end

  private

  # Agrega/mergea productos a una orden a partir de un hash con la forma
  # { "0" => { product_id:, cantidad:, comentario: }, "1" => {...} }.
  # Usado tanto al crear un pedido con productos ya elegidos (create) como
  # al confirmar productos sobre un pedido existente (confirm_items).
  def apply_order_items(order, items_params)
    items_params.each do |_key, item_params|
      product = Product.find(item_params[:product_id])
      cantidad = item_params[:cantidad].to_i
      cantidad = 1 if cantidad < 1
      comentario = item_params[:comentario].to_s.strip

      order_item = order.order_items.find_by(product_id: product.id)

      if order_item
        new_comentario = if order_item.comentario.present? && comentario.present?
          "#{order_item.comentario}; #{comentario}"
        elsif comentario.present?
          comentario
        else
          order_item.comentario
        end

        order_item.update!(
          cantidad: order_item.cantidad + cantidad,
          comentario: new_comentario
        )
      else
        order.order_items.create!(
          product: product,
          cantidad: cantidad,
          precio_unitario: product.precio,
          comentario: comentario
        )
      end
    end
  end

  def order_params
    params.permit(:cliente, :mesero, :comentario, :tipo_servicio, :customer_id, :user_id, :canal)
  end
end
