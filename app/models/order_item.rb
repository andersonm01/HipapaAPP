class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  has_many :order_item_sauces, dependent: :destroy
  has_many :sauces, through: :order_item_sauces

  validates :cantidad,        presence: true, numericality: { greater_than: 0 }
  validates :precio_unitario, presence: true, numericality: { greater_than: 0 }

  def subtotal
    cantidad * precio_unitario
  end
end
