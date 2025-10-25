class Api::V1::ApiBaseController < ActionController::API
  before_action :authenticate_user!
end
