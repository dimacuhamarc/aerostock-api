class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!, unless: :devise_controller?  # Ensures the user is authenticated before accessing any actions

  include RackSessionsFix

  respond_to :json

  protected

  # Modify the behavior of Devise to permit extra parameters for sign up and account updates
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar])
  end

  private

  # Overwrite authenticate_user! to handle JWT authentication
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token
      begin
        # Decode the JWT token using the secret key
        decoded_token = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!).first
        user_id = decoded_token['user_id']
        @current_user = User.find_by(id: user_id)
        
        # If the user cannot be found or token is invalid, deny access
        if @current_user.nil?
          render json: { error: 'Unauthorized access' }, status: :unauthorized
        end
      rescue JWT::DecodeError
        render json: { error: 'Invalid or expired token' }, status: :unauthorized
      end
    else
      # If no token is provided in the request header
      render json: { error: 'Missing token' }, status: :unauthorized
    end
  end
end
