class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    
    if @product.save
      redirect_to products_path, notice: 'Producto creado exitosamente.'
    else
      flash[:alert] = "Error al crear el producto: #{@product.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: 'Producto actualizado exitosamente.'
    else
      flash[:alert] = "Error al actualizar el producto: #{@product.errors.full_messages.join(', ')}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: 'Producto eliminado exitosamente.'
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:nombre, :descripcion, :precio, :categoria, :activo)
  end
end
