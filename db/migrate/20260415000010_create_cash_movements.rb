class CreateCashMovements < ActiveRecord::Migration[7.0]
  def change
    create_table :cash_movements do |t|
      t.references :cash_register, null: false, foreign_key: true
      t.references :order,         foreign_key: true  # nullable: movimientos manuales
      t.string     :tipo,          null: false  # venta, retiro, ingreso
      t.string     :medio_pago,    null: false, default: 'efectivo'  # efectivo, transferencia
      t.decimal    :monto,         precision: 10, scale: 2, null: false
      t.text       :descripcion
      t.timestamps
    end
  end
end
