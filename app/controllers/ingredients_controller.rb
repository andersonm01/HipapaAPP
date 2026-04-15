class IngredientsController < ApplicationController
  before_action :require_admin_or_supervisor
  before_action :set_ingredient, only: [:edit, :update, :destroy, :adjust_stock]

  def index
    @ingredients = Ingredient.activos
    @low_stock   = Ingredient.stock_bajo
  end

  def new
    @ingredient = Ingredient.new(unidad: 'g')
  end

  def create
    @ingredient = Ingredient.new(ingredient_params)
    if @ingredient.save
      redirect_to ingredients_path, notice: "Ingrediente #{@ingredient.nombre} creado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @ingredient.update(ingredient_params)
      redirect_to ingredients_path, notice: "Ingrediente actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @ingredient.update!(activo: false)
    redirect_to ingredients_path, notice: "Ingrediente desactivado."
  end

  def adjust_stock
    cantidad = params[:cantidad].to_f
    operacion = params[:operacion]

    new_stock = case operacion
    when 'add'    then @ingredient.stock_actual + cantidad
    when 'remove' then [@ingredient.stock_actual - cantidad, 0].max
    when 'set'    then cantidad
    else @ingredient.stock_actual
    end

    @ingredient.update!(stock_actual: new_stock)
    redirect_to ingredients_path, notice: "Stock de #{@ingredient.nombre} actualizado."
  end

  private

  def set_ingredient
    @ingredient = Ingredient.find(params[:id])
  end

  def ingredient_params
    params.require(:ingredient).permit(:nombre, :precio, :stock_actual, :stock_minimo, :unidad, :activo)
  end
end
