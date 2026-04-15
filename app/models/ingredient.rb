class Ingredient < ApplicationRecord
  UNITS = %w[g kg ml L unidad].freeze

  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients

  validates :nombre, presence: true
  validates :precio, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :unidad, inclusion: { in: UNITS }
  validates :stock_actual, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_minimo, numericality: { greater_than_or_equal_to: 0 }

  scope :activos,    -> { where(activo: true).order(:nombre) }
  scope :stock_bajo, -> { where(activo: true).where('stock_actual <= stock_minimo') }

  def stock_bajo?
    stock_actual <= stock_minimo
  end

  # Precio normalizado a unidad base (g o ml)
  def precio_por_unidad_base
    case unidad
    when 'kg' then precio / 1000.0
    when 'L'  then precio / 1000.0
    else precio
    end
  end

  def unidad_base
    case unidad
    when 'kg' then 'g'
    when 'L'  then 'ml'
    else unidad
    end
  end
end
