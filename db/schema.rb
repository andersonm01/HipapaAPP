# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2026_04_15_000012) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "business_settings", force: :cascade do |t|
    t.string "nombre", default: "Hi Papa", null: false
    t.string "telefono"
    t.string "direccion"
    t.string "color_primario", default: "#f59e0b", null: false
    t.string "color_secundario", default: "#0f172a", null: false
    t.string "color_acento", default: "#fbbf24", null: false
    t.text "descripcion"
    t.string "whatsapp_negocio"
    t.boolean "activo", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cash_movements", force: :cascade do |t|
    t.integer "cash_register_id", null: false
    t.integer "order_id"
    t.string "tipo", null: false
    t.string "medio_pago", default: "efectivo", null: false
    t.decimal "monto", precision: 10, scale: 2, null: false
    t.text "descripcion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cash_register_id"], name: "index_cash_movements_on_cash_register_id"
    t.index ["order_id"], name: "index_cash_movements_on_order_id"
  end

  create_table "cash_registers", force: :cascade do |t|
    t.integer "user_id", null: false
    t.decimal "monto_apertura", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "monto_cierre", precision: 10, scale: 2
    t.datetime "abierta_en", null: false
    t.datetime "cerrada_en"
    t.string "estado", default: "abierta", null: false
    t.text "notas"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estado"], name: "index_cash_registers_on_estado"
    t.index ["user_id"], name: "index_cash_registers_on_user_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "nombre", null: false
    t.string "whatsapp"
    t.string "direccion"
    t.decimal "precio_domicilio", precision: 8, scale: 2, default: "0.0"
    t.text "notas"
    t.boolean "activo", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nombre"], name: "index_customers_on_nombre"
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "nombre", null: false
    t.decimal "precio", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "stock_actual", precision: 10, scale: 3, default: "0.0", null: false
    t.decimal "stock_minimo", precision: 10, scale: 3, default: "0.0", null: false
    t.string "unidad", default: "g", null: false
    t.boolean "activo", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "customer_id"
    t.string "numero", null: false
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total", precision: 10, scale: 2, default: "0.0", null: false
    t.string "estado", default: "emitida", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_invoices_on_customer_id"
    t.index ["numero"], name: "index_invoices_on_numero", unique: true
    t.index ["order_id"], name: "index_invoices_on_order_id"
  end

  create_table "order_item_sauces", force: :cascade do |t|
    t.integer "order_item_id", null: false
    t.integer "sauce_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_item_id", "sauce_id"], name: "index_order_item_sauces_on_order_item_id_and_sauce_id", unique: true
    t.index ["order_item_id"], name: "index_order_item_sauces_on_order_item_id"
    t.index ["sauce_id"], name: "index_order_item_sauces_on_sauce_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "cantidad", default: 1, null: false
    t.decimal "precio_unitario", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comentario"
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "cliente"
    t.string "mesero"
    t.text "comentario"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.decimal "monto_pagado", precision: 10, scale: 2
    t.string "tipo_pago"
    t.decimal "vuelto", precision: 10, scale: 2
    t.string "tipo_servicio", default: "mesa"
    t.string "kitchen_status", default: "preparing", null: false
    t.string "cancel_reason"
    t.datetime "cancelled_at"
    t.integer "customer_id"
    t.integer "user_id"
    t.decimal "total", precision: 10, scale: 2
    t.decimal "descuento", precision: 8, scale: 2, default: "0.0"
    t.string "canal", default: "pos"
    t.string "numero_orden"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "nombre", null: false
    t.text "descripcion"
    t.decimal "precio", precision: 10, scale: 2, null: false
    t.string "categoria", null: false
    t.boolean "activo", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "costo_calculado", precision: 10, scale: 2
    t.integer "posicion", default: 0
  end

  create_table "recipe_ingredients", force: :cascade do |t|
    t.integer "recipe_id", null: false
    t.integer "ingredient_id", null: false
    t.decimal "cantidad", precision: 10, scale: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_recipe_ingredients_on_ingredient_id"
    t.index ["recipe_id"], name: "index_recipe_ingredients_on_recipe_id"
  end

  create_table "recipes", force: :cascade do |t|
    t.integer "product_id", null: false
    t.text "notas"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_recipes_on_product_id"
  end

  create_table "sauces", force: :cascade do |t|
    t.string "nombre", null: false
    t.string "color", default: "#ef4444", null: false
    t.integer "posicion", default: 0, null: false
    t.boolean "activo", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.string "role", default: "user", null: false
    t.boolean "active", default: true, null: false
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cash_movements", "cash_registers"
  add_foreign_key "cash_movements", "orders"
  add_foreign_key "cash_registers", "users"
  add_foreign_key "invoices", "customers"
  add_foreign_key "invoices", "orders"
  add_foreign_key "order_item_sauces", "order_items"
  add_foreign_key "order_item_sauces", "sauces"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "users"
  add_foreign_key "recipe_ingredients", "ingredients"
  add_foreign_key "recipe_ingredients", "recipes"
  add_foreign_key "recipes", "products"
end
