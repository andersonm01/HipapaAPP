class CocinaController < ApplicationController
  def index
    @orders = Order.for_kitchen
  end
end
