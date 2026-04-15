class BusinessSetting < ApplicationRecord
  has_one_attached :logo

  validates :nombre,           presence: true
  validates :color_primario,   presence: true, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "debe ser un color hex válido (#rrggbb)" }
  validates :color_secundario, presence: true, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "debe ser un color hex válido (#rrggbb)" }
  validates :color_acento,     presence: true, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "debe ser un color hex válido (#rrggbb)" }

  def self.current
    first_or_create!(
      nombre:           'Hi Papa',
      color_primario:   '#f59e0b',
      color_secundario: '#0f172a',
      color_acento:     '#fbbf24'
    )
  end
end
