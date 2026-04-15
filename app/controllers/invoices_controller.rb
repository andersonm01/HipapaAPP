class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :print, :void]

  def index
    @invoices = Invoice.includes(:order, :customer).order(created_at: :desc)
    @invoices = @invoices.where(created_at: Date.parse(params[:fecha]).all_day) if params[:fecha].present?
  end

  def show; end

  def print
    render layout: 'print'
  end

  def void
    @invoice.update!(estado: 'anulada')
    redirect_to invoice_path(@invoice), notice: "Factura #{@invoice.numero} anulada."
  end

  private

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end
end
