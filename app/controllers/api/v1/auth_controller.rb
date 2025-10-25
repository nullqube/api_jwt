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
          }
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
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
