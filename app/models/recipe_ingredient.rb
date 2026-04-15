class RecipeIngredient < ApplicationRecord
  belongs_to :recipe
  belongs_to :ingredient

  validates :cantidad, presence: true, numericality: { greater_than: 0 }

  after_save    :recalculate_recipe_cost
  after_destroy :recalculate_recipe_cost

  def costo_total
    ingredient.precio_por_unidad_base * cantidad
  end

  private

  def recalculate_recipe_cost
    recipe.send(:recalculate_product_cost)
  end
end
