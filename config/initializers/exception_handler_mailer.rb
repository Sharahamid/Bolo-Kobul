# The error-alert emails come from the exception_handler gem's own mailer, which has no
# sender set, so every alert failed with "SMTP From address may not be blank".
# Give it the same sender as all other Bolo Kobul emails.
Rails.application.config.to_prepare do
  ExceptionHandler::ExceptionMailer.default from: ApplicationMailer::SENDER if defined?(ExceptionHandler::ExceptionMailer)
end
