class ReportsController < ApplicationController
  before_action :require_admin_or_supervisor
  VALID_PERIODS = %w[today yesterday week last_week month last_month year custom].freeze

  PERIOD_LABELS = {
    'today'      => 'Hoy',
    'yesterday'  => 'Ayer',
    'week'       => 'Esta semana',
    'last_week'  => 'Semana pasada',
    'month'      => 'Este mes',
    'last_month' => 'Mes pasado',
    'year'       => 'Este año',
    'custom'     => 'Período personalizado'
  }.freeze

  def index
    @period       = VALID_PERIODS.include?(params[:period]) ? params[:period] : 'today'
    @period_label = PERIOD_LABELS[@period]
    @from         = params[:from]
    @to           = params[:to]

    @metrics  = Reports::MetricsService.new(period: @period, from: @from, to: @to).call
    @insights = Reports::InsightsService.new(@metrics).call.sort_by { |i| i[:priority] }
  end
end
