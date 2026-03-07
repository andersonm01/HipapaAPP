class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  KITCHEN_STATUSES = %w[pending preparing ready delivered].freeze

  # Órdenes abiertas que no hayan sido marcadas como entregadas.
  # Si se agregan nuevos productos a una orden entregada, el controlador
  # resetea kitchen_status a 'pending' y la orden vuelve a aparecer aquí.
  scope :for_kitchen, -> {
    where(status: 0)
      .where.not(kitchen_status: 'delivered')
      .includes(order_items: :product)
      .order(created_at: :asc)
  }

  # Retorna true si la orden debe mostrarse en el monitor de cocina.
  def visible_en_cocina?
    status == 0 && kitchen_status != 'delivered'
  end

  def total
    order_items.any? ? order_items.sum { |item| item.subtotal } : 0.0
  end
end
