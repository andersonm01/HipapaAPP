module Reports
  # Tendencia de ventas por bucket (día/semana/mes) con crecimiento % y media
  # móvil calculados en SQL vía CTE + window functions (LAG/AVG OVER), no en
  # Ruby. `relation` debe ser un scope de Order ya filtrado (closed + ransack).
  class TrendQuery
    include Reports::SqlTimeExpressions

    MOVING_AVG_WINDOW = { 'day' => 7, 'week' => 4, 'month' => 3 }.freeze

    def initialize(relation:, granularity: 'day', moving_avg_window: nil)
      @granularity = granularity.to_s
      raise ArgumentError, "Granularidad no soportada: #{granularity}" unless GRANULARITIES.include?(@granularity)

      @window = Integer(moving_avg_window || MOVING_AVG_WINDOW.fetch(@granularity))
      raise ArgumentError, "moving_avg_window debe ser >= 1" unless @window >= 1

      # .reorder(nil) descarta cualquier ORDER BY heredado (irrelevante dentro
      # del CTE); el SELECT explícito evita arrastrar columnas de más.
      @relation = relation.reorder(nil).select(:id, :monto_pagado, :created_at)
    end

    def call
      ActiveRecord::Base.connection.exec_query(sql, 'Reports::TrendQuery').to_a.map { |row| coerce(row) }
    end

    private

    def sql
      <<~SQL
        WITH filtered_orders AS (
          #{@relation.to_sql}
        ),
        bucketed AS (
          SELECT
            #{bucket_expr(@granularity, 'created_at')} AS bucket,
            SUM(monto_pagado) AS revenue,
            COUNT(*) AS orders_count
          FROM filtered_orders
          GROUP BY 1
        ),
        windowed AS (
          SELECT
            bucket, revenue, orders_count,
            LAG(revenue) OVER (ORDER BY bucket) AS revenue_prev_period,
            AVG(revenue) OVER (ORDER BY bucket ROWS BETWEEN #{@window - 1} PRECEDING AND CURRENT ROW) AS moving_avg
          FROM bucketed
        )
        SELECT
          bucket,
          revenue,
          orders_count,
          CASE WHEN orders_count = 0 THEN 0 ELSE ROUND(revenue * 1.0 / orders_count, 2) END AS avg_ticket,
          revenue_prev_period,
          CASE
            WHEN revenue_prev_period IS NULL OR revenue_prev_period = 0 THEN NULL
            ELSE ROUND((revenue - revenue_prev_period) * 100.0 / revenue_prev_period, 2)
          END AS pct_growth,
          ROUND(moving_avg, 2) AS moving_avg
        FROM windowed
        ORDER BY bucket
      SQL
    end

    def coerce(row)
      {
        bucket:              row['bucket'],
        revenue:             row['revenue'].to_f,
        orders_count:        row['orders_count'].to_i,
        avg_ticket:          row['avg_ticket'].to_f,
        revenue_prev_period: row['revenue_prev_period']&.to_f,
        pct_growth:          row['pct_growth']&.to_f,
        moving_avg:          row['moving_avg']&.to_f
      }
    end
  end
end
