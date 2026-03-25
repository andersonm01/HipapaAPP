class AddCancelFieldsToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :cancel_reason, :string
    add_column :orders, :cancelled_at, :datetime
  end
end
