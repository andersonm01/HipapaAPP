class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      t.string  :nombre,           null: false
      t.string  :whatsapp
      t.string  :direccion
      t.decimal :precio_domicilio, precision: 8, scale: 2, default: 0
      t.text    :notas
      t.boolean :activo,           null: false, default: true
      t.timestamps
    end
    add_index :customers, :nombre
  end
end
