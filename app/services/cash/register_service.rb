module Cash
  class RegisterService
    def initialize(cash_register)
      @register = cash_register
    end

    def close!
      raise "La caja ya está cerrada" if @register.cerrada?

      balance = @register.balance_calculado

      @register.update!(
        estado:      'cerrada',
        cerrada_en:  Time.current,
        monto_cierre: balance
      )

      {
        efectivo:        @register.total_efectivo,
        transferencia:   @register.total_transferencia,
        total_ventas:    @register.total_ventas,
        total_retiros:   @register.total_retiros,
        monto_apertura:  @register.monto_apertura,
        balance_final:   balance
      }
    end

    def record_sale(order)
      raise "La caja está cerrada" if @register.cerrada?

      @register.cash_movements.create!(
        order:      order,
        tipo:       'venta',
        medio_pago: order.tipo_pago || 'efectivo',
        monto:      order.total.to_f,
        descripcion: "Pedido #{order.numero_orden}"
      )
    end
  end
end
