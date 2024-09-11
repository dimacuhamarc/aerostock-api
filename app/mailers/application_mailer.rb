class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@aerostock.app", mailer_sender: "no-reply@aerostock.app"
  layout "mailer"
end
