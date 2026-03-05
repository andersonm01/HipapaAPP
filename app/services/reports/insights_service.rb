module Reports
  # Genera insights automáticos en español a partir de las métricas calculadas.
  # Usa análisis estadístico básico (tendencia lineal, comparaciones, patrones).
  class InsightsService
    DAYS_ES = %w[domingos lunes martes miércoles jueves viernes sábados].freeze

    def initialize(metrics)
      @metrics = metrics
      @kpis    = metrics[:kpis]
      @charts  = metrics[:charts]
      @tables  = metrics[:tables]
    end

    def call
      [
        *revenue_insight,
        *orders_insight,
        *dow_insights,
        *peak_hour_insight,
        *product_insights,
        *payment_insight,
        *service_insight,
        *prediction_insight
      ].compact
    end

    private

    # ─── Revenue vs periodo anterior ─────────────────────────────────────────

    def revenue_insight
      r = @kpis[:revenue]
      return [] if r[:prev].zero? || r[:growth].zero?

      dir  = r[:growth] > 0 ? 'aumentó' : 'disminuyó'
      type = r[:growth] > 0 ? 'success' : 'danger'
      emoji = r[:growth] > 0 ? '📈' : '📉'

      [{ text:     "#{emoji} La facturación <strong>#{dir} un #{r[:growth].abs}%</strong> " \
                   "respecto al período anterior " \
                   "(#{fmt(r[:prev])} → #{fmt(r[:value])})",
         type:     type,
         priority: 1 }]
    end

    # ─── Cantidad de pedidos ──────────────────────────────────────────────────

    def orders_insight
      o = @kpis[:orders]
      return [] if o[:prev].zero? || o[:growth].zero?

      dir  = o[:growth] > 0 ? 'aumentó' : 'disminuyó'
      type = o[:growth] > 0 ? 'success' : 'warning'

      [{ text:     "🧾 El número de pedidos <strong>#{dir} un #{o[:growth].abs}%</strong> " \
                   "(#{o[:prev]} → #{o[:value]} pedidos)",
         type:     type,
         priority: 2 }]
    end

    # ─── Día de la semana ─────────────────────────────────────────────────────

    def dow_insights
      dow = @charts[:revenue_by_dow]
      return [] unless dow && dow[:values].any? { |v| v > 0 }

      nonzero = dow[:values].each_with_index.select { |v, _| v > 0 }
      return [] if nonzero.size < 2

      _max_val, max_idx = nonzero.max_by { |v, _| v }
      min_val, min_idx  = nonzero.min_by { |v, _| v }

      insights = [
        { text:     "⭐ Los <strong>#{DAYS_ES[max_idx]}</strong> son el día de mayor venta " \
                    "(últimas 8 semanas) — asegura personal y stock suficiente",
          type:     'info',
          priority: 3 }
      ]

      if nonzero.size > 2 && min_val < dow[:values].sum / dow[:values].count.to_f * 0.6
        insights << {
          text:     "💡 Los <strong>#{DAYS_ES[min_idx]}</strong> tienen bajo volumen de ventas " \
                    "(#{fmt(min_val)}) — oportunidad para promociones o descuentos",
          type:     'warning',
          priority: 4
        }
      end

      insights
    end

    # ─── Hora pico ────────────────────────────────────────────────────────────

    def peak_hour_insight
      hours = @charts[:revenue_by_hour]
      return [] unless hours && hours[:values].any? { |v| v > 0 }

      peak_val, peak_h = hours[:values].each_with_index.max_by { |v, _| v }
      return [] unless peak_val&.positive?

      [{ text:     "🕐 La hora pico de ventas es a las <strong>#{peak_h.to_s.rjust(2, '0')}:00</strong> " \
                   "(#{fmt(peak_val)}) — optimiza cobertura en ese rango horario",
         type:     'info',
         priority: 5 }]
    end

    # ─── Productos ───────────────────────────────────────────────────────────

    def product_insights
      top = @tables[:top_products]
      return [] unless top&.any?

      total_rev = @kpis[:revenue][:value]
      insights  = []

      best = top.first
      pct  = total_rev > 0 ? (best[:revenue] / total_rev * 100).round(1) : 0

      insights << {
        text:     "🏆 \"<strong>#{best[:nombre]}</strong>\" es el producto estrella del período " \
                  "con #{fmt(best[:revenue])} en ventas (#{pct}% del total)",
        type:     'success',
        priority: 6
      }

      cat = @charts[:by_category]
      if cat && cat[:labels].any?
        insights << {
          text:     "📦 La categoría \"<strong>#{cat[:labels].first}</strong>\" lidera con " \
                    "#{fmt(cat[:values].first)} — prioriza inventario de esa línea",
          type:     'info',
          priority: 7
        }
      end

      insights
    end

    # ─── Método de pago ───────────────────────────────────────────────────────

    def payment_insight
      pago  = @charts[:by_pago]
      return [] unless pago && pago[:values].any?

      total = pago[:values].sum.to_f
      return [] if total.zero?

      ef_idx = pago[:labels].index('Efectivo')
      return [] unless ef_idx

      ef_pct = (pago[:values][ef_idx] / total * 100).round(1)
      tf_pct = (100 - ef_pct).round(1)

      if ef_pct > 80
        [{ text:  "💳 El <strong>#{ef_pct}%</strong> de los pagos son en efectivo — " \
                  "considera promover transferencias para reducir manejo de dinero físico",
           type: 'warning', priority: 8 }]
      else
        [{ text:  "💳 Buena distribución de medios de pago: " \
                  "<strong>#{ef_pct}%</strong> efectivo / <strong>#{tf_pct}%</strong> transferencia",
           type: 'info', priority: 8 }]
      end
    end

    # ─── Tipo de servicio ─────────────────────────────────────────────────────

    def service_insight
      serv  = @charts[:by_servicio]
      return [] unless serv && serv[:values].any?

      total = serv[:values].sum.to_f
      return [] if total.zero?

      max_val, max_idx = serv[:values].each_with_index.max_by { |v, _| v }
      return [] unless max_idx

      pct = (max_val / total * 100).round(1)

      [{ text:     "🍽️ El servicio \"<strong>#{serv[:labels][max_idx]}</strong>\" representa el " \
                   "<strong>#{pct}%</strong> de los pedidos del período",
         type:     'info',
         priority: 9 }]
    end

    # ─── Predicción simple (regresión lineal) ────────────────────────────────

    def prediction_insight
      trend = @charts[:revenue_trend]
      return [] unless trend

      values = trend[:values].select { |v| v > 0 }
      return [] if values.size < 4

      slope = linear_slope(values)
      avg   = values.sum / values.size.to_f
      pred  = [avg + slope * values.size, 0].max

      dir  = slope > 0 ? '📈 al alza' : '📉 a la baja'
      type = slope > 0 ? 'primary' : 'warning'

      [{ text:     "🔮 La tendencia va <strong>#{dir}</strong>. " \
                   "Proyección para el siguiente período: ~<strong>#{fmt(pred)}</strong>",
         type:     type,
         priority: 10 }]
    end

    # ─── Utilidades ──────────────────────────────────────────────────────────

    def linear_slope(values)
      n      = values.size
      return 0.0 if n < 2

      x_mean = (n - 1) / 2.0
      y_mean = values.sum / n.to_f
      num    = values.each_with_index.sum { |y, x| (x - x_mean) * (y - y_mean) }
      den    = values.each_with_index.sum { |_, x| (x - x_mean)**2 }

      den.zero? ? 0.0 : num / den
    end

    def fmt(val)
      "$#{format('%.2f', val.to_f)}"
    end
  end
end
