class User < ApplicationRecord
  has_secure_password

  has_many :refresh_tokens, dependent: :destroy

  # Validations
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :password, length: { minimum: 8 }, if: :password_digest_changed?
  # TODO: Re-enable password presence validation if needed
  # validates :password, presence: true, if: :password_required?

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

  private

  def downcase_email
    self.email = email.downcase
  end

  def password_required?
    password_digest.blank? || password.present?
  end
end
