# When a member asked for their account to be deleted. The account is hidden at once
# and permanently erased 30 days later unless they cancel (see AccountDeletionService).
class AddDeletionRequestedAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :deletion_requested_at, :datetime, if_not_exists: true
    add_index :users, :deletion_requested_at, if_not_exists: true
  end
end
