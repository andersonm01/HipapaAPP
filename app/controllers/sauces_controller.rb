class SaucesController < ApplicationController
  before_action :require_admin_or_supervisor
  before_action :set_sauce, only: [:edit, :update, :destroy]

  def index
    @sauces = Sauce.ordenadas
  end

  def new
    @sauce = Sauce.new(color: '#ef4444', posicion: (Sauce.maximum(:posicion) || 0) + 1)
  end

  def create
    @sauce = Sauce.new(sauce_params)
    if @sauce.save
      redirect_to sauces_path, notice: "Salsa #{@sauce.nombre} creada."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @sauce.update(sauce_params)
      redirect_to sauces_path, notice: "Salsa actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sauce.update!(activo: false)
    redirect_to sauces_path, notice: "Salsa desactivada."
  end

  private

  def set_sauce
    @sauce = Sauce.find(params[:id])
  end

  def sauce_params
    params.require(:sauce).permit(:nombre, :color, :posicion, :activo)
  end
end
