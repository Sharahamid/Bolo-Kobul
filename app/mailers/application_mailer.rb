class ApplicationMailer < ActionMailer::Base
  default from: 'BoloKobul <noreply@bolokobul.com>'
  layout 'mailer'
  helper EmailHelper
end
