# ─────────────────────────────────────────────────────────────
# SEEDS — Hi Papa POS
# ─────────────────────────────────────────────────────────────
puts "=== Iniciando seeds ==="

# ── Admin user ──────────────────────────────────────────────
unless User.exists?(email: 'admin@hipapa.com')
  User.create!(
    name: 'Administrador',
    email: 'admin@hipapa.com',
    password: 'Admin123!',
    password_confirmation: 'Admin123!',
    role: 'admin',
    active: true
  )
  puts "✓ Admin creado: admin@hipapa.com / Admin123!"
else
  puts "· Admin ya existe"
end

# ── Configuración del negocio ────────────────────────────────
setting = BusinessSetting.first_or_initialize
setting.assign_attributes(
  nombre:           'Hi Papa',
  telefono:         '3001234567',
  descripcion:      'Las mejores papas con todo de la ciudad 🍟',
  color_primario:   '#f59e0b',
  color_secundario: '#0f172a',
  color_acento:     '#fbbf24',
  whatsapp_negocio: '573001234567'
)
setting.save!
puts "✓ BusinessSetting configurado"

# ── Salsas ──────────────────────────────────────────────────
sauces_data = [
  { nombre: 'Kétchup',            color: '#dc2626', posicion: 1 },
  { nombre: 'Mayonesa',           color: '#fbbf24', posicion: 2 },
  { nombre: 'Mostaza',            color: '#ca8a04', posicion: 3 },
  { nombre: 'BBQ',                color: '#92400e', posicion: 4 },
  { nombre: 'Picante',            color: '#ef4444', posicion: 5 },
  { nombre: 'Ranch',              color: '#a3e635', posicion: 6 },
  { nombre: 'Especial Hi Papa',   color: '#f97316', posicion: 7 },
  { nombre: 'Sin salsa',          color: '#94a3b8', posicion: 8 },
]

sauces_data.each do |s|
  Sauce.find_or_create_by!(nombre: s[:nombre]) do |sauce|
    sauce.color    = s[:color]
    sauce.posicion = s[:posicion]
    sauce.activo   = true
  end
end
puts "✓ #{Sauce.count} salsas creadas"

# ── Ingredientes ─────────────────────────────────────────────
# Precios de compra estimados por unidad/kg/L
ingredients_data = [
  # Bases
  { nombre: 'Papas a la francesa',    precio:  3_000, stock_actual: 10,  stock_minimo: 2,   unidad: 'kg'     },
  { nombre: 'Aceite vegetal',         precio:  8_000, stock_actual: 5,   stock_minimo: 1,   unidad: 'L'      },
  # Proteínas
  { nombre: 'Carne BBQ desmechada',   precio: 20_000, stock_actual: 3,   stock_minimo: 0.5, unidad: 'kg'     },
  { nombre: 'Pollo desmechado',       precio: 14_000, stock_actual: 3,   stock_minimo: 0.5, unidad: 'kg'     },
  { nombre: 'Chicharrón',             precio: 18_000, stock_actual: 2,   stock_minimo: 0.3, unidad: 'kg'     },
  { nombre: 'Tocineta',               precio: 22_000, stock_actual: 1,   stock_minimo: 0.2, unidad: 'kg'     },
  # Toppings
  { nombre: 'Guacamole',              precio:  8_000, stock_actual: 2,   stock_minimo: 0.3, unidad: 'kg'     },
  { nombre: 'Queso mozzarella',       precio: 18_000, stock_actual: 2,   stock_minimo: 0.3, unidad: 'kg'     },
  { nombre: 'Sour cream',             precio:  7_000, stock_actual: 1,   stock_minimo: 0.2, unidad: 'kg'     },
  { nombre: 'Ripio de tostinachos',   precio:  5_000, stock_actual: 2,   stock_minimo: 0.3, unidad: 'kg'     },
  { nombre: 'Maicitos',               precio:  1_500, stock_actual: 20,  stock_minimo: 4,   unidad: 'unidad' },
  { nombre: 'Huevo de codorniz',      precio:    300, stock_actual: 100, stock_minimo: 20,  unidad: 'unidad' },
  # Bebidas (unidades de compra)
  { nombre: 'Coca Cola Mini (botella)',      precio: 1_500, stock_actual: 24, stock_minimo: 6, unidad: 'unidad' },
  { nombre: 'Coca Cola Personal (botella)', precio: 2_500, stock_actual: 24, stock_minimo: 6, unidad: 'unidad' },
  { nombre: 'Coca Cola 1.5L (botella)',     precio: 4_500, stock_actual: 12, stock_minimo: 3, unidad: 'unidad' },
  { nombre: 'Hit Personal (botella)',        precio: 2_000, stock_actual: 24, stock_minimo: 6, unidad: 'unidad' },
  { nombre: 'Hit Litro (botella)',           precio: 3_500, stock_actual: 12, stock_minimo: 3, unidad: 'unidad' },
  { nombre: 'Postobon Personal (botella)',   precio: 2_000, stock_actual: 24, stock_minimo: 6, unidad: 'unidad' },
  { nombre: 'Mr Tea (botella)',              precio: 2_000, stock_actual: 24, stock_minimo: 6, unidad: 'unidad' },
  { nombre: 'Quatro (botella)',              precio: 2_000, stock_actual: 24, stock_minimo: 6, unidad: 'unidad' },
  { nombre: 'Sprite (botella)',              precio: 2_000, stock_actual: 24, stock_minimo: 6, unidad: 'unidad' },
  { nombre: 'Agua Brisa Mini (botella)',     precio: 1_200, stock_actual: 24, stock_minimo: 6, unidad: 'unidad' },
  { nombre: 'Agua Brisa 1.5L (botella)',     precio: 3_500, stock_actual: 12, stock_minimo: 3, unidad: 'unidad' },
  { nombre: 'Agua Natural (botella)',        precio: 1_200, stock_actual: 24, stock_minimo: 6, unidad: 'unidad' },
]

ingredients_data.each do |i|
  Ingredient.find_or_create_by!(nombre: i[:nombre]) do |ing|
    ing.precio       = i[:precio]
    ing.stock_actual = i[:stock_actual]
    ing.stock_minimo = i[:stock_minimo]
    ing.unidad       = i[:unidad]
    ing.activo       = true
  end
end
puts "✓ #{Ingredient.count} ingredientes creados"

# ── Productos ────────────────────────────────────────────────
# Carta real Hi Papa: 4 papas x 2 tamaños + bebidas
products_data = [
  # ── Papas Grande ──────────────────────────────────────────
  {
    nombre:      'La Toxica Grande',
    descripcion: 'Chicharrón, guacamole, sour cream, ripio de tostinachos, huevos de codorniz, papas a la francesa y salsas al gusto',
    precio:      28_000, categoria: 'Papas', posicion: 1
  },
  {
    nombre:      'La Prohibida Grande',
    descripcion: 'Carne BBQ desmechada, guacamole, queso mozzarella, maicitos, huevos de codorniz, papas a la francesa y salsas al gusto',
    precio:      28_000, categoria: 'Papas', posicion: 2
  },
  {
    nombre:      'La Tragona Grande',
    descripcion: 'Carne BBQ desmechada, pollo desmechado, sour cream, huevos de codorniz, papas a la francesa y salsas al gusto',
    precio:      28_000, categoria: 'Papas', posicion: 3
  },
  {
    nombre:      'La Humilde Grande',
    descripcion: 'Tocineta, queso mozzarella, huevos de codorniz, papas a la francesa y salsas al gusto',
    precio:      22_000, categoria: 'Papas', posicion: 4
  },
  # ── Papas Personal ────────────────────────────────────────
  {
    nombre:      'La Toxica Personal',
    descripcion: 'Chicharrón, guacamole, sour cream, ripio de tostinachos, huevos de codorniz, papas a la francesa y salsas al gusto',
    precio:      17_500, categoria: 'Papas', posicion: 5
  },
  {
    nombre:      'La Prohibida Personal',
    descripcion: 'Carne BBQ desmechada, guacamole, queso mozzarella, maicitos, huevos de codorniz, papas a la francesa y salsas al gusto',
    precio:      17_500, categoria: 'Papas', posicion: 6
  },
  {
    nombre:      'La Tragona Personal',
    descripcion: 'Carne BBQ desmechada, pollo desmechado, sour cream, huevos de codorniz, papas a la francesa y salsas al gusto',
    precio:      17_500, categoria: 'Papas', posicion: 7
  },
  {
    nombre:      'La Humilde Personal',
    descripcion: 'Tocineta, queso mozzarella, huevos de codorniz, papas a la francesa y salsas al gusto',
    precio:      15_000, categoria: 'Papas', posicion: 8
  },
  # ── Bebidas ───────────────────────────────────────────────
  { nombre: 'Coca Cola Mini',       descripcion: 'Coca Cola botella pequeña',     precio:  2_500, categoria: 'Bebidas', posicion: 1 },
  { nombre: 'Coca Cola Personal',   descripcion: 'Coca Cola personal',            precio:  4_500, categoria: 'Bebidas', posicion: 2 },
  { nombre: 'Coca Cola 1.5',        descripcion: 'Coca Cola 1.5 litros',          precio:  7_500, categoria: 'Bebidas', posicion: 3 },
  { nombre: 'Hit Personal',         descripcion: 'Hit personal',                  precio:  3_500, categoria: 'Bebidas', posicion: 4 },
  { nombre: 'Hit Litro',            descripcion: 'Hit litro',                     precio:  6_000, categoria: 'Bebidas', posicion: 5 },
  { nombre: 'Postobon Personal',    descripcion: 'Postobon personal',             precio:  3_500, categoria: 'Bebidas', posicion: 6 },
  { nombre: 'Mr Tea',               descripcion: 'Mr Tea',                        precio:  3_500, categoria: 'Bebidas', posicion: 7 },
  { nombre: 'Quatro',               descripcion: 'Quatro',                        precio:  3_500, categoria: 'Bebidas', posicion: 8 },
  { nombre: 'Sprite',               descripcion: 'Sprite',                        precio:  3_500, categoria: 'Bebidas', posicion: 9 },
  { nombre: 'Agua Brisa Mini',      descripcion: 'Agua Brisa mini',               precio:  2_500, categoria: 'Bebidas', posicion: 10 },
  { nombre: 'Agua Brisa 1.5',       descripcion: 'Agua Brisa 1.5 litros',         precio:  6_000, categoria: 'Bebidas', posicion: 11 },
  { nombre: 'Agua Natural',         descripcion: 'Agua natural',                  precio:  2_500, categoria: 'Bebidas', posicion: 12 },
]

products_data.each do |p|
  Product.find_or_create_by!(nombre: p[:nombre]) do |prod|
    prod.descripcion = p[:descripcion]
    prod.precio      = p[:precio]
    prod.categoria   = p[:categoria]
    prod.posicion    = p[:posicion]
    prod.activo      = true
  end
end
puts "✓ #{Product.count} productos creados"

# ── Recetas ──────────────────────────────────────────────────
# Cantidades: papas en gramos, líquidos en ml, sólidos en g, unidades como número
# Grande: ~350g papas / Personal: ~200g papas
# Toppings Grande: ~80g proteína, ~60g salsas; Personal: ~50g / ~40g

recipes_data = {
  'La Toxica Grande' => {
    notas: 'Freír papas a 180°C. Montar chicharrón, guacamole, sour cream, tostinachos y huevos.',
    items: [
      { nombre: 'Papas a la francesa',  cantidad: 350 },
      { nombre: 'Aceite vegetal',       cantidad: 80 },
      { nombre: 'Chicharrón',           cantidad: 80 },
      { nombre: 'Guacamole',            cantidad: 60 },
      { nombre: 'Sour cream',           cantidad: 50 },
      { nombre: 'Ripio de tostinachos', cantidad: 30 },
      { nombre: 'Huevo de codorniz',    cantidad: 4  },
    ]
  },
  'La Toxica Personal' => {
    notas: 'Freír papas a 180°C. Montar chicharrón, guacamole, sour cream, tostinachos y huevos.',
    items: [
      { nombre: 'Papas a la francesa',  cantidad: 200 },
      { nombre: 'Aceite vegetal',       cantidad: 50 },
      { nombre: 'Chicharrón',           cantidad: 50 },
      { nombre: 'Guacamole',            cantidad: 40 },
      { nombre: 'Sour cream',           cantidad: 30 },
      { nombre: 'Ripio de tostinachos', cantidad: 20 },
      { nombre: 'Huevo de codorniz',    cantidad: 2  },
    ]
  },
  'La Prohibida Grande' => {
    notas: 'Freír papas a 180°C. Montar carne BBQ, guacamole, queso mozzarella, maicitos y huevos.',
    items: [
      { nombre: 'Papas a la francesa',  cantidad: 350 },
      { nombre: 'Aceite vegetal',       cantidad: 80 },
      { nombre: 'Carne BBQ desmechada', cantidad: 80 },
      { nombre: 'Guacamole',            cantidad: 60 },
      { nombre: 'Queso mozzarella',     cantidad: 50 },
      { nombre: 'Maicitos',             cantidad: 1  },
      { nombre: 'Huevo de codorniz',    cantidad: 4  },
    ]
  },
  'La Prohibida Personal' => {
    notas: 'Freír papas a 180°C. Montar carne BBQ, guacamole, queso mozzarella, maicitos y huevos.',
    items: [
      { nombre: 'Papas a la francesa',  cantidad: 200 },
      { nombre: 'Aceite vegetal',       cantidad: 50 },
      { nombre: 'Carne BBQ desmechada', cantidad: 50 },
      { nombre: 'Guacamole',            cantidad: 40 },
      { nombre: 'Queso mozzarella',     cantidad: 30 },
      { nombre: 'Maicitos',             cantidad: 1  },
      { nombre: 'Huevo de codorniz',    cantidad: 2  },
    ]
  },
  'La Tragona Grande' => {
    notas: 'Freír papas a 180°C. Montar carne BBQ, pollo desmechado, sour cream y huevos.',
    items: [
      { nombre: 'Papas a la francesa',  cantidad: 350 },
      { nombre: 'Aceite vegetal',       cantidad: 80 },
      { nombre: 'Carne BBQ desmechada', cantidad: 60 },
      { nombre: 'Pollo desmechado',     cantidad: 60 },
      { nombre: 'Sour cream',           cantidad: 50 },
      { nombre: 'Huevo de codorniz',    cantidad: 4  },
    ]
  },
  'La Tragona Personal' => {
    notas: 'Freír papas a 180°C. Montar carne BBQ, pollo desmechado, sour cream y huevos.',
    items: [
      { nombre: 'Papas a la francesa',  cantidad: 200 },
      { nombre: 'Aceite vegetal',       cantidad: 50 },
      { nombre: 'Carne BBQ desmechada', cantidad: 40 },
      { nombre: 'Pollo desmechado',     cantidad: 40 },
      { nombre: 'Sour cream',           cantidad: 30 },
      { nombre: 'Huevo de codorniz',    cantidad: 2  },
    ]
  },
  'La Humilde Grande' => {
    notas: 'Freír papas a 180°C. Montar tocineta crujiente, queso mozzarella y huevos.',
    items: [
      { nombre: 'Papas a la francesa',  cantidad: 350 },
      { nombre: 'Aceite vegetal',       cantidad: 80 },
      { nombre: 'Tocineta',             cantidad: 80 },
      { nombre: 'Queso mozzarella',     cantidad: 60 },
      { nombre: 'Huevo de codorniz',    cantidad: 4  },
    ]
  },
  'La Humilde Personal' => {
    notas: 'Freír papas a 180°C. Montar tocineta crujiente, queso mozzarella y huevos.',
    items: [
      { nombre: 'Papas a la francesa',  cantidad: 200 },
      { nombre: 'Aceite vegetal',       cantidad: 50 },
      { nombre: 'Tocineta',             cantidad: 50 },
      { nombre: 'Queso mozzarella',     cantidad: 40 },
      { nombre: 'Huevo de codorniz',    cantidad: 2  },
    ]
  },
}

recipes_data.each do |product_name, data|
  product = Product.find_by(nombre: product_name)
  next unless product && product.recipe.nil?

  recipe = product.create_recipe!(notas: data[:notas])
  ingredients = data[:items].map do |item|
    ing = Ingredient.find_by(nombre: item[:nombre])
    ing ? { ingredient: ing, cantidad: item[:cantidad] } : nil
  end.compact

  recipe.recipe_ingredients.create!(ingredients) if ingredients.any?
  puts "✓ Receta '#{product_name}' creada (costo: $#{product.reload.costo_calculado})"
end

puts ""
puts "=== Seeds completados ==="
puts "   URL pública del menú: http://localhost:3000/public"
puts "   Admin: admin@hipapa.com / Admin123!"
puts "   Salsas: #{Sauce.count} | Productos: #{Product.count} | Ingredientes: #{Ingredient.count}"
