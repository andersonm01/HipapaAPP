class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  KITCHEN_STATUSES = %w[pending preparing ready delivered].freeze

  # status: 0 = abierta, 1 = cerrada, 2 = cancelada
  STATUS_OPEN      = 0
  STATUS_CLOSED    = 1
  STATUS_CANCELLED = 2

  scope :open,      -> { where(status: STATUS_OPEN) }
  scope :closed,    -> { where(status: STATUS_CLOSED) }
  scope :cancelled, -> { where(status: STATUS_CANCELLED) }

  scope :for_kitchen, -> {
    where(status: STATUS_OPEN)
      .where.not(kitchen_status: 'delivered')
      .includes(order_items: :product)
      .order(created_at: :asc)
  }

  def open?
    status == STATUS_OPEN
  end

  def closed?
    status == STATUS_CLOSED
  end

  def cancelled?
    status == STATUS_CANCELLED
  end

  def visible_en_cocina?
    open? && kitchen_status != 'delivered'
  end

  def total
    order_items.any? ? order_items.sum { |item| item.subtotal } : 0.0
  end
end
