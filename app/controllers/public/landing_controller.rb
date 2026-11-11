class Public::LandingController < ApplicationController
  skip_before_action :require_login
  layout 'landing'

  # Orden de categorías en la vitrina: Papas primero (lo que realmente
  # vendemos), el resto en el orden que ya trae la query. "Domicilio" se
  # excluye siempre (es un cargo que se agrega al pedido, no algo que el
  # cliente elija navegando el menú).
  CATEGORIA_ORDEN = ['Papas'].freeze

  # Cuántos productos se muestran en la franja de destacados.
  DESTACADOS = 3

  # Un producto se marca como "Nuevo" solo si se creó dentro de esta ventana.
  VENTANA_NUEVO = 21.days

  def index
    @business = BusinessSetting.current
    menu_productos = Product.activos.with_attached_foto.where.not(categoria: 'Domicilio')
    @productos_por_categoria = menu_productos.por_categoria.group_by(&:categoria)
                                              .sort_by { |categoria, _| CATEGORIA_ORDEN.index(categoria) || CATEGORIA_ORDEN.size }
                                              .to_h

    productos = @productos_por_categoria.values.flatten
    @mas_vendidos_ids = mas_vendidos_ids(productos)
    @destacados       = destacados(productos)
    @nuevos_ids       = productos.select { |p| p.created_at && p.created_at > VENTANA_NUEVO.ago }.map(&:id)

    # Fotos reales de productos para la galería — solo Papas, no bebidas.
    # Si no hay suficientes, la sección se omite en la vista.
    @fotos_galeria = menu_productos.where(categoria: 'Papas').with_attached_foto.to_a.select { |p| p.foto.attached? }.first(8)
  end

  private

  # Ranking real de ventas (ítems vendidos en pedidos cerrados). No inventamos
  # "los favoritos": si todavía no hay ventas registradas, esto queda vacío y
  # ni las etiquetas ni la sección de destacados usan ese criterio.
  def mas_vendidos_ids(productos)
    return [] if productos.empty?

    OrderItem.joins(:order)
             .where(orders: { status: Order::STATUS_CLOSED }, product_id: productos.map(&:id))
             .group(:product_id)
             .order(Arel.sql('SUM(cantidad) DESC'))
             .limit(DESTACADOS)
             .pluck(:product_id)
  rescue StandardError => e
    Rails.logger.warn("Landing: no se pudo calcular el ranking de ventas — #{e.class}: #{e.message}")
    []
  end

  # Destacados = los más vendidos. Sin datos de venta suficientes, se completa
  # con las primeras Papas del menú (el producto principal del negocio).
  def destacados(productos)
    por_id = productos.index_by(&:id)
    elegidos = @mas_vendidos_ids.filter_map { |id| por_id[id] }
    return elegidos if elegidos.size >= DESTACADOS

    relleno = productos.select { |p| p.categoria == 'Papas' } .presence || productos
    (elegidos + (relleno - elegidos)).first(DESTACADOS)
  end
end
