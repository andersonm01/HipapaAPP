class Customer < ApplicationRecord
  has_many :orders, dependent: :nullify

  validates :nombre, presence: true

  scope :activos,  -> { where(activo: true) }
  scope :ranking,  -> { activos.left_joins(:orders).where(orders: { status: Order::STATUS_CLOSED }).group(:id).order('COUNT(orders.id) DESC') }

  def total_compras
    orders.closed.sum(:total).to_f
  end

  def frecuencia
    orders.closed.count
  end

  def ultimo_pedido
    orders.closed.order(created_at: :desc).first&.created_at
  end
end
