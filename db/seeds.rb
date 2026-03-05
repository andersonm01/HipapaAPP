# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Default admin user
unless User.exists?(email: 'admin@hipapa.com')
  User.create!(
    name: 'Administrador',
    email: 'admin@hipapa.com',
    password: 'Admin123!',
    password_confirmation: 'Admin123!',
    role: 'admin',
    active: true
  )
  puts "Admin creado: admin@hipapa.com / Admin123!"
else
  puts "Admin ya existe: admin@hipapa.com"
end
