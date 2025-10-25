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

# ##################
# for when using microservice and need to verify token issued by another service
# then we switch from HS256 to RS256 and use public/private key pair
# ##################
# class JwtService
#   SECRET_KEY = "shared_secret_key_between_services"
#   ALGORITHM = "HS256"
#   class << self
#   def decode(token)
#       decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
#       decoded[0].with_indifferent_access
#     rescue JWT::ExpiredSignature
#       raise TokenExpiredError, "Token has expired"
#     rescue JWT::DecodeError => e
#       raise InvalidTokenError, "Invalid token: #{e.message}"
#     end
#   end
#   class TokenExpiredError < StandardError; end
#   class InvalidTokenError < StandardError; end
# end
# ##################
# end of microservice example
# ##################
#
#
# class JwtService
#   def self.encode(payload, exp: 15.minutes.from_now)
#     payload[:exp] = exp.to_i
#     private_key.sign(
#       OpenSSL::Algorithm::RSA_SHA256.new,
#       payload.to_json
#     ).to_s
#   end

#   def self.decode(token)
#     public_key.verify(
#       OpenSSL::Algorithm::RSA_SHA256.new,
#       token
#     )
#     payload = JSON.parse(public_key.verify(...))  # Simplified; use full JWT lib
#     JWT.decode(token, public_key, true, algorithm: 'RS256').first
#   rescue JWT::DecodeError
#     nil
#   end

#   private

#   def self.private_key
#     OpenSSL::PKey::RSA.new(Rails.application.credentials.dig(:jwt, :private_key))
#   end

#   def self.public_key
#     OpenSSL::PKey::RSA.new(Rails.application.credentials.dig(:jwt, :public_key))
#   end
# end
