namespace :db do
  desc "Clean all test sales data (Orders, Invoices, OrderItems, CashMovements)"
  task clean_sales: :environment do
    puts "🗑️  Limpiando datos de prueba..."
    
    # Delete in correct order (foreign keys)
    OrderItem.delete_all
    puts "✓ Orden Items eliminados"
    
    Order.delete_all
    puts "✓ Órdenes eliminadas"
    
    Invoice.delete_all
    puts "✓ Facturas eliminadas"
    
    CashMovement.delete_all
    puts "✓ Movimientos de caja eliminados"
    
    puts "\n✅ Datos de prueba eliminados. Base de datos limpia lista para producción."
  end
end

