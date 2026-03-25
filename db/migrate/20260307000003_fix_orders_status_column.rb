class FixOrdersStatusColumn < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    change_column :orders, :status, :integer, default: 0, null: false
  end
end