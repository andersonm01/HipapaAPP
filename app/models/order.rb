class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  
  def total
    order_items.any? ? order_items.sum { |item| item.subtotal } : 0.0
  end
end
