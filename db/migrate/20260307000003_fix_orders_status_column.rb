# frozen_string_literal: true

# Corrige la columna status: :bit no es válida en SQLite y puede hacer
# que el default no se aplique (las órdenes nuevas aparecían cerradas).
class FixOrdersStatusColumn < ActiveRecord::Migration[7.0]
  def up
    change_column :orders, :status, :integer, default: 0, null: false
  end

  def down
    change_column :orders, :status, :integer, default: 0, null: false
  end
end
