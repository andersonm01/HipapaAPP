class Order < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :user,     optional: true

  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_one  :invoice, dependent: :destroy
  has_many :cash_movements, dependent: :nullify

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

  before_create :assign_numero_orden

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

  def total_calculado
    items_total = order_items.loaded? ? order_items.sum(&:subtotal) : order_items.sum('cantidad * precio_unitario')
    desc = descuento.to_f
    [items_total - desc, 0].max
  end

  # Mantiene compatibilidad con código existente
  def total
    total_calculado
  end

  def nombre_cliente
    customer&.nombre || cliente
  end

  private

  def assign_numero_orden
    return if numero_orden.present?
    last = Order.maximum(:id).to_i + 1
    self.numero_orden = "##{last.to_s.rjust(4, '0')}"
  end
end
