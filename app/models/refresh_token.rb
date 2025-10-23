class RefreshToken < ApplicationRecord
  belongs_to :user

  # Validations
  validates :token, presence: true, uniqueness: true
  validates :device_id, presence: true
  validates :expires_at, presence: true

  # Scopes
  scope :active, -> { where(revoked: false).where("expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }
  scope :revoked, -> { where(revoked: true) }

  # Callbacks
  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create

  # Class Methods
  def self.cleanup_expired!
    expired.delete_all
  end

  # Instance Methods

  # Revoke this refresh token
  def revoke!
    update(revoked: true)
  end

  # Check if the token is active (not revoked and not expired)
  def active?
    !revoked && expires_at > Time.current
  end

  # Update the last used timestamp
  def touch_last_used!
    update(last_used_at: Time.current)
  end

  private

  # Generate a unique token
  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  # Set default expiration (e.g., 30 days from now)
  def set_expiration
    self.expires_at ||= 30.days.from_now
  end
end
