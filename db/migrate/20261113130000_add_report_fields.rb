# For the admin Reports: follow-up status on Assisted Service orders, the time a profile
# report was reviewed, and a simple count of every SMS and email sent.
class AddReportFields < ActiveRecord::Migration[8.1]
  def up
    add_column :orders, :fulfilment_status, :string, null: false, default: 'to_do'
    add_column :orders, :fulfilment_note, :text
    add_column :orders, :fulfilled_at, :datetime
    add_column :profile_reports, :reviewed_at, :datetime
    execute "UPDATE profile_reports SET reviewed_at = updated_at WHERE status IN ('action_taken', 'dismissed')"
    create_table :message_logs do |t|
      t.string :channel, null: false   # sms, sms_failed, email
      t.string :kind                   # e.g. kobul1_sent, KobulOneMailer#send_request
      t.datetime :created_at, null: false
    end
    add_index :message_logs, [:channel, :created_at]
  end

  def down
    drop_table :message_logs
    remove_column :profile_reports, :reviewed_at
    remove_column :orders, :fulfilled_at
    remove_column :orders, :fulfilment_note
    remove_column :orders, :fulfilment_status
  end
end
