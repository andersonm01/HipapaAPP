class Public::LandingController < ApplicationController
  skip_before_action :require_login
  layout 'landing'

  def index
    @business = BusinessSetting.current
    @destacados = Product.activos.por_posicion.limit(6)
    @productos_por_categoria = Product.activos.por_categoria.group_by(&:categoria)

    # Fotos reales de productos para la galería — si no hay suficientes, la sección se omite en la vista.
    @fotos_galeria = Product.activos.with_attached_foto.to_a.select { |p| p.foto.attached? }.first(8)
  end
end
