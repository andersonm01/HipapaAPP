module Reports
  # Traduce los params "amigables" que manda el frontend (period preset o
  # from/to, mesero, tipo_servicio, tipo_pago, user_id, categoria,
  # product_id) a los hashes de predicados que necesita Ransack, tanto a
  # nivel de Order (KPIs, tendencia, tabla de detalle, vendedores, heatmap)
  # como a nivel de OrderItem (top productos, ventas por categoría).
  class FilterParams
    PRESETS = %w[today last_7_days month quarter year custom].freeze

    attr_reader :from, :to, :period

    def initialize(params)
      @period = PRESETS.include?(params[:period].to_s) ? params[:period].to_s : 'month'
      @from, @to = resolve_range(params)

      @mesero         = params[:mesero].presence
      @tipo_servicio  = params[:tipo_servicio].presence
      @tipo_pago      = params[:tipo_pago].presence
      @user_id        = params[:user_id].presence
      @categoria      = params[:categoria].presence
      @product_id     = params[:product_id].presence
    end

    def prev_from
      @from - (@to - @from) - 1.second
    end

    def prev_to
      @from - 1.second
    end

    # Ransack contra Order: KPIs, tendencia, tabla de detalle, vendedores, heatmap.
    def order_ransack_params(from: @from, to: @to)
      q = { created_at_gteq: from, created_at_lteq: to, status_eq: Order::STATUS_CLOSED }
      q[:mesero_eq]                        = @mesero        if @mesero
      q[:tipo_servicio_eq]                 = @tipo_servicio if @tipo_servicio
      q[:tipo_pago_eq]                     = @tipo_pago     if @tipo_pago
      q[:user_id_eq]                       = @user_id       if @user_id
      q[:order_items_product_id_eq]        = @product_id    if @product_id
      q[:order_items_product_categoria_eq] = @categoria     if @categoria
      q
    end

    # Ransack contra OrderItem: top productos, ventas por categoría — así el
    # filtro de categoría/producto restringe los ÍTEMS que cuentan, no solo
    # "órdenes que contienen al menos un ítem que matchea".
    def item_ransack_params
      q = { order_created_at_gteq: @from, order_created_at_lteq: @to, order_status_eq: Order::STATUS_CLOSED }
      q[:order_mesero_eq]        = @mesero        if @mesero
      q[:order_tipo_servicio_eq] = @tipo_servicio if @tipo_servicio
      q[:order_tipo_pago_eq]     = @tipo_pago     if @tipo_pago
      q[:order_user_id_eq]       = @user_id       if @user_id
      q[:product_id_eq]          = @product_id    if @product_id
      q[:product_categoria_eq]   = @categoria     if @categoria
      q
    end

    private

    def resolve_range(params)
      if @period == 'custom'
        parsed = parse_custom(params[:from], params[:to])
        return parsed if parsed
      end

      case @period
      when 'today'       then [Time.current.beginning_of_day, Time.current.end_of_day]
      when 'last_7_days'  then [6.days.ago.beginning_of_day, Time.current.end_of_day]
      when 'quarter'      then [3.months.ago.beginning_of_day, Time.current.end_of_day]
      when 'year'         then [Time.current.beginning_of_year, Time.current.end_of_year]
      else                     [Time.current.beginning_of_month, Time.current.end_of_month]
      end
    end

    def parse_custom(from, to)
      return nil if from.blank? || to.blank?

      [from.to_date.beginning_of_day, to.to_date.end_of_day]
    rescue ArgumentError, TypeError
      nil
    end
  end
end
