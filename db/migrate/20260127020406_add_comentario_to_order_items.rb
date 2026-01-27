class AddComentarioToOrderItems < ActiveRecord::Migration[7.0]
  def change
    add_column :order_items, :comentario, :text
  end
end
