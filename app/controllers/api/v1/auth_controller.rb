module Api
  module V1
    class AuthController < APIBaseController
      skip_before_action :authenticate_user!, only: [ :signup, :login, :refresh ]

      # POST /api/v1/auth/signup
      def signup
        user = User.new(signup_params)

        if user.save
          tokens = generate_tokens_for_user(user)
          render json: {
            user: user_json(user),
            **tokens
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: login_params[:email].downcase)

        if user&.authenticate(login_params[:password])
          tokens = generate_tokens_for_user(user)
          render json: {
            user: user_json(user),
            **tokens
          }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      # POST /api/v1/auth/refresh
      def refresh
        refresh_token_string = request.headers["X-Refresh-Token"]

        unless refresh_token_string
          return render json: { error: "Refresh token required" }, status: :unauthorized
        end

        # refresh_token = RefreshToken.find_by(token: refresh_token_string)
        # Use find_by + explicit revoked check in one query
        # Atomic fetch: only active, unrevoked, non-expired tokens
        refresh_token = RefreshToken.where(token: refresh_token_string)
                                    .where(revoked: false)
                                    .where("expires_at > ?", Time.current)
                                    .first

        unless refresh_token&.active?
          Rails.logger.warn "Invalid refresh token used from IP: #{request.remote_ip}"
          return render json: { error: "Invalid or expired refresh token" }, status: :unauthorized
        end

        # Mark as used and revoke in one update
        # Atomic: To avoid a tiny window where last_used_at is
        # updated but revoke! fails, combine them:
        refresh_token.update!(revoked: true, last_used_at: Time.current)

        tokens = generate_tokens_for_user(refresh_token.user)
        render json: tokens
      end

      # DELETE /api/v1/auth/logout
      def logout
        device_id = request.headers["X-Device-Id"]
        if device_id && current_user.refresh_tokens.exists?(device_id: device_id)
          current_user.revoke_token!(device_id)
        end
        head :no_content
      end

      # DELETE /api/v1/auth/logout_all
      def logout_all
        current_user.revoke_all_tokens!
        head :no_content
      end

      # GET /api/v1/auth/me
      def me
        render json: { user: user_json(current_user) }
      end

      # GET /api/v1/auth/sessions
      def sessions
        sessions = current_user.active_sessions.map do |token|
          {
            device_id: token.device_id,
            device_name: token.device_name,
            ip_address: token.ip_address,
            last_used_at: token.last_used_at,
            created_at: token.created_at
          }
        end

        render json: { sessions: sessions }
      end

      private

      def signup_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end

      def login_params
        params.require(:user).permit(:email, :password)
      end

      def generate_device_id
        SecureRandom.uuid
      end

      def generate_tokens_for_user(user)
        access_token = JwtService.encode_access_token(user.id)

        refresh_token = user.refresh_tokens.create!(
          device_id: request.headers["X-Device-Id"] || generate_device_id,
          device_name: request.headers["X-Device-Name"],
          ip_address: request.remote_ip,
          user_agent: request.user_agent
        )

        {
          access_token: access_token,
          refresh_token: refresh_token.token,
          expires_in: JwtService::ACCESS_TOKEN_EXPIRATION.to_i
        }
      end

      def user_json(user)
        {
          id: user.id,
          email: user.email
          # created_at: user.created_at
        }
      end

      # ##################
    end
  end
end
