class AddWeeklyMatchesEmailToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :weekly_matches_email, :boolean, default: true, null: false
  end
end
