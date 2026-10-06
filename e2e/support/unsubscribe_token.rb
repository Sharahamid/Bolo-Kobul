# Prints the matches-email unsubscribe token for a test member. LOCAL / TEST DATABASES ONLY.
# Usage: bin/rails runner e2e/support/unsubscribe_token.rb carol@example.com
abort('Not for production') if Rails.env.production?
print WeeklyReminderService.unsubscribe_token(User.find_by!(email: ARGV.first))
