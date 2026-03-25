class FixStatusColumnType < ActiveRecord::Migration[7.0]
  def up
    col = connection.columns(:orders).find { |c| c.name == 'status' }
    return unless col
    return if col.type == :integer

    if connection.adapter_name == 'PostgreSQL'
      # PostgreSQL no permite cast directo de boolean/bit a integer sin USING.
      # Convertimos: true/'1' → 1, false/'0'/null → 0
      execute <<~SQL
        ALTER TABLE orders
          ALTER COLUMN status TYPE integer
          USING (
            CASE
              WHEN status IS NULL THEN 0
              WHEN status::text IN ('true', 't', 'yes', 'on', '1') THEN 1
              ELSE 0
            END
          )
      SQL
      execute "ALTER TABLE orders ALTER COLUMN status SET DEFAULT 0"
      execute "ALTER TABLE orders ALTER COLUMN status SET NOT NULL"
    else
      change_column :orders, :status, :integer, null: false, default: 0
      Order.where(status: nil).update_all(status: 0)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
