class Public::LandingController < ApplicationController
  skip_before_action :require_login
  layout 'landing'

  # Orden de categorías en la vitrina: Papas primero (lo que realmente
  # vendemos), el resto en el orden que ya trae la query. "Domicilio" se
  # excluye siempre (es un cargo que se agrega al pedido, no algo que el
  # cliente elija navegando el menú).
  CATEGORIA_ORDEN = ['Papas'].freeze

  def index
    @business = BusinessSetting.current
    menu_productos = Product.activos.where.not(categoria: 'Domicilio')
    # Destacados: solo Papas, es lo que se quiere resaltar en la portada.
    @destacados = menu_productos.where.not(categoria: 'Bebidas').por_posicion.limit(6)
    @productos_por_categoria = menu_productos.por_categoria.group_by(&:categoria)
                                              .sort_by { |categoria, _| CATEGORIA_ORDEN.index(categoria) || CATEGORIA_ORDEN.size }
                                              .to_h

    # Fotos reales de productos para la galería — si no hay suficientes, la sección se omite en la vista.
    @fotos_galeria = menu_productos.with_attached_foto.to_a.select { |p| p.foto.attached? }.first(8)
  end
end
