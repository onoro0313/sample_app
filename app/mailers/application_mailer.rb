class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@example.com'
  # 送り主
  layout 'mailer'
end
