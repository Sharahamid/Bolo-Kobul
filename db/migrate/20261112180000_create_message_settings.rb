# One row of on/off switches for every SMS and email the site sends (Admin > Manage Site > Messages On Off)
class CreateMessageSettings < ActiveRecord::Migration[8.1]
  def up
    create_table :message_settings do |t|
      t.boolean :sms_all, null: false, default: true
      t.boolean :sms_otp, null: false, default: true
      t.boolean :sms_kobul, null: false, default: true
      t.boolean :sms_purchase, null: false, default: true
      t.boolean :sms_text_alerts, null: false, default: true
      t.boolean :email_all, null: false, default: true
      t.boolean :email_account, null: false, default: true
      t.boolean :email_kobul, null: false, default: true
      t.boolean :email_chat, null: false, default: true
      t.boolean :email_purchase, null: false, default: true
      t.boolean :email_reminders, null: false, default: true
      t.boolean :email_admin, null: false, default: true
      t.timestamps
    end
    execute "INSERT INTO message_settings (created_at, updated_at) VALUES (NOW(), NOW())"
  end

  def down
    drop_table :message_settings
  end
end
