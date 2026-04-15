class CreateInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.references :order,    null: false, foreign_key: true
      t.references :customer, foreign_key: true  # nullable
      t.string     :numero,   null: false
      t.decimal    :subtotal, precision: 10, scale: 2, null: false, default: 0
      t.decimal    :total,    precision: 10, scale: 2, null: false, default: 0
      t.string     :estado,   null: false, default: 'emitida'  # emitida, anulada
      t.timestamps
    end
    add_index :invoices, :numero, unique: true
  end
end
