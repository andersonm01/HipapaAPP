module Recipes
  class CostCalculator
    def initialize(product)
      @product = product
    end

    def call
      recipe = @product.recipe
      return 0 unless recipe

      total = recipe.recipe_ingredients.includes(:ingredient).sum(&:costo_total)
      @product.update_column(:costo_calculado, total.round(2))
      total
    end

    def margin_percentage
      cost = call
      return nil if cost.zero? || @product.precio.zero?
      ((@product.precio - cost) / @product.precio * 100).round(2)
    end
  end
end
