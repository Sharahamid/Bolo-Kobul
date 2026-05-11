class RenameColumnsNotificationWillEmailSms < ActiveRecord::Migration[6.0]
  def change
    rename_column :notifications, :send_email, :will_email
    rename_column :notifications, :send_sms, :will_sms
  end
end
