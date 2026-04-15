class RecipesController < ApplicationController
  before_action :require_admin_or_supervisor
  before_action :set_product

  def show
    @recipe = @product.recipe || @product.build_recipe
    @ingredients = Ingredient.activos
  end

  def update
    @recipe = @product.recipe || @product.build_recipe
    @recipe.notas = params[:recipe][:notas]

    ActiveRecord::Base.transaction do
      @recipe.save!

      # Limpiar y re-crear ingredientes
      @recipe.recipe_ingredients.destroy_all

      Array(params[:recipe_ingredients]).each do |ri_params|
        next if ri_params[:ingredient_id].blank? || ri_params[:cantidad].to_f <= 0
        @recipe.recipe_ingredients.create!(
          ingredient_id: ri_params[:ingredient_id],
          cantidad:      ri_params[:cantidad].to_f
        )
      end
    end

    redirect_to product_recipe_path(@product), notice: "Receta guardada. Costo: $#{@product.reload.costo_calculado}"
  rescue => e
    @ingredients = Ingredient.activos
    flash.now[:alert] = "Error al guardar receta: #{e.message}"
    render :show, status: :unprocessable_entity
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end
end
