class User < ApplicationRecord
  has_secure_password validations: false

  ROLES = %w[admin supervisor user].freeze

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: ROLES }
  validates :password, length: { minimum: 6 }, allow_nil: true,
                       if: -> { provider.blank? }
  validates :password, presence: true,
                       if: -> { provider.blank? && password_digest.blank? }

  before_save { self.email = email.downcase }

  def admin?
    role == 'admin'
  end

  def supervisor?
    role == 'supervisor'
  end

  def active?
    active
  end

  def self.from_omniauth(auth)
    find_by(email: auth.info.email.downcase)
  end
end
