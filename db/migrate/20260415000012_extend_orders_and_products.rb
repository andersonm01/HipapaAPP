class ExtendOrdersAndProducts < ActiveRecord::Migration[7.0]
  def change
    # Orders: vincular a customer, user; agregar campos de negocio
    add_reference :orders, :customer, foreign_key: true, null: true
    add_reference :orders, :user,     foreign_key: true, null: true
    add_column :orders, :total,         :decimal, precision: 10, scale: 2
    add_column :orders, :descuento,     :decimal, precision: 8, scale: 2, default: 0
    add_column :orders, :canal,         :string,  default: 'pos'   # pos, web, whatsapp
    add_column :orders, :numero_orden,  :string

    # Products: costo calculado desde receta, orden visual
    add_column :products, :costo_calculado, :decimal, precision: 10, scale: 2
    add_column :products, :posicion,        :integer, default: 0
  end
end
