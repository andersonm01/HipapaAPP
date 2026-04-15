class CashRegister < ApplicationRecord
  belongs_to :user
  has_many :cash_movements, dependent: :destroy

  ESTADOS = %w[abierta cerrada].freeze

  validates :monto_apertura, numericality: { greater_than_or_equal_to: 0 }
  validates :estado, inclusion: { in: ESTADOS }

  scope :abiertas, -> { where(estado: 'abierta') }
  scope :cerradas, -> { where(estado: 'cerrada') }

  def abierta?
    estado == 'abierta'
  end

  def cerrada?
    estado == 'cerrada'
  end

  def total_efectivo
    cash_movements.where(medio_pago: 'efectivo', tipo: 'venta').sum(:monto)
  end

  def total_transferencia
    cash_movements.where(medio_pago: 'transferencia', tipo: 'venta').sum(:monto)
  end

  def total_ventas
    cash_movements.where(tipo: 'venta').sum(:monto)
  end

  def total_retiros
    cash_movements.where(tipo: 'retiro').sum(:monto)
  end

  def total_ingresos_manuales
    cash_movements.where(tipo: 'ingreso').sum(:monto)
  end

  def balance_calculado
    monto_apertura + total_efectivo + total_ingresos_manuales - total_retiros
  end

  def self.caja_abierta_para(user)
    where(user: user, estado: 'abierta').order(created_at: :desc).first
  end

  def self.cualquier_caja_abierta
    abiertas.order(created_at: :desc).first
  end
end
