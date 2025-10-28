class User < ApplicationRecord
  has_secure_password

  has_many :refresh_tokens, dependent: :destroy

  # Validations
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password, length: { minimum: 8 }, if: :password_digest_changed?
  validates :password_reset_token, uniqueness: true, allow_nil: true

  # Callbacks
  before_save :downcase_email

  # Instance Methods
  def active_sessions
    refresh_tokens.where(revoked: false)
                  .where("expires_at > ?", Time.current)
                  .order(last_used_at: :desc)
  end

  def revoke_all_tokens!
    refresh_tokens.update_all(revoked: true)
  end

  def revoke_token!(device_id)
    refresh_tokens.where(device_id: device_id).update_all(revoked: true)
  end

  def generate_password_reset_token
    loop do
      token = SecureRandom.urlsafe_base64(32)
      break token unless User.exists?(password_reset_token: token)
    end

    update!(
      password_reset_token: token,
      password_reset_sent_at: Time.current
    )

    token
  end

  # Check if reset token is valid (1 hour expiry)
  def password_reset_token_valid?
    password_reset_sent_at.present? && password_reset_sent_at > 1.hour.ago
  end

  # Clear after successful password reset
  def clear_password_reset_token
    update!(password_reset_token: nil, password_reset_sent_at: nil)
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def password_required?
    password_digest.blank? || password.present?
  end
end
