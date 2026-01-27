class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :cantidad, default: 1, null: false
      t.decimal :precio_unitario, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
