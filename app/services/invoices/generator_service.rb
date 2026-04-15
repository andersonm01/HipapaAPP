module Invoices
  class GeneratorService
    def initialize(order)
      @order = order
    end

    def call
      return @order.invoice if @order.invoice.present?

      Invoice.create!(
        order:    @order,
        customer: @order.customer,
        numero:   Invoice.next_number,
        subtotal: @order.total_calculado,
        total:    @order.total_calculado,
        estado:   'emitida'
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("[Invoices::Generator] Error: #{e.message}")
      nil
    end
  end
end
