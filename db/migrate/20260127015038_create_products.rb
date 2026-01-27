class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :nombre, null: false
      t.text :descripcion
      t.decimal :precio, precision: 10, scale: 2, null: false
      t.string :categoria, null: false
      t.boolean :activo, default: true, null: false

      t.timestamps
    end
  end
end
