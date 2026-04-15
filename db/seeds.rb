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
  descripcion:      'Las mejores hamburguesas y papas con todo de la ciudad 🍔',
  color_primario:   '#f59e0b',
  color_secundario: '#0f172a',
  color_acento:     '#fbbf24',
  whatsapp_negocio: '573001234567'
)
setting.save!
puts "✓ BusinessSetting configurado"

# ── Salsas ──────────────────────────────────────────────────
sauces_data = [
  { nombre: 'Kétchup',    color: '#dc2626', posicion: 1 },
  { nombre: 'Mayonesa',   color: '#fbbf24', posicion: 2 },
  { nombre: 'Mostaza',    color: '#ca8a04', posicion: 3 },
  { nombre: 'BBQ',        color: '#92400e', posicion: 4 },
  { nombre: 'Picante',    color: '#ef4444', posicion: 5 },
  { nombre: 'Ranch',      color: '#a3e635', posicion: 6 },
  { nombre: 'Especial Hi Papa', color: '#f97316', posicion: 7 },
  { nombre: 'Sin salsa',  color: '#94a3b8', posicion: 8 },
]

sauces_data.each do |s|
  Sauce.find_or_create_by!(nombre: s[:nombre]) do |sauce|
    sauce.color    = s[:color]
    sauce.posicion = s[:posicion]
    sauce.activo   = true
  end
end
puts "✓ #{Sauce.count} salsas creadas"

# ── Ingredientes base ────────────────────────────────────────
ingredients_data = [
  # Precio por kg/L/unidad para que precio_por_unidad_base calcule por g/ml correctamente
  { nombre: 'Carne de res (molida)',   precio: 25_000, stock_actual: 5,    stock_minimo: 0.5,  unidad: 'kg'    },
  { nombre: 'Pan de hamburguesa',      precio: 1_500,  stock_actual: 50,   stock_minimo: 10,   unidad: 'unidad'},
  { nombre: 'Queso cheddar',           precio: 18_000, stock_actual: 2,    stock_minimo: 0.2,  unidad: 'kg'    },
  { nombre: 'Papa criolla',            precio: 3_000,  stock_actual: 10,   stock_minimo: 1,    unidad: 'kg'    },
  { nombre: 'Aceite vegetal',          precio: 8_000,  stock_actual: 3,    stock_minimo: 0.5,  unidad: 'L'     },
  { nombre: 'Lechuga',                 precio: 2_000,  stock_actual: 0.8,  stock_minimo: 0.2,  unidad: 'kg'    },
  { nombre: 'Tomate',                  precio: 3_000,  stock_actual: 1.5,  stock_minimo: 0.3,  unidad: 'kg'    },
  { nombre: 'Tocino/Bacon',            precio: 22_000, stock_actual: 1,    stock_minimo: 0.2,  unidad: 'kg'    },
  { nombre: 'Huevo',                   precio: 500,    stock_actual: 30,   stock_minimo: 6,    unidad: 'unidad'},
  { nombre: 'Sal',                     precio: 1_000,  stock_actual: 1,    stock_minimo: 0.1,  unidad: 'kg'    },
  { nombre: 'Gaseosa (botella 300ml)', precio: 2_500,  stock_actual: 48,   stock_minimo: 12,   unidad: 'unidad'},
  { nombre: 'Agua (botella 500ml)',    precio: 1_200,  stock_actual: 24,   stock_minimo: 6,    unidad: 'unidad'},
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
products_data = [
  # Hamburguesas
  { nombre: 'Hamburguesa Clásica',    descripcion: 'Carne, queso, lechuga, tomate',   precio: 18_000, categoria: 'Hamburguesas', posicion: 1 },
  { nombre: 'Hamburguesa Especial',   descripcion: 'Doble carne, tocino, huevo frito', precio: 24_000, categoria: 'Hamburguesas', posicion: 2 },
  { nombre: 'Hamburguesa Pollo',      descripcion: 'Pollo a la plancha, aguacate',     precio: 16_000, categoria: 'Hamburguesas', posicion: 3 },
  # Papas
  { nombre: 'Papas Fritas',           descripcion: 'Papa criolla frita en aceite',     precio: 8_000,  categoria: 'Papas',        posicion: 1 },
  { nombre: 'Papas con Todo',         descripcion: 'Papas + carne + queso + salsas',   precio: 15_000, categoria: 'Papas',        posicion: 2 },
  { nombre: 'Papas Tocino',           descripcion: 'Papas fritas con tocino crujiente', precio: 12_000, categoria: 'Papas',        posicion: 3 },
  # Bebidas
  { nombre: 'Gaseosa 300ml',          descripcion: 'Coca-Cola, Pepsi, Sprite',         precio: 3_500,  categoria: 'Bebidas',      posicion: 1 },
  { nombre: 'Agua 500ml',             descripcion: 'Agua mineral o natural',            precio: 2_000,  categoria: 'Bebidas',      posicion: 2 },
  { nombre: 'Jugo Natural',           descripcion: 'Maracuyá, mango o mora',            precio: 4_500,  categoria: 'Bebidas',      posicion: 3 },
  # Combos
  { nombre: 'Combo Clásico',          descripcion: 'Hamburguesa Clásica + Papas + Bebida', precio: 25_000, categoria: 'Combos', posicion: 1 },
  { nombre: 'Combo Especial',         descripcion: 'Hamburguesa Especial + Papas con Todo + Bebida', precio: 35_000, categoria: 'Combos', posicion: 2 },
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

# ── Receta de ejemplo: Hamburguesa Clásica ───────────────────
hamburguesa = Product.find_by(nombre: 'Hamburguesa Clásica')
if hamburguesa && hamburguesa.recipe.nil?
  recipe = hamburguesa.create_recipe!(notas: 'Asar carne 3 min por lado a fuego alto')

  carne  = Ingredient.find_by(nombre: 'Carne de res (molida)')
  pan    = Ingredient.find_by(nombre: 'Pan de hamburguesa')
  queso  = Ingredient.find_by(nombre: 'Queso cheddar')
  lechuga = Ingredient.find_by(nombre: 'Lechuga')
  tomate = Ingredient.find_by(nombre: 'Tomate')

  recipe.recipe_ingredients.create!([
    { ingredient: carne,   cantidad: 150 },  # 150g de carne
    { ingredient: pan,     cantidad: 1   },  # 1 pan
    { ingredient: queso,   cantidad: 30  },  # 30g queso
    { ingredient: lechuga, cantidad: 20  },  # 20g lechuga
    { ingredient: tomate,  cantidad: 40  },  # 40g tomate
  ]) if carne && pan && queso

  puts "✓ Receta de Hamburguesa Clásica creada (costo: $#{hamburguesa.reload.costo_calculado})"
end

# ── Receta: Papas Fritas ─────────────────────────────────────
papas = Product.find_by(nombre: 'Papas Fritas')
if papas && papas.recipe.nil?
  recipe = papas.create_recipe!(notas: 'Freír a 180°C por 5 minutos')
  papa  = Ingredient.find_by(nombre: 'Papa criolla')
  aceite = Ingredient.find_by(nombre: 'Aceite vegetal')
  sal    = Ingredient.find_by(nombre: 'Sal')

  recipe.recipe_ingredients.create!([
    { ingredient: papa,   cantidad: 250 },
    { ingredient: aceite, cantidad: 50  },
    { ingredient: sal,    cantidad: 5   },
  ]) if papa && aceite && sal

  puts "✓ Receta de Papas Fritas creada (costo: $#{papas.reload.costo_calculado})"
end

puts ""
puts "=== Seeds completados ==="
puts "   URL pública del menú: http://localhost:3000/public"
puts "   Admin: admin@hipapa.com / Admin123!"
puts "   Salsas: #{Sauce.count} | Productos: #{Product.count} | Ingredientes: #{Ingredient.count}"
