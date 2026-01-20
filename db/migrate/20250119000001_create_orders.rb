class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :cliente
      t.string :mesero
      t.text :comentario

      t.timestamps
    end
  end
end
