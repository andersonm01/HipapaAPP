class Public::MenuController < ApplicationController
  skip_before_action :require_login
  layout 'public'

  def index
    setting = BusinessSetting.current
    @business = setting
    @productos_por_categoria = Product.activos.por_categoria.group_by(&:categoria)
    @sauces = Sauce.activas
  end
end
