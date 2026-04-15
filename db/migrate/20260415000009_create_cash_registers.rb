class CreateCashRegisters < ActiveRecord::Migration[7.0]
  def change
    create_table :cash_registers do |t|
      t.references :user,           null: false, foreign_key: true
      t.decimal    :monto_apertura, precision: 10, scale: 2, null: false, default: 0
      t.decimal    :monto_cierre,   precision: 10, scale: 2
      t.datetime   :abierta_en,     null: false
      t.datetime   :cerrada_en
      t.string     :estado,         null: false, default: 'abierta'  # abierta, cerrada
      t.text       :notas
      t.timestamps
    end
    add_index :cash_registers, :estado
  end
end
