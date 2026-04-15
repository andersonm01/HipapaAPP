class CustomersController < ApplicationController
  before_action :require_admin_or_supervisor, only: [:destroy]
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  def index
    @customers = Customer.activos.order(:nombre)
    @customers = @customers.where('nombre ILIKE ? OR whatsapp LIKE ?', "%#{params[:q]}%", "%#{params[:q]}%") if params[:q].present?

    # Ranking
    @top_customers = Customer.activos
      .joins(:orders)
      .where(orders: { status: Order::STATUS_CLOSED })
      .group('customers.id')
      .select('customers.*, COUNT(orders.id) as pedidos_count, SUM(orders.total) as total_gastado')
      .order('total_gastado DESC')
      .limit(5)
  end

  def show
    @orders = @customer.orders.order(created_at: :desc).limit(20)
  end

  def new
    @customer = Customer.new
  end

  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      redirect_to customers_path, notice: "Cliente #{@customer.nombre} creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @customer.update(customer_params)
      redirect_to customers_path, notice: "Cliente actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @customer.update!(activo: false)
    redirect_to customers_path, notice: "Cliente eliminado."
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:nombre, :whatsapp, :direccion, :precio_domicilio, :notas)
  end
end
