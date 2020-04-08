class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.secrets.default_mail
  layout 'mailer'
end
