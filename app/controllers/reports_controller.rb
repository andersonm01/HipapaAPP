class ReportsController < ApplicationController
  before_action :require_admin_or_supervisor

  def index
    @meseros    = Order.where.not(mesero: [nil, '']).distinct.order(:mesero).pluck(:mesero)
    @categorias = Product.where.not(categoria: [nil, '']).distinct.order(:categoria).pluck(:categoria)
    @productos  = Product.order(:nombre).pluck(:nombre, :id)
  end
end
