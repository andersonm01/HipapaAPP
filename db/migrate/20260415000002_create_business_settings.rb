class CreateBusinessSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :business_settings do |t|
      t.string  :nombre,           null: false, default: 'Hi Papa'
      t.string  :telefono
      t.string  :direccion
      t.string  :color_primario,   null: false, default: '#f59e0b'
      t.string  :color_secundario, null: false, default: '#0f172a'
      t.string  :color_acento,     null: false, default: '#fbbf24'
      t.text    :descripcion
      t.string  :whatsapp_negocio
      t.boolean :activo,           null: false, default: true
      t.timestamps
    end
  end
end
