# frozen_string_literal: true

class ChangeKitchenStatusDefaultToPreparing < ActiveRecord::Migration[7.0]
  def up
    change_column_default :orders, :kitchen_status, from: 'pending', to: 'preparing'
  end

  def down
    change_column_default :orders, :kitchen_status, from: 'preparing', to: 'pending'
  end
end
