class Invoice < ApplicationRecord
  belongs_to :order
  belongs_to :customer, optional: true

  ESTADOS = %w[emitida anulada].freeze

  validates :numero, presence: true, uniqueness: true
  validates :estado, inclusion: { in: ESTADOS }

  scope :emitidas, -> { where(estado: 'emitida') }
  scope :anuladas, -> { where(estado: 'anulada') }

  def self.next_number
    last = maximum(:numero).to_s
    num = last.gsub(/\D/, '').to_i + 1
    "FACT-#{num.to_s.rjust(5, '0')}"
  end

  def anulada?
    estado == 'anulada'
  end
end
