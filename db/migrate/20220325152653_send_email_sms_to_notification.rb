class SendEmailSmsToNotification < ActiveRecord::Migration[6.0]
  def change
    add_column :notifications, :send_email, :boolean, default: true
    add_column :notifications, :send_sms, :boolean, default: true
  end
end
