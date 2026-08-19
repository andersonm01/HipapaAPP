class AddHistoriaToBusinessSettings < ActiveRecord::Migration[7.0]
  def change
    add_column :business_settings, :historia, :text
  end
end
