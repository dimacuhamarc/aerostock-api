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
  
      # Automatically sign in the user with Devise
      sign_in(user)
  
      # Generate JWT token
      token = user.generate_jwt_token
  
      # Respond with JWT token
      render json: { token: "Bearer #{token}", message: 'OTP verified and logged in successfully' }, status: :ok
    else
      render json: { error: 'Invalid or expired OTP' }, status: :unauthorized
    end
  end
  

  private

  def respond_to_on_destroy
    if request.headers['Authorization'].present?
      token = request.headers['Authorization'].split(' ').index(1)
      begin
        jwt_payload = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!).first
        current_user = User.find(jwt_payload['sub'])
      rescue JWT::DecodeError
        return render json: { status: 401, message: 'Invalid token' }, status: :unauthorized
      end
    end
    
    if current_user
      # Optionally, perform any clean-up here if needed
      render json: { status: 200, message: 'Logged out successfully.' }, status: :ok
    else
      render json: { status: 401, message: "Couldn't find an active session." }, status: :unauthorized
    end
  end
  

  def send_otp(user)
    Rails.logger.debug "Sending OTP to: #{user.email}" # Log the email being used
    otp = SecureRandom.random_number(10**6).to_s.rjust(6, '0')
  
    user.update(otp: otp, otp_sent_at: Time.current)
  
    OtpMailer.send_otp(user, otp).deliver_now
  end
end
