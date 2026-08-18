class DropSaucesTables < ActiveRecord::Migration[7.0]
  def up
    drop_table :order_item_sauces
    drop_table :sauces
  end

  def down
    create_table :sauces do |t|
      t.string  :nombre,   null: false
      t.string  :color,    null: false, default: '#ef4444'
      t.integer :posicion, null: false, default: 0
      t.boolean :activo,   null: false, default: true
      t.timestamps
    end

    create_table :order_item_sauces do |t|
      t.references :order_item, null: false, foreign_key: true
      t.references :sauce,      null: false, foreign_key: true
      t.timestamps
    end
    add_index :order_item_sauces, [:order_item_id, :sauce_id], unique: true
  end
end
