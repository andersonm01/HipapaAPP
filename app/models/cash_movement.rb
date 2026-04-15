class CashMovement < ApplicationRecord
  belongs_to :cash_register
  belongs_to :order, optional: true

  TIPOS       = %w[venta retiro ingreso].freeze
  MEDIOS_PAGO = %w[efectivo transferencia].freeze

  validates :tipo,      inclusion: { in: TIPOS }
  validates :medio_pago, inclusion: { in: MEDIOS_PAGO }
  validates :monto,     numericality: { greater_than: 0 }
end
