namespace :db do
  desc "Add adiciones (extra toppings) to products"
  task add_additions: :environment do
    puts "➕ Agregando adiciones..."

    additions_data = [
      { nombre: 'Carne BBQ Extra Personal', descripcion: 'Porción extra de carne BBQ desmechada', precio: 3_000, categoria: 'Adiciones', posicion: 1 },
      { nombre: 'Carne BBQ Extra Grande', descripcion: 'Porción extra de carne BBQ desmechada', precio: 5_000, categoria: 'Adiciones', posicion: 2 },
      { nombre: 'Pollo Extra Personal', descripcion: 'Porción extra de pollo desmechado', precio: 3_000, categoria: 'Adiciones', posicion: 3 },
      { nombre: 'Pollo Extra Grande', descripcion: 'Porción extra de pollo desmechado', precio: 5_000, categoria: 'Adiciones', posicion: 4 },
      { nombre: 'Guacamole Extra Personal', descripcion: 'Porción extra de guacamole', precio: 2_500, categoria: 'Adiciones', posicion: 5 },
      { nombre: 'Guacamole Extra Grande', descripcion: 'Porción extra de guacamole', precio: 4_000, categoria: 'Adiciones', posicion: 6 },
      { nombre: 'Queso Extra Personal', descripcion: 'Porción extra de queso mozzarella', precio: 2_500, categoria: 'Adiciones', posicion: 7 },
      { nombre: 'Queso Extra Grande', descripcion: 'Porción extra de queso mozzarella', precio: 4_000, categoria: 'Adiciones', posicion: 8 },
      { nombre: 'Chicharrón Extra Personal', descripcion: 'Porción extra de chicharrón', precio: 3_000, categoria: 'Adiciones', posicion: 9 },
      { nombre: 'Chicharrón Extra Grande', descripcion: 'Porción extra de chicharrón', precio: 5_000, categoria: 'Adiciones', posicion: 10 },
      { nombre: 'Tocineta Extra Personal', descripcion: 'Porción extra de tocineta crujiente', precio: 3_000, categoria: 'Adiciones', posicion: 11 },
      { nombre: 'Tocineta Extra Grande', descripcion: 'Porción extra de tocineta crujiente', precio: 5_000, categoria: 'Adiciones', posicion: 12 },
      { nombre: 'Sour Cream Extra Personal', descripcion: 'Porción extra de sour cream', precio: 1_500, categoria: 'Adiciones', posicion: 13 },
      { nombre: 'Sour Cream Extra Grande', descripcion: 'Porción extra de sour cream', precio: 2_000, categoria: 'Adiciones', posicion: 14 },
      { nombre: 'Huevos Extra Personal', descripcion: 'Huevos de codorniz adicionales (2 unidades)', precio: 1_500, categoria: 'Adiciones', posicion: 15 },
      { nombre: 'Huevos Extra Grande', descripcion: 'Huevos de codorniz adicionales (3 unidades)', precio: 2_000, categoria: 'Adiciones', posicion: 16 },
    ]

    additions_data.each do |a|
      Product.find_or_create_by!(nombre: a[:nombre]) do |prod|
        prod.descripcion = a[:descripcion]
        prod.precio = a[:precio]
        prod.categoria = a[:categoria]
        prod.posicion = a[:posicion]
        prod.activo = true
      end
    end

    puts "✓ #{additions_data.count} adiciones agregadas"
    puts "\n✅ Adiciones listas para usar"
  end
end

