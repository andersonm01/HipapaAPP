class Recipe < ApplicationRecord
  belongs_to :product
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients

  validates :product, presence: true

  after_save    :recalculate_product_cost
  after_destroy :clear_product_cost

  def total_cost
    recipe_ingredients.sum { |ri| ri.costo_total }
  end

  private

  def recalculate_product_cost
    cost = recipe_ingredients.includes(:ingredient).sum { |ri| ri.costo_total }
    product.update_column(:costo_calculado, cost.round(2))
  end

  def clear_product_cost
    product.update_column(:costo_calculado, nil)
  end
end
