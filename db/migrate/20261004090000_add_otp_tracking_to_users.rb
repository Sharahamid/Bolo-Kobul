class AddOtpTrackingToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :otp_sent_at, :datetime
    add_column :users, :otp_attempts, :integer, default: 0, null: false
  end
end
