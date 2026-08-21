module Reports
  # Expresiones SQL para convertir columnas de fecha (guardadas en UTC) a hora
  # local y agruparlas por día/semana/mes/hora/día-de-semana, con sintaxis
  # distinta según el adaptador (SQLite en dev, PostgreSQL en prod).
  module SqlTimeExpressions
    GRANULARITIES = %w[day week month].freeze

    def postgres?
      ActiveRecord::Base.connection.adapter_name.match?(/postg/i)
    end

    def local_time_expr(column = 'created_at')
      # PostgreSQL necesita el identificador IANA (America/Bogota), no el
      # nombre amigable de ActiveSupport::TimeZone (Bogota).
      tz_name = ActiveSupport::TimeZone[Rails.application.config.time_zone].tzinfo.name
      "(#{column} AT TIME ZONE 'UTC' AT TIME ZONE '#{tz_name}')"
    end

    def local_date_expr(column = 'created_at')
      postgres? ? "DATE#{local_time_expr(column)}" : "DATE(datetime(#{column}, 'localtime'))"
    end

    def local_hour_expr(column = 'created_at')
      if postgres?
        "CAST(EXTRACT(HOUR FROM #{local_time_expr(column)}) AS INTEGER)"
      else
        "CAST(STRFTIME('%H', datetime(#{column}, 'localtime')) AS INTEGER)"
      end
    end

    def local_month_expr(column = 'created_at')
      if postgres?
        "TO_CHAR(#{local_time_expr(column)}, 'MM')"
      else
        "STRFTIME('%m', datetime(#{column}, 'localtime'))"
      end
    end

    def local_dow_expr(column = 'created_at')
      if postgres?
        "CAST(EXTRACT(DOW FROM #{local_time_expr(column)}) AS INTEGER)"
      else
        "CAST(STRFTIME('%w', datetime(#{column}, 'localtime')) AS INTEGER)"
      end
    end

    # Fecha de inicio del bucket (día/semana/mes) como DATE, misma forma en
    # ambos adaptadores para que ORDER BY / LAG / AVG OVER se comporten igual
    # sin importar la granularidad. Semanas con inicio en lunes.
    def bucket_expr(granularity, column = 'created_at')
      case granularity.to_s
      when 'day'
        local_date_expr(column)
      when 'week'
        if postgres?
          "CAST(DATE_TRUNC('week', #{local_time_expr(column)}) AS DATE)"
        else
          # STRFTIME %w da 0=domingo..6=sábado; (%w + 6) % 7 = días desde el
          # lunes anterior (lunes=0, domingo=6).
          "DATE(#{local_date_expr(column)}, '-' || ((CAST(STRFTIME('%w', datetime(#{column}, 'localtime')) AS INTEGER) + 6) % 7) || ' days')"
        end
      when 'month'
        postgres? ? "CAST(DATE_TRUNC('month', #{local_time_expr(column)}) AS DATE)" : "DATE(#{local_date_expr(column)}, 'start of month')"
      else
        raise ArgumentError, "Granularidad no soportada: #{granularity}"
      end
    end
  end
end
