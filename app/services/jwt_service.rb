class JwtService
  # rails runner "puts SecureRandom.hex(64)"
  # Generate a secure random key and store it in credentials
  # EDITOR="nano --wait" rails credentials:edit
  # jwt_secret_key: your_generated_key_here
  SECRET_KEY = Rails.application.credentials.jwt_secret_key
  ALGORITHM = "HS256"
  ACCESS_TOKEN_EXPIRATION = 15.minutes

  class << self
    # Encode access token
    def encode_access_token(user_id)
      payload = {
        user_id: user_id,
        exp: ACCESS_TOKEN_EXPIRATION.from_now.to_i,
        iat: Time.current.to_i
      }

      JWT.encode(payload, SECRET_KEY, ALGORITHM)
    end

    # Decode token
    def decode(token)
      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
      decoded[0].with_indifferent_access
    rescue JWT::ExpiredSignature
      raise TokenExpiredError, "Token has expired"
    rescue JWT::DecodeError => e
      raise InvalidTokenError, "Invalid token: #{e.message}"
    end

    # Validate token and return user_id
    def validate_access_token(token)
      payload = decode(token)
      payload[:user_id]
    end
  end

  # Custom Exceptions
  class TokenExpiredError < StandardError; end
  class InvalidTokenError < StandardError; end
end
