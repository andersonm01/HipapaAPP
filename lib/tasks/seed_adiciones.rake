namespace :db do
  desc "Normalizar los productos de la categoría Adiciones (prefijo 'Adi' -> 'Adición') y completar la variante faltante de Huevo de Codorniz"
  task seed_adiciones: :environment do
    # Los productos de "Adiciones" ya existían en la base de datos (cargados
    # a mano desde /products), con nombres inconsistentes: prefijo "Adi",
    # mayúsculas variables, sin tildes. Esta tarea los renombra en el mismo
    # registro (mismo product_id, no rompe historial de pedidos ni reportes)
    # y agrega la variante Personal de Huevo de Codorniz que faltaba.
    # Idempotente: se puede correr varias veces sin duplicar ni fallar.
    renames = {
      'Adi Carne GRANDE'        => { nombre: 'Adición Carne Grande',              descripcion: 'Adición de carne',              posicion: 1  },
      'Adi Carne Personal'      => { nombre: 'Adición Carne Personal',            descripcion: 'Adición de carne',              posicion: 2  },
      'Adi pollo Grande'        => { nombre: 'Adición Pollo Grande',              descripcion: 'Adición de pollo',              posicion: 3  },
      'Adi Pollo Personal'      => { nombre: 'Adición Pollo Personal',            descripcion: 'Adición de pollo',              posicion: 4  },
      'Adi Guacamole Grande'    => { nombre: 'Adición Guacamole Grande',          descripcion: 'Adición de guacamole',          posicion: 5  },
      'Adi Guacamole Personal'  => { nombre: 'Adición Guacamole Personal',        descripcion: 'Adición de guacamole',          posicion: 6  },
      'Adi Sour cream Grande'   => { nombre: 'Adición Sour Cream Grande',         descripcion: 'Adición de sour cream',         posicion: 7  },
      'Adi Sour cream Personal' => { nombre: 'Adición Sour Cream Personal',       descripcion: 'Adición de sour cream',         posicion: 8  },
      'Adi Queso Grande'        => { nombre: 'Adición Queso Grande',              descripcion: 'Adición de queso',              posicion: 9  },
      'Adi Queso Personal'      => { nombre: 'Adición Queso Personal',            descripcion: 'Adición de queso',              posicion: 10 },
      'Adi Tocineta Grande'     => { nombre: 'Adición Tocineta Grande',           descripcion: 'Adición de tocineta',           posicion: 11 },
      'Adi Tocineta Personal'   => { nombre: 'Adición Tocineta Personal',         descripcion: 'Adición de tocineta',           posicion: 12 },
      'Adi Chicharron Grande'   => { nombre: 'Adición Chicharrón Grande',         descripcion: 'Adición de chicharrón',         posicion: 13 },
      'Adi Chicharron Personal' => { nombre: 'Adición Chicharrón Personal',       descripcion: 'Adición de chicharrón',         posicion: 14 },
      'Adi Huevo'               => { nombre: 'Adición Huevo de Codorniz Grande',  descripcion: 'Adición de huevo de codorniz',  posicion: 15 },
    }

    renamed = 0
    already_ok = 0

    renames.each do |old_nombre, attrs|
      product = Product.find_by(categoria: 'Adiciones', nombre: old_nombre)

      if product
        product.update!(nombre: attrs[:nombre], descripcion: attrs[:descripcion], posicion: attrs[:posicion])
        renamed += 1
        puts "✓ Renombrado: \"#{old_nombre}\" -> \"#{attrs[:nombre]}\""
      elsif Product.exists?(categoria: 'Adiciones', nombre: attrs[:nombre])
        already_ok += 1
      else
        puts "⚠️  No se encontró \"#{old_nombre}\" ni \"#{attrs[:nombre]}\" — revisar manualmente"
      end
    end

    created = 0
    Product.find_or_create_by!(nombre: 'Adición Huevo de Codorniz Personal') do |prod|
      prod.descripcion = 'Adición de huevo de codorniz'
      prod.precio       = 500
      prod.categoria    = 'Adiciones'
      prod.posicion     = 16
      prod.activo       = true
      created += 1
    end

    puts "\n✅ Adiciones normalizadas: #{renamed} renombrados, #{already_ok} ya estaban al día, #{created} creados."
  end
end
