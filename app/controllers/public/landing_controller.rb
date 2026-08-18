class Public::LandingController < ApplicationController
  skip_before_action :require_login
  layout 'landing'

  def index
    @business = BusinessSetting.current
    @productos_por_categoria = Product.activos.por_categoria.group_by(&:categoria)
  end
end
