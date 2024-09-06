# frozen_string_literal: true

class AerostockDeviseMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  layout "main_layout_v1"

  default from: "no-reply@aerostock.app", template_path: 'devise/mailer'

  DEFAULT_EMAIL = "no-reply@aerostock.app"

  def reset_password_instructions(record, token, opts = {})
    @first_name = record.first_name
    opts[:subject] = "Hello #{@first_name}! Here's your password reset instructions."
    opts[:from] = DEFAULT_EMAIL
    opts[:reply_to] = ''
    super
  end

  def send_password_change_notification(record, token, opts = {})
    @first_name = record.first_name
    subject = "Hello #{@first_name}! Here's your password reset instructions."

    mail(
      to: record.email, 
      subject: subject, 
      from: DEFAULT_EMAIL, 
      template_path: 'devise/mailer', 
      template_name: 'password_change'
    )
  end

  def welcome_email(record, opts = {})
    user = record
    @first_name = user.first_name
    subject = "Hi #{@first_name}! Welcome to Aerostock App."

    mail(
      to: record.email, 
      subject: subject, 
      from: DEFAULT_EMAIL, 
      template_path: 'devise/mailer', 
      template_name: 'welcome_email'
    )
  end
end