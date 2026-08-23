class AddIndexToCustomersWhatsapp < ActiveRecord::Migration[7.0]
  def change
    add_index :customers, :whatsapp
  end
end
