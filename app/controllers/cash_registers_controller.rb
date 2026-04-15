class CashRegistersController < ApplicationController
  before_action :require_admin_or_supervisor, only: [:index, :show]
  before_action :set_cash_register, only: [:show, :close, :add_movement]

  def index
    @cajas = CashRegister.includes(:user).order(created_at: :desc).limit(30)
    @caja_abierta = CashRegister.caja_abierta_para(current_user)
  end

  def show
    @movements = @cash_register.cash_movements.includes(:order).order(created_at: :desc)
  end

  def open
    if CashRegister.caja_abierta_para(current_user)
      redirect_to cash_registers_path, alert: "Ya tienes una caja abierta."
      return
    end

    @cash_register = CashRegister.create!(
      user:            current_user,
      monto_apertura:  params[:monto_apertura].to_f,
      abierta_en:      Time.current,
      estado:          'abierta',
      notas:           params[:notas]
    )
    redirect_to cash_register_path(@cash_register), notice: "Caja abierta exitosamente."
  rescue => e
    redirect_to cash_registers_path, alert: "Error al abrir caja: #{e.message}"
  end

  def close
    service = Cash::RegisterService.new(@cash_register)
    resumen = service.close!
    session[:ultimo_cierre_caja] = resumen
    redirect_to cash_register_path(@cash_register), notice: "Caja cerrada. Total ventas: $#{resumen[:total_ventas]}"
  rescue => e
    redirect_to cash_register_path(@cash_register), alert: e.message
  end

  def add_movement
    @cash_register.cash_movements.create!(
      tipo:        params[:tipo],
      medio_pago:  params[:medio_pago] || 'efectivo',
      monto:       params[:monto].to_f,
      descripcion: params[:descripcion]
    )
    redirect_to cash_register_path(@cash_register), notice: "Movimiento registrado."
  rescue => e
    redirect_to cash_register_path(@cash_register), alert: "Error: #{e.message}"
  end

  private

  def set_cash_register
    @cash_register = CashRegister.find(params[:id])
  end
end
