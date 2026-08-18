class Public::LandingController < ApplicationController
  skip_before_action :require_login
  layout 'landing'

  def index
    @business = BusinessSetting.current
    @destacados = Product.activos.por_posicion.limit(6)
  end
end
