class JsonWebToken
  # Secret key for JWT encoding/decoding
  # In production, this should be stored in Rails credentials or ENV
  SECRET_KEY = Rails.application.credentials.secret_key_base || ENV['JWT_SECRET']

  # Encode a payload into a JWT token
  # @param payload [Hash] The data to encode
  # @param exp [Time] Expiration time (default: 24 hours from now)
  # @return [String] The encoded JWT token
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  # Decode a JWT token
  # @param token [String] The JWT token to decode
  # @return [HashWithIndifferentAccess, nil] The decoded payload or nil if invalid
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    Rails.logger.error("JWT Decode Error: #{e.message}")
    nil
  end
end
