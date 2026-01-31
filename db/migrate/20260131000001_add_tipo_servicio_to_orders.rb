# frozen_string_literal: true

class AddTipoServicioToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :tipo_servicio, :string, default: 'mesa'
  end
end
