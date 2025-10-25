module Api::V1::AuthParams
  extend ActiveSupport::Concern

  private

  def auth_user_params(required_attrs = [])
    params_slice = params[:user] || {}  # Normalize: pull from wrapper or flat fallback
    permitted = [ :email, :username, :password, :password_confirmation, :token ]
    permitted += required_attrs  # e.g., for reset: [:email] already covered

    # Device fields top-level
    device_id = params[:device_id] || SecureRandom.uuid
    device_name = params[:device_name]

    # Build normalized hash
    {
      user: params_slice.permit(*permitted),
      device_id: device_id,
      device_name: device_name
    }
  end
end
