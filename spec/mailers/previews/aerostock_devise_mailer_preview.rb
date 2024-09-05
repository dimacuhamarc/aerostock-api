# frozen_string_literal: true

class AerostockDeviseMailerPreview < ActionMailer::Preview
  def welcome_email
    user = User.first
    token = "fake_token"
    AerostockDeviseMailer.welcome_email(user, token)
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
end