class FixOrdersStatusColumn < ActiveRecord::Migration[7.0]
  # Desactiva la transacción para PostgreSQL
  disable_ddl_transaction!

  def up
    change_column :orders, :status, :integer, null: false, default: 0
  end

  def down
    change_column :orders, :status, :boolean, null: false, default: false
  end
end