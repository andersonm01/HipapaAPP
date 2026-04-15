class CreateRecipes < ActiveRecord::Migration[7.0]
  def change
    create_table :recipes do |t|
      t.references :product, null: false, foreign_key: true
      t.text       :notas
      t.timestamps
    end
  end
end
