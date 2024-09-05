class DeviseMailer < Devise::Mailer
  
  def confirmation_instructions(record, token, opts={})
    @token = token
    devise_mail(record, :confirmation_instructions, opts)
  end
  
  private
  
end
