module Reports
  # KPIs + gráficas agregadas para el dashboard, a partir de scopes ya
  # filtrados (Ransack) de Order/OrderItem. Revenue siempre es monto_pagado
  # (lo efectivamente cobrado), nunca la suma de order_items.
  class SummaryQuery
    include Reports::SqlTimeExpressions

    MAP_SERVICIO = { 'mesa' => 'En Mesa', 'llevar' => 'Para Llevar', 'domicilio' => 'Domicilio' }.freeze
    MAP_PAGO     = { 'efectivo' => 'Efectivo', 'transferencia' => 'Transferencia' }.freeze

    def initialize(orders:, prev_orders:, items:)
      @orders      = orders
      @prev_orders = prev_orders
      @items       = items
    end

    def call
      {
        kpis:         kpis,
        top_products: top_products,
        by_category:  by_category,
        by_servicio:  by_servicio,
        by_pago:      by_pago,
        sellers:      sellers,
        heatmap:      heatmap
      }
    end

    private

    def kpis
      revenue      = @orders.sum(:monto_pagado).to_f
      prev_revenue = @prev_orders.sum(:monto_pagado).to_f
      count        = @orders.count
      prev_count   = @prev_orders.count
      avg          = count > 0 ? revenue / count : 0.0
      prev_avg     = prev_count > 0 ? prev_revenue / prev_count : 0.0
      items_sold   = @items.sum(:cantidad).to_i

      {
        revenue:    { value: revenue,  prev: prev_revenue, growth: growth(revenue, prev_revenue) },
        orders:     { value: count,    prev: prev_count,   growth: growth(count,   prev_count)   },
        avg_ticket: { value: avg,      prev: prev_avg,     growth: growth(avg,     prev_avg)     },
        items_sold: { value: items_sold }
      }
    end

    def top_products
      @items.joins(:product)
        .group('products.id', 'products.nombre', 'products.categoria')
        .select(
          'products.nombre           AS nombre',
          'products.categoria        AS categoria',
          'SUM(order_items.cantidad) AS total_cantidad',
          'SUM(order_items.cantidad * order_items.precio_unitario) AS total_revenue'
        )
        .order('total_revenue DESC')
        .limit(10)
        .map { |r| { nombre: r.nombre, categoria: r.categoria, cantidad: r.total_cantidad.to_i, revenue: r.total_revenue.to_f } }
    end

    def by_category
      data = @items.joins(:product)
                   .group('products.categoria')
                   .sum('order_items.cantidad * order_items.precio_unitario')
                   .sort_by { |_, v| -v }
      { labels: data.map(&:first), values: data.map { |_, v| v.to_f } }
    end

    def by_servicio
      data = @orders.group(:tipo_servicio).count
      { labels: data.keys.map { |k| MAP_SERVICIO[k] || k.to_s.capitalize }, values: data.values }
    end

    def by_pago
      data = @orders.group(:tipo_pago).sum(:monto_pagado)
      { labels: data.keys.map { |k| MAP_PAGO[k] || k.to_s.capitalize }, values: data.map { |_, v| v.to_f } }
    end

    def sellers
      @orders.group(:mesero)
        .select(
          :mesero,
          'COUNT(*)          AS orders_count',
          'SUM(monto_pagado) AS total_revenue',
          'AVG(monto_pagado) AS avg_ticket'
        )
        .order('total_revenue DESC')
        .map { |r| { mesero: r.mesero.presence || 'Sin asignar', orders: r.orders_count.to_i, revenue: r.total_revenue.to_f, avg: r.avg_ticket.to_f } }
    end

    # Día de la semana (0=domingo..6=sábado) × hora (0..23) → revenue.
    def heatmap
      data = @orders.group(local_dow_expr, local_hour_expr).sum(:monto_pagado)
      data.map { |(dow, hour), revenue| { dow: dow.to_i, hour: hour.to_i, revenue: revenue.to_f } }
    end

    def growth(current, prev)
      return 0.0 if prev.nil? || prev.zero?

      ((current.to_f - prev.to_f) / prev.to_f * 100).round(1)
    end
  end
end
