require 'csv'

module Api
  module V1
    class ReportsController < BaseController
      before_action :require_admin_or_supervisor_json

      GRANULARITIES  = %w[day week month].freeze
      MAX_PER_PAGE    = 100
      DEFAULT_PER_PAGE = 25
      CSV_ROW_LIMIT   = 5000

      def summary
        data = Reports::SummaryQuery.new(orders: base_orders, prev_orders: prev_orders, items: base_items).call
        data[:insights] = build_insights(data)
        data[:meta] = { period: filter_params.period, from: filter_params.from, to: filter_params.to }
        render json: data
      end

      def trend
        granularity = GRANULARITIES.include?(params[:granularity]) ? params[:granularity] : 'day'
        data = Reports::TrendQuery.new(relation: base_orders, granularity: granularity).call
        render json: { granularity: granularity, data: data, meta: { from: filter_params.from, to: filter_params.to } }
      rescue ArgumentError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      def orders
        page     = [params[:page].to_i, 1].max
        per_page = params[:per_page].presence ? [[params[:per_page].to_i, 1].max, MAX_PER_PAGE].min : DEFAULT_PER_PAGE
        total    = base_orders.count

        rows = base_orders.order(created_at: :desc)
                           .limit(per_page)
                           .offset((page - 1) * per_page)
                           .select(:id, :numero_orden, :cliente, :mesero, :tipo_servicio, :tipo_pago, :monto_pagado, :created_at)

        render json: {
          data: rows.map { |o| serialize_order(o) },
          meta: { page: page, per_page: per_page, total: total, total_pages: total.zero? ? 0 : (total.to_f / per_page).ceil }
        }
      end

      def orders_csv
        rows = base_orders.order(created_at: :desc).limit(CSV_ROW_LIMIT)

        csv = CSV.generate(headers: true) do |out|
          out << ['Número', 'Cliente', 'Mesero', 'Servicio', 'Pago', 'Total', 'Fecha']
          rows.each do |o|
            out << [o.numero_orden, o.cliente, o.mesero, o.tipo_servicio, o.tipo_pago, o.monto_pagado, o.created_at.strftime('%d/%m/%Y %H:%M')]
          end
        end

        send_data csv, filename: "reporte_ventas_#{Date.current}.csv", type: 'text/csv'
      end

      private

      def filter_params
        @filter_params ||= Reports::FilterParams.new(params)
      end

      # Ransack filtra vía JOIN sobre order_items/product (para mesero+
      # categoría/producto a la vez), lo que puede duplicar filas de Order
      # por cada ítem que matchea. `.result(distinct: true)` "arregla" el
      # count pero rompe `.sum(:columna)` (Rails genera SUM(DISTINCT columna),
      # que descarta pagos con el mismo monto). En vez de eso, resolvemos los
      # ids ya deduplicados con Ransack y armamos un scope plano sin joins
      # para los cálculos de columna posteriores.
      def base_orders
        @base_orders ||= Order.where(id: Order.ransack(filter_params.order_ransack_params).result.select(:id))
      end

      def prev_orders
        @prev_orders ||= Order.where(
          id: Order.ransack(
            filter_params.order_ransack_params(from: filter_params.prev_from, to: filter_params.prev_to)
          ).result.select(:id)
        )
      end

      # OrderItem → :order y :product son belongs_to (1:1), así que filtrar
      # por esas asociaciones nunca duplica filas — no hace falta distinct.
      def base_items
        @base_items ||= OrderItem.ransack(filter_params.item_ransack_params).result
      end

      def serialize_order(o)
        {
          id:            o.id,
          numero_orden:  o.numero_orden,
          cliente:       o.cliente,
          mesero:        o.mesero,
          tipo_servicio: o.tipo_servicio,
          tipo_pago:     o.tipo_pago,
          monto_pagado:  o.monto_pagado.to_f,
          created_at:    o.created_at.strftime('%d/%m/%Y %H:%M')
        }
      end

      # Reusa Reports::InsightsService (ya probado) armando el shape de
      # "metrics" que espera, a partir de los datos ya calculados en
      # SummaryQuery más una tendencia diaria auxiliar (para la predicción).
      def build_insights(summary_data)
        trend = Reports::TrendQuery.new(relation: base_orders, granularity: 'day').call
        hours = Array.new(24, 0.0)
        dows  = Array.new(7, 0.0)
        summary_data[:heatmap].each do |cell|
          hours[cell[:hour]] += cell[:revenue]
          dows[cell[:dow]]   += cell[:revenue]
        end

        metrics = {
          kpis: summary_data[:kpis],
          charts: {
            revenue_trend:   { labels: trend.map { |t| t[:bucket] }, values: trend.map { |t| t[:revenue] } },
            revenue_by_hour: { labels: (0..23).map { |h| "#{h.to_s.rjust(2, '0')}:00" }, values: hours },
            revenue_by_dow:  { labels: Reports::MetricsService::DAYS_ES, values: dows },
            by_category:     summary_data[:by_category],
            by_servicio:     summary_data[:by_servicio],
            by_pago:         summary_data[:by_pago]
          },
          tables: {
            top_products: summary_data[:top_products],
            by_mesero:    summary_data[:sellers]
          }
        }

        Reports::InsightsService.new(metrics).call.sort_by { |i| i[:priority] }
      rescue StandardError => e
        Rails.logger.error("Reports insights error: #{e.class}: #{e.message}")
        []
      end
    end
  end
end
