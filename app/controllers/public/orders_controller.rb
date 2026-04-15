class Public::OrdersController < ApplicationController
  skip_before_action :require_login
  skip_before_action :verify_authenticity_token, only: [:create]
  layout 'public'

  def create
    items_raw = JSON.parse(params[:cart_items] || '[]')

    ActiveRecord::Base.transaction do
      @order = Order.create!(
        cliente:         params[:nombre].to_s.strip,
        tipo_servicio:   params[:tipo_servicio] || 'llevar',
        comentario:      params[:notas].to_s.strip,
        canal:           'web',
        kitchen_status:  'pending',
        status:          Order::STATUS_OPEN
      )

      # Asociar cliente si existe
      if params[:whatsapp].present?
        customer = Customer.find_or_create_by(whatsapp: params[:whatsapp].gsub(/\D/, '')) do |c|
          c.nombre    = params[:nombre]
          c.direccion = params[:direccion]
        end
        @order.update!(customer: customer)
      end

      items_raw.each do |item|
        product = Product.activos.find(item['product_id'])
        @order.order_items.create!(
          product:         product,
          cantidad:        item['cantidad'].to_i,
          precio_unitario: product.precio,
          comentario:      item['notas'].to_s
        )
      end
    end

    ActionCable.server.broadcast("orders_channel", {
      type:     "new_web_order",
      order_id: @order.id,
      canal:    'web'
    })

    redirect_to public_order_status_path(@order.id)
  rescue JSON::ParserError, ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid => e
    flash[:alert] = "Error al procesar el pedido: #{e.message}"
    redirect_to public_menu_path
  end

  def status
    @order = Order.includes(order_items: :product).find(params[:id])
    @business = BusinessSetting.current
  end
end
