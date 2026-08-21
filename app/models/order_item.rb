class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :cantidad,        presence: true, numericality: { greater_than: 0 }
  validates :precio_unitario, presence: true, numericality: { greater_than: 0 }

  def subtotal
    cantidad * precio_unitario
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[cantidad precio_unitario product_id order_id created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[order product]
  end
end
