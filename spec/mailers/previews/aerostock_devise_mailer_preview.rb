# frozen_string_literal: true

class AerostockDeviseMailerPreview < ActionMailer::Preview
  include SecureRandom
  def welcome_email
    user = User.first
    AerostockDeviseMailer.welcome_email(user)
  end

  def reset_password_instructions
    token = "fake_token"
    user = User.first
    AerostockDeviseMailer.reset_password_instructions(user, token)
  end

  def send_password_change_notification
    token = "fake_token"
    user = User.first
    AerostockDeviseMailer.send_password_change_notification(user, token)
  end

  def send_otp
    user = User.last
    otp = rand.to_s[2..7]
    OtpMailer.send_otp(user, otp)
  end
end