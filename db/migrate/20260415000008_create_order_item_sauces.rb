class CreateOrderItemSauces < ActiveRecord::Migration[7.0]
  def change
    create_table :order_item_sauces do |t|
      t.references :order_item, null: false, foreign_key: true
      t.references :sauce,      null: false, foreign_key: true
      t.timestamps
    end
    add_index :order_item_sauces, [:order_item_id, :sauce_id], unique: true
  end
end
