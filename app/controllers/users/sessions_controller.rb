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
      render json: { message: 'OTP sent successfully', user: user.email, uid: user.id}, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def verify_otp
    user = User.find_by(id: params[:user_id])
    Rails.logger.debug "User ID: #{params[:user_id]}, OTP: #{params[:otp]}"
    if user
      Rails.logger.debug "Verifying OTP for User ID: #{user.id}, OTP: #{user.otp}, Sent At: #{user.otp_sent_at}, Current Time: #{Time.current}"
  
      if user.otp == params[:otp] && user.otp_sent_at > 10.minutes.ago
        # Clear OTP after successful verification
        user.update(otp: nil, otp_sent_at: nil)
  
        # Automatically sign in the user with Devise
        sign_in(user)
  
        # Generate JWT token
        token = user.generate_jwt_token
  
        # Respond with JWT token
        render json: { token: "Bearer #{token}", message: 'OTP verified and logged in successfully' }, status: :ok
      else
        render json: { error: 'Invalid or expired OTP' }, status: :unauthorized
      end
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end
  
  

  private

  def respond_to_on_destroy
    if request.headers['Authorization'].present?
      token = request.headers['Authorization']&.split(' ')&.last

      begin
        jwt_payload = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!).first # Decode the token
        user_id = jwt_payload['user_id']
        @current_user = User.find_by(id: user_id)

        Rails.logger.debug "Logging out user: #{current_user.email}" # Log the email of the logged-out user
        sign_out(current_user) # Devise sign-out§
        render json: { status: 200, message: 'Logged out successfully.' }, status: :ok
      rescue JWT::DecodeError
        render json: { status: 401, message: 'Invalid token' }, status: :unauthorized
      end
    else
      # Log the actual content of the Authorization header for debugging purposes
      Rails.logger.error "Expected Authorization header to be a String but got: #{request.headers['Authorization'].inspect}"
      render json: { status: 401, message: "Invalid Authorization header." }, status: :unauthorized
    end
  end
  
  
  

  def send_otp(user)
    Rails.logger.debug "Sending OTP to: #{user.email}" # Log the email being used
    otp = SecureRandom.random_number(10**6).to_s.rjust(6, '0')
  
    user.update(otp: otp, otp_sent_at: Time.current)
  
    OtpMailer.send_otp(user, otp).deliver_now
  end
end
