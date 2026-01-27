class Product < ApplicationRecord
  validates :nombre, presence: true
  validates :precio, presence: true, numericality: { greater_than: 0 }
  validates :categoria, presence: true
  
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
end
