namespace :db do
  desc "Add adiciones (extra toppings) to products"
  task add_additions: :environment do
    puts "➕ Agregando adiciones..."

    additions_data = [
      { nombre: 'Carne BBQ Extra', descripcion: 'Porción extra de carne BBQ desmechada', precio: 5_000, categoria: 'Adiciones', posicion: 1 },
      { nombre: 'Pollo Extra', descripcion: 'Porción extra de pollo desmechado', precio: 5_000, categoria: 'Adiciones', posicion: 2 },
      { nombre: 'Guacamole Extra', descripcion: 'Porción extra de guacamole', precio: 4_000, categoria: 'Adiciones', posicion: 3 },
      { nombre: 'Queso Extra', descripcion: 'Porción extra de queso mozzarella', precio: 4_000, categoria: 'Adiciones', posicion: 4 },
      { nombre: 'Chicharrón Extra', descripcion: 'Porción extra de chicharrón', precio: 5_000, categoria: 'Adiciones', posicion: 5 },
      { nombre: 'Tocineta Extra', descripcion: 'Porción extra de tocineta crujiente', precio: 5_000, categoria: 'Adiciones', posicion: 6 },
      { nombre: 'Sour Cream Extra', descripcion: 'Porción extra de sour cream', precio: 2_000, categoria: 'Adiciones', posicion: 7 },
      { nombre: 'Huevos Extra', descripcion: 'Huevos de codorniz adicionales (3 unidades)', precio: 2_000, categoria: 'Adiciones', posicion: 8 },
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

