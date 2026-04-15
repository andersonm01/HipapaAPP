class CreateRecipeIngredients < ActiveRecord::Migration[7.0]
  def change
    create_table :recipe_ingredients do |t|
      t.references :recipe,     null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.decimal    :cantidad,   precision: 10, scale: 3, null: false
      t.timestamps
    end
  end
end
