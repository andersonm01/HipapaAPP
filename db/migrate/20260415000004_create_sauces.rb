class CreateSauces < ActiveRecord::Migration[7.0]
  def change
    create_table :sauces do |t|
      t.string  :nombre,   null: false
      t.string  :color,    null: false, default: '#ef4444'
      t.integer :posicion, null: false, default: 0
      t.boolean :activo,   null: false, default: true
      t.timestamps
    end
  end
end
