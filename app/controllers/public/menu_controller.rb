class Public::MenuController < ApplicationController
  skip_before_action :require_login
  layout 'public'

  # Orden de categorías en la vitrina: Papas primero (lo que realmente
  # vendemos), el resto en el orden que ya trae la query. "Domicilio" se
  # excluye por completo: es un cargo que se agrega al pedido, no algo
  # que el cliente elija navegando el menú.
  CATEGORIA_ORDEN = ['Papas'].freeze

  def index
    setting = BusinessSetting.current
    @business = setting
    return unless setting.activo?

    productos = Product.activos.with_attached_foto.where.not(categoria: 'Domicilio').por_categoria
    @productos_por_categoria = productos.group_by(&:categoria)
                                         .sort_by { |categoria, _| CATEGORIA_ORDEN.index(categoria) || CATEGORIA_ORDEN.size }
                                         .to_h
  end
end
