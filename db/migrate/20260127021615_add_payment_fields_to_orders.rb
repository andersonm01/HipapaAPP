class AddPaymentFieldsToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :monto_pagado, :decimal, precision: 10, scale: 2
    add_column :orders, :tipo_pago, :string
    add_column :orders, :vuelto, :decimal, precision: 10, scale: 2
  end
end
