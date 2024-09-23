class OtpMailer < ApplicationMailer
  layout "main_layout_v1"

  def send_otp(user, otp)
    @otp = otp
    @first_name = user.first_name
    mail(
      to: user.email, 
      subject: 'ALERT: Your One-time Password',
      template_path: 'mailers',
      template_name: 'otp'
    )
  end
end