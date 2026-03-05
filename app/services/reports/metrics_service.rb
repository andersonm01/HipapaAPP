module Reports
  class MetricsService
    DAYS_ES   = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'].freeze
    MONTHS_ES = %w[Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre].freeze

    def initialize(period:, from: nil, to: nil)
      @period = period.to_sym
      @range  = build_range(from, to)
      @prev   = build_prev_range
    end

    def call
      {
        kpis:   kpis,
        charts: charts,
        tables: tables,
        meta:   { period: @period, from: @range.begin, to: @range.end,
                  prev_from: @prev.begin, prev_to: @prev.end }
      }
    end

    private

    # ─── Ranges ───────────────────────────────────────────────────────────────

    def build_range(from, to)
      case @period
      when :today      then Time.current.beginning_of_day..Time.current.end_of_day
      when :yesterday  then 1.day.ago.beginning_of_day..1.day.ago.end_of_day
      when :week       then Time.current.beginning_of_week..Time.current.end_of_week
      when :last_week  then 1.week.ago.beginning_of_week..1.week.ago.end_of_week
      when :month      then Time.current.beginning_of_month..Time.current.end_of_month
      when :last_month then 1.month.ago.beginning_of_month..1.month.ago.end_of_month
      when :year       then Time.current.beginning_of_year..Time.current.end_of_year
      when :custom     then from.to_date.beginning_of_day..to.to_date.end_of_day
      else                  Time.current.beginning_of_day..Time.current.end_of_day
      end
    end

    def build_prev_range
      duration = @range.end - @range.begin
      (@range.begin - duration - 1.second)..(@range.begin - 1.second)
    end

    # ─── Base scopes ──────────────────────────────────────────────────────────

    def closed_orders
      @closed_orders ||= Order.where(status: 1, created_at: @range)
    end

    def prev_closed_orders
      @prev_closed_orders ||= Order.where(status: 1, created_at: @prev)
    end

    def closed_items_scope(range = @range)
      OrderItem.joins(:order).where(orders: { status: 1, created_at: range })
    end

    # ─── KPIs ─────────────────────────────────────────────────────────────────

    def kpis
      revenue      = closed_orders.sum(:monto_pagado).to_f
      prev_revenue = prev_closed_orders.sum(:monto_pagado).to_f
      count        = closed_orders.count
      prev_count   = prev_closed_orders.count
      avg          = count > 0 ? revenue / count : 0.0
      prev_avg     = prev_count > 0 ? prev_revenue / prev_count : 0.0
      items        = closed_items_scope.sum(:cantidad).to_i

      {
        revenue:    { value: revenue,  prev: prev_revenue, growth: growth(revenue, prev_revenue) },
        orders:     { value: count,    prev: prev_count,   growth: growth(count,   prev_count)   },
        avg_ticket: { value: avg,      prev: prev_avg,     growth: growth(avg,     prev_avg)     },
        items_sold: { value: items }
      }
    end

    # ─── Charts ───────────────────────────────────────────────────────────────

    def charts
      {
        revenue_trend:   revenue_trend,
        revenue_by_hour: revenue_by_hour,
        revenue_by_dow:  revenue_by_dow,
        by_category:     by_category,
        by_servicio:     by_servicio,
        by_pago:         by_pago
      }
    end

    def revenue_trend
      if %i[today yesterday].include?(@period)
        # Agrupar por hora
        data   = closed_orders
                   .group(local_hour_expr)
                   .order(Arel.sql(local_hour_expr))
                   .sum(:monto_pagado)
        labels = (0..23).map { |h| "#{h.to_s.rjust(2, '0')}:00" }
        values = (0..23).map { |h| data[h]&.to_f || 0.0 }
      elsif @period == :year
        # Agrupar por mes
        data   = closed_orders
                   .group(local_month_expr)
                   .order(Arel.sql(local_month_expr))
                   .sum(:monto_pagado)
        labels = MONTHS_ES
        values = (1..12).map { |m| data[m.to_s.rjust(2, '0')]&.to_f || 0.0 }
      else
        # Agrupar por día
        data   = closed_orders
                   .group(local_date_expr)
                   .order(Arel.sql(local_date_expr))
                   .sum(:monto_pagado)
        labels = []
        values = []
        current  = @range.begin.to_date
        end_date = [@range.end.to_date, Date.current].min
        while current <= end_date
          labels << current.strftime('%d/%m')
          values << (data[current.to_s]&.to_f || 0.0)
          current += 1.day
        end
      end

      { labels: labels, values: values }
    end

    def revenue_by_hour
      data   = closed_orders
                 .group(local_hour_expr)
                 .order(Arel.sql(local_hour_expr))
                 .sum(:monto_pagado)
      labels = (0..23).map { |h| "#{h.to_s.rjust(2, '0')}:00" }
      values = (0..23).map { |h| data[h]&.to_f || 0.0 }
      { labels: labels, values: values }
    end

    def revenue_by_dow
      # Usar últimas 8 semanas para patrón más robusto
      data   = Order.where(status: 1, created_at: 8.weeks.ago..Time.current)
                    .group(local_dow_expr)
                    .sum(:monto_pagado)
      labels = DAYS_ES
      values = (0..6).map { |d| data[d]&.to_f || 0.0 }
      { labels: labels, values: values }
    end

    def by_category
      data = closed_items_scope
               .joins(:product)
               .group('products.categoria')
               .sum('order_items.cantidad * order_items.precio_unitario')
               .sort_by { |_, v| -v }
      { labels: data.map(&:first), values: data.map { |_, v| v.to_f } }
    end

    def by_servicio
      map  = { 'mesa' => 'En Mesa', 'llevar' => 'Para Llevar', 'domicilio' => 'Domicilio' }
      data = closed_orders.group(:tipo_servicio).count
      { labels: data.keys.map { |k| map[k] || k.to_s.capitalize }, values: data.values }
    end

    def by_pago
      map  = { 'efectivo' => 'Efectivo', 'transferencia' => 'Transferencia' }
      data = closed_orders.group(:tipo_pago).sum(:monto_pagado)
      { labels: data.keys.map { |k| map[k] || k.to_s.capitalize },
        values: data.map { |_, v| v.to_f } }
    end

    # ─── Tables ───────────────────────────────────────────────────────────────

    def tables
      { top_products: top_products, by_mesero: by_mesero }
    end

    def top_products
      closed_items_scope
        .joins(:product)
        .group('products.id', 'products.nombre', 'products.categoria')
        .select(
          'products.nombre      AS nombre',
          'products.categoria   AS categoria',
          'SUM(order_items.cantidad) AS total_cantidad',
          'SUM(order_items.cantidad * order_items.precio_unitario) AS total_revenue'
        )
        .order('total_revenue DESC')
        .limit(10)
        .map do |r|
          { nombre:    r.nombre,
            categoria: r.categoria,
            cantidad:  r.total_cantidad.to_i,
            revenue:   r.total_revenue.to_f }
        end
    end

    def by_mesero
      closed_orders
        .group(:mesero)
        .select(
          :mesero,
          'COUNT(*)          AS orders_count',
          'SUM(monto_pagado) AS total_revenue',
          'AVG(monto_pagado) AS avg_ticket'
        )
        .order('total_revenue DESC')
        .map do |r|
          { mesero:  r.mesero.presence || 'Sin asignar',
            orders:  r.orders_count.to_i,
            revenue: r.total_revenue.to_f,
            avg:     r.avg_ticket.to_f }
        end
    end

    # ─── Helpers ──────────────────────────────────────────────────────────────

    def growth(current, prev)
      return 0.0 if prev.nil? || prev.zero?
      ((current.to_f - prev.to_f) / prev.to_f * 100).round(1)
    end

    # SQLite datetime expressions converting UTC → localtime
    def local_date_expr
      "DATE(datetime(created_at, 'localtime'))"
    end

    def local_hour_expr
      "CAST(STRFTIME('%H', datetime(created_at, 'localtime')) AS INTEGER)"
    end

    def local_month_expr
      "STRFTIME('%m', datetime(created_at, 'localtime'))"
    end

    def local_dow_expr
      "CAST(STRFTIME('%w', datetime(created_at, 'localtime')) AS INTEGER)"
    end
  end
end
