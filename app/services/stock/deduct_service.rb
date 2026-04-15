module Stock
  class DeductService
    def initialize(order)
      @order = order
    end

    def call
      ActiveRecord::Base.transaction do
        @order.order_items.includes(product: { recipe: { recipe_ingredients: :ingredient } }).each do |item|
          deduct_for_item(item)
        end
      end
      notify_low_stock
    rescue => e
      Rails.logger.error("[Stock::DeductService] Error al descontar stock: #{e.message}")
    end

    private

    def deduct_for_item(item)
      recipe = item.product.recipe
      return unless recipe

      recipe.recipe_ingredients.each do |ri|
        total_needed = ri.cantidad * item.cantidad
        ingredient = Ingredient.lock.find(ri.ingredient_id)

        if ingredient.stock_actual < total_needed
          Rails.logger.warn("[StockDeduct] Stock insuficiente para #{ingredient.nombre}: necesita #{total_needed} #{ingredient.unidad}, tiene #{ingredient.stock_actual}")
        end

        new_stock = [ingredient.stock_actual - total_needed, 0].max
        ingredient.update_column(:stock_actual, new_stock)
      end
    end

    def notify_low_stock
      low = Ingredient.where(activo: true).where('stock_actual <= stock_minimo')
      return if low.empty?

      ActionCable.server.broadcast("admin_channel", {
        type: "low_stock_alert",
        count: low.count,
        ingredients: low.map { |i| { id: i.id, nombre: i.nombre, stock: i.stock_actual.to_f, unidad: i.unidad } }
      })
    end
  end
end
