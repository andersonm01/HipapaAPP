class Sauce < ApplicationRecord
  has_many :order_item_sauces, dependent: :destroy
  has_many :order_items, through: :order_item_sauces

  validates :nombre, presence: true
  validates :color,  presence: true, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "debe ser un color hex válido" }

  scope :activas,   -> { where(activo: true).order(:posicion, :nombre) }
  scope :ordenadas, -> { order(:posicion, :nombre) }
end
