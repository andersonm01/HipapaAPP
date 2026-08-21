class AddStatusCreatedAtIndexToOrders < ActiveRecord::Migration[7.0]
  def change
    add_index :orders, [:status, :created_at]
  end
end
