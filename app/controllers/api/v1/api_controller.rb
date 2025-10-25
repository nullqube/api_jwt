class Api::V1::ApiBaseController < ActionController::API
  before_action :authenticate_user!

  rescue_from JwtService::TokenExpiredError, with: :handle_expired_token
  rescue_from JwtService::InvalidTokenError, with: :handle_invalid_token

  private

  def authenticate_user!
    token = extract_token_from_header

    unless token
      return render json: { error: "Authorization token required" }, status: :unauthorized
    end

    user_id = JwtService.validate_access_token(token)
    @current_user = User.find_by(id: user_id)

    unless @current_user
      render json: { error: "User not found" }, status: :unauthorized
    end
  rescue JwtService::TokenExpiredError, JwtService::InvalidTokenError => e
    raise e
  end

  def current_user
    @current_user
  end

  def extract_token_from_header
    auth_header = request.headers["Authorization"]
    return nil unless auth_header

    # Expected format: "Bearer <token>"
    auth_header.split(" ").last if auth_header.start_with?("Bearer ")
  end

  def handle_expired_token
    render json: {
      error: "Token expired",
      code: "TOKEN_EXPIRED"
    }, status: :unauthorized
  end

  def handle_invalid_token
    render json: {
      error: "Invalid token",
      code: "INVALID_TOKEN"
    }, status: :unauthorized
  end
end
