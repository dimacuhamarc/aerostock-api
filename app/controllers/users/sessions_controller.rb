# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include RackSessionsFix
  respond_to :json

  def create
    user = User.find_by(email: params[:user][:email])
  
    if user && user.valid_password?(params[:user][:password])
      # User is authenticated
      Rails.logger.debug "Logged in user: #{user.email}" # Log the email of the logged-in user
      send_otp(user) # Send OTP to the authenticated user
      render json: { message: 'OTP sent successfully', user: user.email }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
  

  def verify_otp
    user = User.find_by(id: params[:user_id])

    if user && user.otp == params[:otp] && user.otp_sent_at > 10.minutes.ago
      # Clear OTP after successful verification
      user.update(otp: nil, otp_sent_at: nil)

      # Generate JWT token
      token = user.generate_jwt_token

      # Respond with JWT token
      render json: { token: "Bearer #{token}", message: 'OTP verified successfully' }, status: :ok
    else
      render json: { error: 'Invalid or expired OTP' }, status: :unauthorized
    end
  end
  
  private

  def respond_with(current_user, _opts = {})
    render json: {
      status: { 
        code: 200, message: 'Logged in successfully.',
        data: { user: UserSerializer.new(current_user).serializable_hash[:data][:attributes] }
      }
    }, status: :ok
  end

  def respond_to_on_destroy
    if request.headers['Authorization'].present?
      jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last, Rails.application.credentials.devise_jwt_secret_key!).first
      current_user = User.find(jwt_payload['sub'])
    end
    
    if current_user
      render json: {
        status: 200,
        message: 'Logged out successfully.'
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end

  

  def send_otp(user)
    Rails.logger.debug "Sending OTP to: #{user.email}" # Log the email being used
    # Generate a 6-digit OTP
    otp = SecureRandom.random_number(10**6).to_s.rjust(6, '0')
  
    # Store the OTP and the time it was sent in the database
    user.update(otp: otp, otp_sent_at: Time.current)
  
    # Send the OTP to the user's email
    OtpMailer.send_otp(user, otp).deliver_now
  end
  

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
