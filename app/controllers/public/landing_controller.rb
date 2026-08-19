class Public::LandingController < ApplicationController
  skip_before_action :require_login
  layout 'landing'

  # Orden de categorías en la vitrina: Papas primero (lo que realmente
  # vendemos), el resto en el orden que ya trae la query. "Domicilio" se
  # excluye por completo (es un cargo que se agrega al pedido, no algo
  # que el cliente elija navegando el menú) y "Bebidas" se excluye de la
  # landing (no es lo que se destaca en la portada).
  CATEGORIA_ORDEN = ['Papas'].freeze

  def index
    @business = BusinessSetting.current
    vendibles = Product.activos.where.not(categoria: ['Domicilio', 'Bebidas'])
    @destacados = vendibles.por_posicion.limit(6)
    @productos_por_categoria = vendibles.por_categoria.group_by(&:categoria)
                                         .sort_by { |categoria, _| CATEGORIA_ORDEN.index(categoria) || CATEGORIA_ORDEN.size }
                                         .to_h

    # Fotos reales de productos para la galería — si no hay suficientes, la sección se omite en la vista.
    @fotos_galeria = vendibles.with_attached_foto.to_a.select { |p| p.foto.attached? }.first(8)
  end
end
