class AddKitchenStatusToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :kitchen_status, :string, default: 'preparing', null: false
  end
end
