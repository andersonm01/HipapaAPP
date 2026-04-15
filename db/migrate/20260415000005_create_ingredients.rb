class CreateIngredients < ActiveRecord::Migration[7.0]
  def change
    create_table :ingredients do |t|
      t.string  :nombre,       null: false
      t.decimal :precio,       precision: 10, scale: 2, null: false, default: 0
      t.decimal :stock_actual, precision: 10, scale: 3, null: false, default: 0
      t.decimal :stock_minimo, precision: 10, scale: 3, null: false, default: 0
      t.string  :unidad,       null: false, default: 'g'  # g, ml, kg, L, unidad
      t.boolean :activo,       null: false, default: true
      t.timestamps
    end
  end
end
