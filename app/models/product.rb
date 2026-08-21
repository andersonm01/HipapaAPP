class Product < ApplicationRecord
  has_one_attached :foto

  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_one  :recipe, dependent: :destroy

  validates :nombre,    presence: true
  validates :precio,    presence: true, numericality: { greater_than: 0 }
  validates :categoria, presence: true

  scope :activos,       -> { where(activo: true) }
  scope :por_categoria, -> { order(:categoria, :posicion, :nombre) }
  scope :por_posicion,  -> { order(:posicion, :nombre) }

  def margen_ganancia
    return nil unless costo_calculado&.positive? && precio.positive?
    ((precio - costo_calculado) / precio * 100).round(1)
  end

  def rentable?
    margen_ganancia.nil? || margen_ganancia >= 30
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[id nombre categoria activo]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[order_items]
  end
end
